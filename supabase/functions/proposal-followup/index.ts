// proposal-followup
// Scheduled/triggered follow-up for sent proposals.
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

    const now = new Date();
    const threeDaysAgo = new Date(now.getTime() - 3 * 24 * 60 * 60 * 1000);

    // Find proposals sent 3+ days ago with no response
    const { data: pendingProposals, error: fetchError } = await supabase
      .from('proposals')
      .select('id, organization_id, opportunity_id, contact_id, owner_user_id, sent_at')
      .eq('status', 'sent')
      .lte('sent_at', threeDaysAgo.toISOString());

    if (fetchError) throw new Error(fetchError.message);

    const followups = [];
    for (const proposal of pendingProposals || []) {
      const { error: taskError } = await supabase
        .from('tasks')
        .insert({
          organization_id: proposal.organization_id,
          related_object_type: 'proposal',
          related_record_id: proposal.id,
          owner_user_id: proposal.owner_user_id,
          task_type: 'followup',
          priority: 'normal',
          status: 'open',
          subject: 'Follow up on sent proposal',
          description: 'Proposal has been pending for 3+ days. Check in with customer.',
          due_at: new Date(now.getTime() + 24 * 60 * 60 * 1000).toISOString(),
        });

      if (!taskError) followups.push(proposal.id);
    }

    return new Response(JSON.stringify({ ok: true, followups_created: followups.length }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    });
  } catch (error) {
    return new Response(JSON.stringify({ ok: false, error: String(error) }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    });
  }
});
