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

    // 1. Upsert the invitation record via the DB function
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
    let emailError = null;

    const { error: inviteErr } = await supabase.auth.admin.inviteUserByEmail(
      trimmedEmail,
      { redirectTo: redirectUrl }
    )

    if (inviteErr) {
      const errStr = (inviteErr.message || JSON.stringify(inviteErr)).toLowerCase();
      const isAlreadyRegistered =
        errStr.includes('already been registered') ||
        errStr.includes('already registered') ||
        inviteErr.status === 422 ||
        inviteErr.code === 'email_exists';

      if (isAlreadyRegistered) {
        // User already exists in auth.users -> send OTP / magic link email via SMTP/Resend redirecting to /accept-invite
        const { error: otpErr } = await supabase.auth.signInWithOtp({
          email: trimmedEmail,
          options: {
            emailRedirectTo: redirectUrl,
          },
        })
        emailError = otpErr
      } else {
        emailError = inviteErr
      }
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
