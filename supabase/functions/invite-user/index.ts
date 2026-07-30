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
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    const { email, company_id, permission_group_id, name, redirect_url } = await req.json()

    if (!email || !company_id || !permission_group_id) {
      return new Response(
        JSON.stringify({ error: 'Parâmetros ausentes: email, company_id ou permission_group_id.' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 1. Verify if user already exists in user_profiles
    const { data: existingProfile, error: profileErr } = await supabase
      .from('user_profiles')
      .select('id, email')
      .eq('email', email)
      .maybeSingle()

    if (profileErr) {
      throw profileErr
    }

    if (existingProfile) {
      return new Response(
        JSON.stringify({ error: 'Este e-mail já está associado a um usuário cadastrado.' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 2. Invite the user
    // We attach company_id, permission_group_id, and name to user_metadata
    // This metadata will be read by our PostgreSQL handle_new_user trigger when they accept the invite.
    const redirectUrl = redirect_url ?? `${req.headers.get('origin') ?? 'http://localhost:3000'}/change-password`

    const { data, error: inviteErr } = await supabase.auth.admin.inviteUserByEmail(
      email,
      {
        redirectTo: redirectUrl,
        data: {
          company_id,
          permission_group_id,
          name: name ?? email.split('@')[0]
        }
      }
    )

    if (inviteErr) {
      const inviteMsg = inviteErr.message || inviteErr.error_description || (typeof inviteErr === 'object' ? JSON.stringify(inviteErr) : String(inviteErr))
      return new Response(
        JSON.stringify({ error: `Erro ao convidar usuário: ${inviteMsg}` }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Set the default password to '123456' right after the invite is created
    if (data?.user?.id) {
      const { error: updateErr } = await supabase.auth.admin.updateUserById(
        data.user.id,
        { password: '123456' }
      )
      if (updateErr) {
        console.error('Erro ao definir senha padrão:', updateErr.message)
      }
    }

    return new Response(
      JSON.stringify({ message: 'Convite enviado com sucesso!', data }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    const catchMsg = error?.message || (typeof error === 'object' ? JSON.stringify(error) : String(error))
    return new Response(
      JSON.stringify({ error: catchMsg }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
