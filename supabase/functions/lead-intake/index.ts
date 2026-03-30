// lead-intake
// Lead intake webhook handler to normalize inbound lead payloads and call RPC create_lead_from_form.
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface LeadPayload {
  organization_id?: string;
  first_name: string;
  last_name: string;
  email?: string;
  phone?: string;
  company?: string;
  lead_source_name?: string;
  [key: string]: unknown;
}

function validateLeadPayload(payload: unknown): { valid: boolean; errors: string[] } {
  const errors: string[] = [];
  
  if (!payload || typeof payload !== 'object') {
    errors.push('Payload must be a JSON object');
    return { valid: false, errors };
  }

  const data = payload as Record<string, unknown>;
  
  if (!data.first_name || typeof data.first_name !== 'string') {
    errors.push('first_name is required and must be a string');
  }
  
  if (!data.last_name || typeof data.last_name !== 'string') {
    errors.push('last_name is required and must be a string');
  }

  if (data.email && typeof data.email !== 'string') {
    errors.push('email must be a string');
  }

  if (data.phone && typeof data.phone !== 'string') {
    errors.push('phone must be a string');
  }

  return {
    valid: errors.length === 0,
    errors,
  };
}

function normalizePayload(rawPayload: Record<string, unknown>, orgId: string): LeadPayload {
  return {
    organization_id: orgId,
    first_name: String(rawPayload.first_name || ''),
    last_name: String(rawPayload.last_name || ''),
    email: rawPayload.email ? String(rawPayload.email) : undefined,
    phone: rawPayload.phone ? String(rawPayload.phone).replace(/\D/g, '') : undefined,
    company: rawPayload.company ? String(rawPayload.company) : undefined,
    lead_source_name: rawPayload.lead_source_name ? String(rawPayload.lead_source_name) : 'Website Form',
    ...rawPayload,
  };
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseServiceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);

    // Parse incoming request
    let rawPayload: Record<string, unknown>;
    try {
      rawPayload = await req.json();
    } catch {
      return new Response(
        JSON.stringify({ ok: false, error: 'Invalid JSON payload' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
      );
    }

    // Validate payload structure
    const validation = validateLeadPayload(rawPayload);
    if (!validation.valid) {
      return new Response(
        JSON.stringify({ ok: false, error: 'Validation failed', errors: validation.errors }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
      );
    }

    // Get organization_id from payload or header or default
    let organizationId = rawPayload.organization_id as string;
    
    if (!organizationId) {
      const authHeader = req.headers.get('x-organization-id');
      organizationId = authHeader || Deno.env.get('DEFAULT_ORG_ID') || '';
    }

    if (!organizationId) {
      return new Response(
        JSON.stringify({ ok: false, error: 'organization_id is required (in payload or x-organization-id header)' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
      );
    }

    // Normalize the payload
    const normalizedPayload = normalizePayload(rawPayload, organizationId);

    // Call the RPC function to create lead from form
    const { data, error } = await supabase.rpc('create_lead_from_form', {
      payload: normalizedPayload,
    });

    if (error) {
      console.error('RPC error:', error);
      return new Response(
        JSON.stringify({ ok: false, error: error.message }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
      );
    }

    return new Response(
      JSON.stringify({
        ok: true,
        lead_id: data,
        message: 'Lead created successfully',
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 201 }
    );
  } catch (error) {
    console.error('Function error:', error);
    return new Response(
      JSON.stringify({ ok: false, error: String(error) }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
    );
  }
});
