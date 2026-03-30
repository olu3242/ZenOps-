// first-response-sla
// Scheduled job to flag and escalate leads missing first response SLA.
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseServiceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);

    const now = new Date();

    // Find leads that missed SLA (no first_response and due_at is past)
    const { data: missedSlaLeads, error: fetchError } = await supabase
      .from('leads')
      .select('id, organization_id, assigned_user_id, first_response_due_at, status')
      .is('first_response_at', null)
      .lt('first_response_due_at', now.toISOString())
      .eq('status', 'new');

    if (fetchError) {
      throw new Error(`Failed to fetch leads: ${fetchError.message}`);
    }

    const escalations = [];

    for (const lead of missedSlaLeads || []) {
      try {
        // Create escalation task for the assigned user
        const { data: createdTask, error: taskError } = await supabase
          .from('tasks')
          .insert({
            organization_id: lead.organization_id,
            related_object_type: 'lead',
            related_record_id: lead.id,
            owner_user_id: lead.assigned_user_id,
            task_type: 'escalation',
            priority: 'high',
            status: 'open',
            subject: 'SLA Breach: First Response Required',
            description: `Lead has exceeded the first response SLA. Immediate action required.`,
            due_at: new Date(now.getTime() + 30 * 60 * 1000).toISOString(), // 30 mins from now
          })
          .select('id');

        if (taskError) {
          console.error(`Failed to create task for lead ${lead.id}:`, taskError);
          continue;
        }

        // Update lead status to flagged
        const { error: updateError } = await supabase
          .from('leads')
          .update({ status: 'flagged' })
          .eq('id', lead.id);

        if (updateError) {
          console.error(`Failed to update lead ${lead.id}:`, updateError);
        } else {
          escalations.push({
            lead_id: lead.id,
            task_id: createdTask?.[0]?.id,
            status: 'escalated',
          });
        }
      } catch (err) {
        console.error(`Error processing lead ${lead.id}:`, err);
      }
    }

    return new Response(
      JSON.stringify({
        ok: true,
        escalations_created: escalations.length,
        details: escalations,
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
    );
  } catch (error) {
    console.error('Function error:', error);
    return new Response(
      JSON.stringify({ ok: false, error: String(error) }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
    );
  }
});
