// review-request
// Post-service review request dispatcher.
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseServiceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);

    const payload = await req.json().catch(() => ({}));
    const { organization_id, contact_id, opportunity_id, request_date } = payload as Record<string, unknown>;

    if (!organization_id || !contact_id) {
      return new Response(JSON.stringify({ ok: false, error: 'organization_id and contact_id required' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      });
    }

    // Create review request
    const { data: review, error: reviewError } = await supabase
      .from('review_requests')
      .insert({
        organization_id,
        contact_id,
        opportunity_id,
        status: 'pending',
        requested_at: request_date || new Date().toISOString(),
        metadata: payload,
      })
      .select('id');

    if (reviewError) throw new Error(reviewError.message);

    return new Response(JSON.stringify({ ok: true, review_request_id: review?.[0]?.id }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 201,
    });
  } catch (error) {
    return new Response(JSON.stringify({ ok: false, error: String(error) }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    });
  }
});
