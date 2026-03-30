// opportunity-won
// Post-win workflow dispatcher for revenue and retention actions.
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
    const { organization_id, opportunity_id, deal_value, won_date } = payload as Record<string, unknown>;

    if (!organization_id || !opportunity_id || !deal_value) {
      return new Response(JSON.stringify({ ok: false, error: 'organization_id, opportunity_id, and deal_value required' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      });
    }

    // Record revenue event for reporting
    const { data: event, error: eventError } = await supabase
      .from('revenue_events')
      .insert({
        organization_id,
        opportunity_id,
        event_type: 'won',
        event_date: won_date || new Date().toISOString(),
        deal_value: parseFloat(deal_value as string),
        metadata: payload,
      })
      .select('id');

    if (eventError) throw new Error(eventError.message);

    return new Response(JSON.stringify({ ok: true, event_id: event?.[0]?.id, message: 'Revenue event recorded' }), {
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
