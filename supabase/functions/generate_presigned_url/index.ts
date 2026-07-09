import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { AwsV4Signer } from 'https://esm.sh/aws4fetch@1.0.20';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

// Presigned URL TTL in seconds (15 minutes)
const PRESIGNED_URL_TTL_SECONDS = 900;

// Expected object key prefix for security validation
const VALID_KEY_PREFIX = 'attachments/';

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // ── 1. Read required secrets ───────────────────────────────────────────
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    const r2AccountId = Deno.env.get('R2_ACCOUNT_ID') ?? '';
    const r2AccessKeyId = Deno.env.get('R2_ACCESS_KEY_ID') ?? '';
    const r2SecretAccessKey = Deno.env.get('R2_SECRET_ACCESS_KEY') ?? '';
    const r2BucketName = Deno.env.get('R2_BUCKET_NAME') ?? '';
    const r2PublicUrl = Deno.env.get('R2_PUBLIC_URL') ?? '';

    if (!r2AccountId || !r2AccessKeyId || !r2SecretAccessKey || !r2BucketName || !r2PublicUrl) {
      console.error('Missing R2 environment variables');
      return jsonError('Configuração do servidor incompleta.', 500);
    }

    // ── 2. Validate caller JWT — extract user_id ───────────────────────────
    const authHeader = req.headers.get('Authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return jsonError('Token de autenticação ausente.', 401);
    }
    const jwt = authHeader.replace('Bearer ', '');

    // Use service-role client to verify the JWT and resolve the user
    const supabase = createClient(supabaseUrl, supabaseServiceKey);
    const { data: { user }, error: authError } = await supabase.auth.getUser(jwt);

    if (authError || !user) {
      return jsonError('Token inválido ou expirado.', 401);
    }

    // ── 3. Parse and validate request body ────────────────────────────────
    const body = await req.json().catch(() => null);
    const objectKey: string | undefined = body?.object_key;

    if (!objectKey || typeof objectKey !== 'string') {
      return jsonError('Parâmetro object_key ausente ou inválido.', 400);
    }

    // Key must start with the expected prefix
    if (!objectKey.startsWith(VALID_KEY_PREFIX)) {
      return jsonError('Formato de object_key inválido.', 400);
    }

    // ── 4. Enforce company ownership ──────────────────────────────────────
    // Extract company_id from the object key: attachments/{company_id}/...
    const keyParts = objectKey.split('/');
    if (keyParts.length < 3) {
      return jsonError('Formato de object_key inválido.', 400);
    }
    const companyIdFromKey = keyParts[1];

    // Look up the user's actual company_id from the database
    const { data: profile, error: profileError } = await supabase
      .from('user_profiles')
      .select('company_id')
      .eq('id', user.id)
      .maybeSingle();

    if (profileError || !profile) {
      return jsonError('Perfil de usuário não encontrado.', 403);
    }

    // The company_id in the key must match what the DB says — no spoofing
    if (profile.company_id !== companyIdFromKey) {
      return jsonError('Acesso negado: empresa inválida.', 403);
    }

    // ── 5. Generate presigned PUT URL via AWS SigV4 ───────────────────────
    // Cloudflare R2 uses the S3-compatible endpoint format
    const r2Endpoint = `https://${r2AccountId}.r2.cloudflarestorage.com`;
    const objectUrl = `${r2Endpoint}/${r2BucketName}/${objectKey}`;

    const signer = new AwsV4Signer({
      url: objectUrl,
      method: 'PUT',
      accessKeyId: r2AccessKeyId,
      secretAccessKey: r2SecretAccessKey,
      region: 'auto', // R2 always uses "auto"
      service: 's3',
      signQuery: true, // presigned URL: credentials go in query params, not headers
    });

    const expiryDate = new Date(Date.now() + PRESIGNED_URL_TTL_SECONDS * 1000);
    const { url: presignedUrl } = await signer.sign({
      headers: { host: new URL(r2Endpoint).host },
      query: { 'X-Amz-Expires': String(PRESIGNED_URL_TTL_SECONDS) },
    });

    // ── 6. Build the final public URL (served via R2 public domain) ────────
    // The presigned URL points to the R2 S3-compatible endpoint — not the CDN.
    // The public URL (served to app users) uses the R2 public domain or your custom domain.
    const fileKey = objectKey;
    const publicUrl = `${r2PublicUrl}/${fileKey}`;

    return new Response(
      JSON.stringify({
        upload_url: presignedUrl.toString(),
        file_key: fileKey,
        public_url: publicUrl,
        expires_at: expiryDate.toISOString(),
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      },
    );
  } catch (error) {
    console.error('Unexpected error in generate_presigned_url:', error);
    return jsonError('Erro interno do servidor.', 500);
  }
});

// ── Helper ─────────────────────────────────────────────────────────────────

function jsonError(message: string, status: number): Response {
  return new Response(JSON.stringify({ error: message }), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}
