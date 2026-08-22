import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface PushNotificationPayload {
  user_ids: string[]
  title: string
  body: string
  data?: Record<string, string>
}

// Helper to create OAuth2 access token for Firebase HTTP v1 API using service account
async function getAccessToken(serviceAccount: Record<string, any>): Promise<string> {
  const iat = Math.floor(Date.now() / 1000)
  const exp = iat + 3600

  const header = {
    alg: "RS256",
    typ: "JWT",
  }

  const claimSet = {
    iss: serviceAccount.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    exp,
    iat,
  }

  const encodedHeader = btoa(JSON.stringify(header)).replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_")
  const encodedClaim = btoa(JSON.stringify(claimSet)).replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_")
  const unsignedToken = `${encodedHeader}.${encodedClaim}`

  // Convert PEM private key to CryptoKey
  const pem = serviceAccount.private_key
  const binaryDer = pemToDer(pem)
  const key = await crypto.subtle.importKey(
    "pkcs8",
    binaryDer,
    {
      name: "RSASSA-PKCS1-v1_5",
      hash: "SHA-256",
    },
    false,
    ["sign"]
  )

  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(unsignedToken)
  )

  const encodedSignature = btoa(String.fromCharCode(...new Uint8Array(signature)))
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_")

  const jwt = `${unsignedToken}.${encodedSignature}`

  // Exchange JWT for OAuth2 token
  const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
  })

  const tokenData = await tokenRes.json()
  if (!tokenData.access_token) {
    throw new Error(`Failed to obtain Google OAuth2 access token: ${JSON.stringify(tokenData)}`)
  }
  return tokenData.access_token
}

function pemToDer(pem: string): Uint8Array {
  const lines = pem.split("\n").filter((l) => !l.includes("-----"))
  const b64 = lines.join("").trim()
  const raw = atob(b64)
  const uint8 = new Uint8Array(raw.length)
  for (let i = 0; i < raw.length; i++) {
    uint8[i] = raw.charCodeAt(i)
  }
  return uint8
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    const payload: PushNotificationPayload = await req.json()
    const { user_ids, title, body, data = {} } = payload

    if (!user_ids || !Array.isArray(user_ids) || user_ids.length === 0 || !title || !body) {
      return new Response(
        JSON.stringify({ error: 'Parâmetros obrigatórios ausentes: user_ids, title ou body.' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 1. Fetch user configurations to exclude users with disabled notifications
    const { data: configs } = await supabase
      .from('user_configurations')
      .select('user_id, push_notifications_enabled')
      .in('user_id', user_ids)

    const disabledUserIds = new Set(
      (configs ?? [])
        .filter((c) => c.push_notifications_enabled === false)
        .map((c) => c.user_id)
    )

    const targetUserIds = user_ids.filter((id) => !disabledUserIds.has(id))
    if (targetUserIds.length === 0) {
      return new Response(
        JSON.stringify({ message: 'Todos os usuários de destino desativaram as notificações.', sent: 0 }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 2. Fetch device tokens for active users
    const { data: tokens, error: tokensErr } = await supabase
      .from('user_device_tokens')
      .select('id, user_id, device_token, platform')
      .in('user_id', targetUserIds)

    if (tokensErr) {
      throw tokensErr
    }

    if (!tokens || tokens.length === 0) {
      return new Response(
        JSON.stringify({ message: 'Nenhum token de dispositivo encontrado para os usuários.', sent: 0 }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 3. Dispatch notifications via Firebase Cloud Messaging
    const serviceAccountJson = Deno.env.get('FIREBASE_SERVICE_ACCOUNT')
    let accessToken: string | null = null
    let projectId = 'serviceproviders-733e7'

    if (serviceAccountJson) {
      try {
        const serviceAccount = JSON.parse(serviceAccountJson)
        projectId = serviceAccount.project_id || projectId
        accessToken = await getAccessToken(serviceAccount)
      } catch (err) {
        console.error('Erro ao processar FIREBASE_SERVICE_ACCOUNT:', err)
      }
    }

    const deadTokenIds: string[] = []
    let successCount = 0

    if (accessToken) {
      // Send each message using FCM HTTP v1
      for (const tokenItem of tokens) {
        try {
          const fcmMessage = {
            message: {
              token: tokenItem.device_token,
              notification: {
                title,
                body,
              },
              data,
              android: {
                priority: 'HIGH',
                notification: {
                  channel_id: 'high_importance_channel',
                  sound: 'default',
                },
              },
              apns: {
                payload: {
                  aps: {
                    sound: 'default',
                    badge: 1,
                  },
                },
              },
            },
          }

          const fcmRes = await fetch(
            `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
            {
              method: 'POST',
              headers: {
                'Content-Type': 'application/json',
                Authorization: `Bearer ${accessToken}`,
              },
              body: JSON.stringify(fcmMessage),
            }
          )

          if (fcmRes.ok) {
            successCount++
          } else {
            const errBody = await fcmRes.json()
            console.error(`FCM error for token ${tokenItem.device_token}:`, errBody)
            // If token is invalid or unregistered, queue for deletion
            if (
              fcmRes.status === 404 ||
              fcmRes.status === 410 ||
              errBody?.error?.details?.some((d: any) => d.errorCode === 'UNREGISTERED')
            ) {
              deadTokenIds.push(tokenItem.id)
            }
          }
        } catch (e) {
          console.error(`Falha ao enviar para token ${tokenItem.device_token}:`, e)
        }
      }
    } else {
      console.warn('FIREBASE_SERVICE_ACCOUNT não configurada. Notificações simuladas.')
      successCount = tokens.length
    }

    // 4. Cleanup stale/dead tokens if any
    if (deadTokenIds.length > 0) {
      await supabase.from('user_device_tokens').delete().in('id', deadTokenIds)
    }

    return new Response(
      JSON.stringify({
        message: 'Disparo de notificações processado com sucesso.',
        total_tokens: tokens.length,
        sent: successCount,
        cleaned_dead_tokens: deadTokenIds.length,
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    const errorMsg = error?.message || (typeof error === 'object' ? JSON.stringify(error) : String(error))
    return new Response(
      JSON.stringify({ error: errorMsg }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
