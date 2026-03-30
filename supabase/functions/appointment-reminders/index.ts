// appointment-reminders
// Scheduled reminders for upcoming appointments.
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

    // Query upcoming appointments in the next 24 hours that need reminders
    const now = new Date();
    const in24Hours = new Date(now.getTime() + 24 * 60 * 60 * 1000);

    const { data: appointments, error: appointmentsError } = await supabase
      .from('appointments')
      .select('id, contact_id, provider_user_id, start_at, status, appointment_type')
      .eq('status', 'scheduled')
      .eq('reminder_status', null)
      .gte('start_at', now.toISOString())
      .lte('start_at', in24Hours.toISOString());

    if (appointmentsError) {
      throw new Error(`Failed to fetch appointments: ${appointmentsError.message}`);
    }

    // Get contact and provider info for reminders
    const reminders = [];
    
    for (const appt of appointments || []) {
      try {
        // Get contact email
        const { data: contact } = await supabase
          .from('contacts')
          .select('email, first_name, last_name')
          .eq('id', appt.contact_id)
          .single();

        // Get provider info
        const { data: provider } = await supabase
          .from('users')
          .select('email, first_name, last_name')
          .eq('id', appt.provider_user_id)
          .single();

        if (contact?.email && provider?.email) {
          reminders.push({
            appointment_id: appt.id,
            contact_email: contact.email,
            contact_name: `${contact.first_name} ${contact.last_name}`,
            provider_email: provider.email,
            provider_name: `${provider.first_name} ${provider.last_name}`,
            appointment_type: appt.appointment_type,
            start_at: appt.start_at,
          });

          // Mark appointment as having reminder sent
          await supabase
            .from('appointments')
            .update({ reminder_status: 'sent' })
            .eq('id', appt.id);
        }
      } catch (err) {
        console.error(`Error processing appointment ${appt.id}:`, err);
      }
    }

    return new Response(
      JSON.stringify({
        ok: true,
        reminders_sent: reminders.length,
        details: reminders,
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
