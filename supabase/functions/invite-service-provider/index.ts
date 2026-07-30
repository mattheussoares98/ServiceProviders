import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    const appBaseUrl = Deno.env.get('APP_BASE_URL') ?? 'https://serviceproviders-733e7.web.app'

    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    const { service_provider_company_id, email } = await req.json()

    if (!service_provider_company_id || !email) {
      return new Response(
        JSON.stringify({ error: 'Parâmetros ausentes: service_provider_company_id ou email.' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const trimmedEmail = email.trim().toLowerCase()

    // 1. Check if a valid pending invitation already exists
    const { data: existingInvitation, error: invitationErr } = await supabase
      .from('service_provider_invitations')
      .select('id, status, expires_at')
      .eq('email', trimmedEmail)
      .eq('service_provider_company_id', service_provider_company_id)
      .eq('status', 'pending')
      .maybeSingle()

    if (invitationErr) {
      throw invitationErr
    }

    if (existingInvitation) {
      const expiresAt = existingInvitation.expires_at ? new Date(existingInvitation.expires_at) : null
      const isStillValid = expiresAt === null || expiresAt > new Date()

      if (isStillValid) {
        return new Response(
          JSON.stringify({ error: 'Já existe um convite pendente para este e-mail.' }),
          { status: 409, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
    }

    // 2. Upsert the invitation record via the DB function
    const { data: invitationId, error: rpcError } = await supabase.rpc(
      'create_service_provider_invitation',
      {
        p_email: trimmedEmail,
        p_service_provider_company_id: service_provider_company_id,
        p_invite_token: crypto.randomUUID(),
        p_expires_in_days: 7,
      }
    )

    if (rpcError) {
      throw rpcError
    }

    // 3. Retrieve the token to embed in the redirect URL
    const { data: invitation, error: fetchErr } = await supabase
      .from('service_provider_invitations')
      .select('invite_token')
      .eq('id', invitationId)
      .single()

    if (fetchErr) {
      throw fetchErr
    }

    // 4. Build redirect URL for the deeplink/web app
    const redirectUrl = `${appBaseUrl}/accept-invite`

    // 5. Send invite email via Supabase Auth (or generate magic link if user already exists in auth.users)
    const { data: existingUser } = await supabase
      .from('user_profiles')
      .select('id')
      .eq('email', trimmedEmail)
      .maybeSingle()

    let emailError = null;

    if (!existingUser) {
      // User doesn't exist yet -> send standard Auth invite email via SMTP
      const { error: inviteErr } = await supabase.auth.admin.inviteUserByEmail(
        trimmedEmail,
        { redirectTo: redirectUrl }
      )
      emailError = inviteErr
    } else {
      // User already exists -> generate link / magic link email redirecting to SP acceptance page
      const { error: linkErr } = await supabase.auth.admin.generateLink({
        type: 'magiclink',
        email: trimmedEmail,
        options: { redirectTo: redirectUrl }
      })
      emailError = linkErr
    }

    if (emailError) {
      console.error('Erro ao enviar e-mail de convite:', emailError)
      const errorMessage = emailError.message || emailError.error_description || (typeof emailError === 'object' ? JSON.stringify(emailError) : String(emailError))
      return new Response(
        JSON.stringify({ error: `Erro ao disparar e-mail via SMTP: ${errorMessage}` }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    return new Response(
      JSON.stringify({ message: 'Convite enviado com sucesso!', invitation_id: invitationId }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    const catchMessage = error?.message || (typeof error === 'object' ? JSON.stringify(error) : String(error))
    return new Response(
      JSON.stringify({ error: catchMessage }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
