import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { AwsV4Signer } from 'https://esm.sh/aws4fetch@1.0.20';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req: Request) => {
  // Allow cors preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    const r2AccountId = Deno.env.get('R2_ACCOUNT_ID') ?? '';
    const r2AccessKeyId = Deno.env.get('R2_ACCESS_KEY_ID') ?? '';
    const r2SecretAccessKey = Deno.env.get('R2_SECRET_ACCESS_KEY') ?? '';
    const r2BucketName = Deno.env.get('R2_BUCKET_NAME') ?? '';

    if (!supabaseUrl || !supabaseServiceKey || !r2AccountId || !r2AccessKeyId || !r2SecretAccessKey || !r2BucketName) {
      console.error('Missing configuration variables');
      return new Response(JSON.stringify({ error: 'Configuração incompleta.' }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // 1. Fetch attachments soft-deleted more than 30 days ago
    const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString();
    const { data: attachments, error: fetchError } = await supabase
      .from('attachments')
      .select('id, company_id, work_order_id, file_name')
      .lt('deleted_at', thirtyDaysAgo);

    if (fetchError) {
      console.error('Error fetching expired attachments:', fetchError);
      return new Response(JSON.stringify({ error: fetchError.message }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    if (!attachments || attachments.length === 0) {
      return new Response(JSON.stringify({ message: 'Nenhum anexo expirado para limpar.' }), {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    console.log(`Encontrados ${attachments.length} anexos expirados. Iniciando limpeza no R2...`);

    const r2Endpoint = `https://${r2AccountId}.r2.cloudflarestorage.com`;

    // 2. Loop through and delete from Cloudflare R2
    for (const attachment of attachments) {
      const ext = attachment.file_name.split('.').pop() || '';
      const objectKey = `attachments/${attachment.company_id}/${attachment.work_order_id}/${attachment.id}.${ext}`;
      const objectUrl = `${r2Endpoint}/${r2BucketName}/${objectKey}`;

      console.log(`Deletando do R2: ${objectKey}`);

      const signer = new AwsV4Signer({
        url: objectUrl,
        method: 'DELETE',
        accessKeyId: r2AccessKeyId,
        secretAccessKey: r2SecretAccessKey,
        region: 'auto',
        service: 's3',
      });

      const { url, headers } = await signer.sign();

      try {
        const r2Response = await fetch(url, {
          method: 'DELETE',
          headers,
        });

        if (!r2Response.ok) {
          console.error(`Erro ao deletar do R2 (${objectKey}): status ${r2Response.status}`);
        }
      } catch (err) {
        console.error(`Falha ao conectar no R2 para deletar ${objectKey}:`, err);
      }
    }

    // 3. Hard-delete rows from the database
    const idsToDelete = attachments.map((a) => a.id);
    const { error: deleteError } = await supabase
      .from('attachments')
      .delete()
      .in('id', idsToDelete);

    if (deleteError) {
      console.error('Erro ao remover registros do banco de dados:', deleteError);
      return new Response(JSON.stringify({ error: deleteError.message }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    console.log(`Limpeza concluída com sucesso. ${idsToDelete.length} anexos removidos.`);
    return new Response(JSON.stringify({ message: `Limpeza concluída. ${idsToDelete.length} anexos limpos.` }), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (error) {
    console.error('Unexpected error in cleanup-attachments:', error);
    return new Response(JSON.stringify({ error: 'Erro interno do servidor.' }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
