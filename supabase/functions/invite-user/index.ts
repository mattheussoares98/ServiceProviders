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

    const trimmedEmail = email.trim().toLowerCase()

    // 1. Check if user profile already exists in user_profiles
    const { data: existingProfile, error: profileErr } = await supabase
      .from('user_profiles')
      .select('id, email, company_id, is_active, deleted_at')
      .eq('email', trimmedEmail)
      .maybeSingle()

    if (profileErr) {
      throw profileErr
    }

    if (existingProfile) {
      if (existingProfile.company_id === company_id && existingProfile.is_active && !existingProfile.deleted_at) {
        return new Response(
          JSON.stringify({ error: 'Este e-mail já está cadastrado como usuário ativo nesta empresa.' }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
    }

    const redirectUrl = redirect_url ?? `${req.headers.get('origin') ?? 'http://localhost:3000'}/change-password`

    // 2. Attempt to invite user via Supabase Auth admin API
    const { data: inviteData, error: inviteErr } = await supabase.auth.admin.inviteUserByEmail(
      trimmedEmail,
      {
        redirectTo: redirectUrl,
        data: {
          company_id,
          permission_group_id,
          name: name ?? trimmedEmail.split('@')[0]
        }
      }
    )

    if (inviteErr) {
      const errStr = (inviteErr.message || JSON.stringify(inviteErr)).toLowerCase()
      const isAlreadyRegistered =
        errStr.includes('already been registered') ||
        errStr.includes('already registered') ||
        inviteErr.status === 422 ||
        inviteErr.code === 'email_exists'

      if (isAlreadyRegistered) {
        // User already exists in auth.users -> find authUserId and attach to user_profiles
        let authUserId = existingProfile?.id

        if (!authUserId) {
          const { data: spProfile } = await supabase
            .from('service_provider_profiles')
            .select('auth_user_id')
            .eq('email', trimmedEmail)
            .maybeSingle()

          if (spProfile?.auth_user_id) {
            authUserId = spProfile.auth_user_id
          }
        }

        if (!authUserId) {
          const { data: usersData } = await supabase.auth.admin.listUsers()
          const matchedUser = usersData?.users?.find(
            (u) => u.email?.toLowerCase() === trimmedEmail
          )
          if (matchedUser) {
            authUserId = matchedUser.id
          }
        }

        if (!authUserId) {
          return new Response(
            JSON.stringify({ error: `Erro ao convidar usuário: ${inviteErr.message}` }),
            { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
          )
        }

        if (existingProfile) {
          const { error: updateErr } = await supabase
            .from('user_profiles')
            .update({
              company_id: company_id,
              permission_group_id: permission_group_id,
              is_active: true,
              deleted_at: null,
              updated_at: new Date().toISOString(),
            })
            .eq('id', authUserId)

          if (updateErr) {
            throw updateErr
          }
        } else {
          const { error: insertErr } = await supabase
            .from('user_profiles')
            .insert({
              id: authUserId,
              company_id: company_id,
              name: name ?? trimmedEmail.split('@')[0],
              email: trimmedEmail,
              permission_group_id: permission_group_id,
              is_active: true,
              is_admin: false,
              created_at: new Date().toISOString(),
              updated_at: new Date().toISOString(),
            })

          if (insertErr) {
            throw insertErr
          }
        }

        // Send OTP / Magic link to notify the existing user
        const { error: otpErr } = await supabase.auth.signInWithOtp({
          email: trimmedEmail,
          options: {
            emailRedirectTo: redirectUrl,
          },
        })

        if (otpErr) {
          console.error('Erro ao enviar magic link para usuário existente:', otpErr)
        }

        return new Response(
          JSON.stringify({
            message: 'Convite enviado com sucesso para o usuário existente!',
            data: { user: { id: authUserId, email: trimmedEmail } },
          }),
          { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      } else {
        const inviteMsg = inviteErr.message || inviteErr.error_description || (typeof inviteErr === 'object' ? JSON.stringify(inviteErr) : String(inviteErr))
        return new Response(
          JSON.stringify({ error: `Erro ao convidar usuário: ${inviteMsg}` }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
    }

    // Set default password to '123456' right after the invite is created for brand-new users
    if (inviteData?.user?.id) {
      const { error: updateErr } = await supabase.auth.admin.updateUserById(
        inviteData.user.id,
        { password: '123456' }
      )
      if (updateErr) {
        console.error('Erro ao definir senha padrão:', updateErr.message)
      }
    }

    return new Response(
      JSON.stringify({ message: 'Convite enviado com sucesso!', data: inviteData }),
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
