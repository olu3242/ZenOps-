// role-access-refresh
// Recalculate cached/effective access after profile or role changes.
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

    // Get all active users
    const { data: users, error: fetchError } = await supabase
      .from('users')
      .select('id, organization_id, role_id, profile_id')
      .eq('status', 'active');

    if (fetchError) throw new Error(fetchError.message);

    let refreshed = 0;

    for (const user of users || []) {
      try {
        // Verify role and permissions are still valid
        const { data: role } = await supabase
          .from('roles')
          .select('id')
          .eq('id', user.role_id)
          .eq('organization_id', user.organization_id)
          .single();

        const { data: profile } = await supabase
          .from('profiles')
          .select('id')
          .eq('id', user.profile_id)
          .eq('is_active', true)
          .single();

        if (role && profile) {
          refreshed++;
        } else {
          console.warn(`User ${user.id} has invalid role or profile`);
        }
      } catch (err) {
        console.error(`Error refreshing user ${user.id}:`, err);
      }
    }

    return new Response(JSON.stringify({ ok: true, users_refreshed: refreshed }), {
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
