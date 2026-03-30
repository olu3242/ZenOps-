// missed-call-handler
// Telephony webhook handler for missed calls and follow-up task/text-back enqueue.
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
    const { organization_id, contact_id, provider_user_id, call_duration_seconds } = payload as Record<string, unknown>;

    if (!organization_id || !contact_id) {
      return new Response(JSON.stringify({ ok: false, error: 'organization_id and contact_id required' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      });
    }

    // Create follow-up task
    const { data: task, error: taskError } = await supabase
      .from('tasks')
      .insert({
        organization_id,
        related_object_type: 'contact',
        related_record_id: contact_id,
        owner_user_id: provider_user_id,
        task_type: 'callback',
        priority: 'high',
        status: 'open',
        subject: 'Follow up missed call',
        description: `Contact did not answer the call. Please follow up.${call_duration_seconds ? ` (Ring time: ${call_duration_seconds}s)` : ''}`,
        due_at: new Date(Date.now() + 60 * 60 * 1000).toISOString(),
      })
      .select('id');

    if (taskError) throw new Error(taskError.message);

    return new Response(JSON.stringify({ ok: true, task_id: task?.[0]?.id }), {
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
