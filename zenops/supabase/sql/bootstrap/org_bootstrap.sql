-- ZenOps organization bootstrap helpers

create or replace function public.bootstrap_zenops_organization(
  p_org_name text,
  p_owner_user_id uuid default null,
  p_industry text default 'dental'
)
returns uuid
language plpgsql
security definer
as $$
declare
  v_org_id uuid;
  v_general_team_id uuid;
  v_owner_role_id uuid;
  v_ops_manager_role_id uuid;
  v_intake_lead_role_id uuid;
  v_intake_rep_role_id uuid;
  v_sales_lead_role_id uuid;
  v_sales_rep_role_id uuid;
  v_marketing_manager_role_id uuid;
  v_provider_role_id uuid;
  v_lead_pipeline_id uuid;
  v_opp_pipeline_id uuid;
begin
  insert into public.organizations (name, industry, timezone, subscription_plan, status, onboarding_status, owner_user_id)
  values (p_org_name, p_industry, 'America/Chicago', 'starter', 'active', 'in_progress', p_owner_user_id)
  returning id into v_org_id;

  insert into public.teams (organization_id, name, description, manager_user_id)
  values (v_org_id, 'General Intake', 'Default intake and routing team', p_owner_user_id)
  returning id into v_general_team_id;

  insert into public.roles (organization_id, name, hierarchy_level, can_approve_proposals, can_manage_users, can_view_team_records)
  values (v_org_id, 'Owner', 100, true, true, true) returning id into v_owner_role_id;

  insert into public.roles (organization_id, name, parent_role_id, hierarchy_level, can_approve_proposals, can_manage_users, can_view_team_records)
  values
    (v_org_id, 'Operations Manager', v_owner_role_id, 80, true, true, true),
    (v_org_id, 'Intake Lead', v_owner_role_id, 70, false, false, true),
    (v_org_id, 'Intake Rep', v_owner_role_id, 60, false, false, false),
    (v_org_id, 'Sales Lead', v_owner_role_id, 70, true, false, true),
    (v_org_id, 'Sales Rep', v_owner_role_id, 60, false, false, false),
    (v_org_id, 'Marketing Manager', v_owner_role_id, 65, false, false, true),
    (v_org_id, 'Provider', v_owner_role_id, 50, false, false, false);

  select id into v_ops_manager_role_id from public.roles where organization_id = v_org_id and name = 'Operations Manager' limit 1;
  select id into v_intake_lead_role_id from public.roles where organization_id = v_org_id and name = 'Intake Lead' limit 1;
  select id into v_intake_rep_role_id from public.roles where organization_id = v_org_id and name = 'Intake Rep' limit 1;
  select id into v_sales_lead_role_id from public.roles where organization_id = v_org_id and name = 'Sales Lead' limit 1;
  select id into v_sales_rep_role_id from public.roles where organization_id = v_org_id and name = 'Sales Rep' limit 1;
  select id into v_marketing_manager_role_id from public.roles where organization_id = v_org_id and name = 'Marketing Manager' limit 1;
  select id into v_provider_role_id from public.roles where organization_id = v_org_id and name = 'Provider' limit 1;

  insert into public.pipelines (organization_id, name, object_type, is_default, is_active)
  values
    (v_org_id, 'Lead Pipeline', 'lead', true, true),
    (v_org_id, 'Opportunity Pipeline', 'opportunity', true, true);

  select id into v_lead_pipeline_id from public.pipelines where organization_id = v_org_id and name = 'Lead Pipeline' limit 1;
  select id into v_opp_pipeline_id from public.pipelines where organization_id = v_org_id and name = 'Opportunity Pipeline' limit 1;

  insert into public.pipeline_stages (pipeline_id, name, sequence_order, probability_percent, stage_category, sla_hours, is_active)
  values
    (v_lead_pipeline_id, 'New Inquiry', 1, 5, 'open', 1, true),
    (v_lead_pipeline_id, 'Attempted Contact', 2, 15, 'open', 4, true),
    (v_lead_pipeline_id, 'Qualified', 3, 35, 'open', 8, true),
    (v_lead_pipeline_id, 'Booked Consultation', 4, 60, 'open', 24, true),
    (v_lead_pipeline_id, 'No Show', 5, 20, 'open', 24, true),
    (v_lead_pipeline_id, 'Unresponsive', 6, 10, 'lost', 48, true),
    (v_lead_pipeline_id, 'Converted', 7, 100, 'won', 0, true),
    (v_lead_pipeline_id, 'Disqualified', 8, 0, 'lost', 0, true),
    (v_opp_pipeline_id, 'Consultation Completed', 1, 25, 'open', 24, true),
    (v_opp_pipeline_id, 'Treatment Plan Sent', 2, 50, 'open', 48, true),
    (v_opp_pipeline_id, 'Follow-Up Needed', 3, 60, 'open', 72, true),
    (v_opp_pipeline_id, 'Accepted', 4, 80, 'open', 24, true),
    (v_opp_pipeline_id, 'Won', 5, 100, 'won', 0, true),
    (v_opp_pipeline_id, 'Lost', 6, 0, 'lost', 0, true);

  insert into public.lead_sources (organization_id, name, type, platform, is_active)
  values
    (v_org_id, 'Website Form', 'web', 'website', true),
    (v_org_id, 'Google Ads', 'paid', 'google', true),
    (v_org_id, 'Facebook Lead Form', 'paid', 'facebook', true),
    (v_org_id, 'Organic Search', 'organic', 'google', true),
    (v_org_id, 'Referral', 'referral', null, true),
    (v_org_id, 'Phone Call', 'call', null, true),
    (v_org_id, 'Walk-In', 'direct', null, true),
    (v_org_id, 'QR Campaign', 'qr', null, true);

  insert into public.automation_rules (organization_id, name, object_type, trigger_event, entry_criteria_json, actions_json, is_active, version_number, created_by_user_id)
  values
    (v_org_id, 'New Lead Immediate Response', 'lead', 'lead.created', '{"status":["new"]}'::jsonb, '[{"type":"send_sms_template","template":"new_lead_ack"},{"type":"create_task","task_type":"follow_up","due_in_minutes":15}]'::jsonb, true, 1, p_owner_user_id),
    (v_org_id, 'Missed Call Text Back', 'inquiry_event', 'inquiry_event.created', '{"event_type":["missed_call"]}'::jsonb, '[{"type":"send_sms_template","template":"missed_call_text_back"}]'::jsonb, true, 1, p_owner_user_id),
    (v_org_id, 'Appointment Reminder', 'appointment', 'appointment.scheduled', '{"status":["scheduled"]}'::jsonb, '[{"type":"schedule_reminder","offset_hours":24},{"type":"schedule_reminder","offset_hours":2}]'::jsonb, true, 1, p_owner_user_id),
    (v_org_id, 'Proposal Follow-Up', 'proposal', 'proposal.sent', '{"status":["sent"]}'::jsonb, '[{"type":"schedule_followup","offset_days":2},{"type":"schedule_followup","offset_days":5}]'::jsonb, true, 1, p_owner_user_id),
    (v_org_id, 'Review Request After Visit', 'appointment', 'appointment.completed', '{"status":["completed"]}'::jsonb, '[{"type":"send_review_request"}]'::jsonb, true, 1, p_owner_user_id);

  return v_org_id;
end;
$$;

comment on function public.bootstrap_zenops_organization(text, uuid, text) is 'Creates a new ZenOps organization with default team, roles, pipelines, stages, lead sources, and starter automation templates.';
