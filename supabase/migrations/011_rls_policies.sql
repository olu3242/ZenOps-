-- ZenOps: 011_rls_policies.sql
-- Comprehensive Row-Level Security policies for all tables

-- Enable RLS on all tables
alter table public.organizations enable row level security;
alter table public.teams enable row level security;
alter table public.profiles enable row level security;
alter table public.roles enable row level security;
alter table public.permission_sets enable row level security;
alter table public.users enable row level security;
alter table public.user_permission_assignments enable row level security;
alter table public.audit_logs enable row level security;
alter table public.accounts enable row level security;
alter table public.contacts enable row level security;
alter table public.lead_sources enable row level security;
alter table public.campaigns enable row level security;
alter table public.leads enable row level security;
alter table public.inquiry_events enable row level security;
alter table public.tasks enable row level security;
alter table public.tags enable row level security;
alter table public.record_tag_links enable row level security;
alter table public.conversations enable row level security;
alter table public.messages enable row level security;
alter table public.call_logs enable row level security;
alter table public.appointments enable row level security;
alter table public.pipelines enable row level security;
alter table public.pipeline_stages enable row level security;
alter table public.opportunities enable row level security;
alter table public.proposals enable row level security;
alter table public.proposal_items enable row level security;
alter table public.automation_rules enable row level security;
alter table public.automation_runs enable row level security;
alter table public.revenue_events enable row level security;
alter table public.source_attributions enable row level security;
alter table public.review_requests enable row level security;
alter table public.referrals enable row level security;
alter table public.integration_credentials enable row level security;
alter table public.custom_field_definitions enable row level security;
alter table public.custom_field_values enable row level security;

-- Foundation policies
create policy org_select_organizations on public.organizations for select using (id = public.current_user_organization_id());
create policy org_update_organizations on public.organizations for update using (id = public.current_user_organization_id() and (public.is_org_owner() or public.has_permission('manage_users')));
create policy org_select_teams on public.teams for select using (organization_id = public.current_user_organization_id());
create policy org_crud_teams on public.teams for all using (organization_id = public.current_user_organization_id()) with check (organization_id = public.current_user_organization_id());
create policy org_select_profiles on public.profiles for select using (organization_id = public.current_user_organization_id() or organization_id is null);
create policy org_select_roles on public.roles for select using (organization_id = public.current_user_organization_id());
create policy org_crud_roles on public.roles for all using (organization_id = public.current_user_organization_id() and (public.is_org_owner() or public.has_permission('manage_users'))) with check (organization_id = public.current_user_organization_id());
create policy org_select_permission_sets on public.permission_sets for select using (organization_id = public.current_user_organization_id() or organization_id is null);
create policy org_crud_permission_sets on public.permission_sets for all using ((organization_id = public.current_user_organization_id() or organization_id is null) and (public.is_org_owner() or public.has_permission('manage_users'))) with check (organization_id = public.current_user_organization_id() or organization_id is null);
create policy org_select_users on public.users for select using (organization_id = public.current_user_organization_id());
create policy self_update_users on public.users for update using (organization_id = public.current_user_organization_id() and (id = auth.uid() or public.is_org_owner() or public.has_permission('manage_users'))) with check (organization_id = public.current_user_organization_id());
create policy org_select_user_permission_assignments on public.user_permission_assignments for select using (exists (select 1 from public.users u where u.id = public.user_permission_assignments.user_id and u.organization_id = public.current_user_organization_id()));
create policy org_crud_user_permission_assignments on public.user_permission_assignments for all using (public.is_org_owner() or public.has_permission('manage_users')) with check (exists (select 1 from public.users u where u.id = public.user_permission_assignments.user_id and u.organization_id = public.current_user_organization_id()));
create policy admin_select_audit_logs on public.audit_logs for select using (organization_id = public.current_user_organization_id() and (public.is_org_owner() or public.has_permission('view_audit_logs')));

-- CRM policies
create policy org_crud_accounts on public.accounts for all using (organization_id = public.current_user_organization_id()) with check (organization_id = public.current_user_organization_id());
create policy org_crud_contacts on public.contacts for all using (organization_id = public.current_user_organization_id()) with check (organization_id = public.current_user_organization_id());
create policy org_crud_lead_sources on public.lead_sources for all using (organization_id = public.current_user_organization_id()) with check (organization_id = public.current_user_organization_id());
create policy org_crud_campaigns on public.campaigns for all using (organization_id = public.current_user_organization_id()) with check (organization_id = public.current_user_organization_id());
create policy org_select_leads on public.leads for select using (organization_id = public.current_user_organization_id() and (assigned_user_id = auth.uid() or public.can_view_team_record(team_id) or public.is_org_owner() or public.has_permission('view_all_leads')));
create policy org_insert_leads on public.leads for insert with check (organization_id = public.current_user_organization_id());
create policy org_update_leads on public.leads for update using (organization_id = public.current_user_organization_id() and (assigned_user_id = auth.uid() or public.can_view_team_record(team_id) or public.is_org_owner() or public.has_permission('manage_leads'))) with check (organization_id = public.current_user_organization_id());
create policy org_select_inquiry_events on public.inquiry_events for select using (organization_id = public.current_user_organization_id());
create policy org_insert_inquiry_events on public.inquiry_events for insert with check (organization_id = public.current_user_organization_id());
create policy org_select_tasks on public.tasks for select using (organization_id = public.current_user_organization_id() and (owner_user_id = auth.uid() or public.is_org_owner() or public.has_permission('view_all_tasks')));
create policy org_crud_tasks on public.tasks for all using (organization_id = public.current_user_organization_id()) with check (organization_id = public.current_user_organization_id());
create policy org_crud_tags on public.tags for all using (organization_id = public.current_user_organization_id()) with check (organization_id = public.current_user_organization_id());
create policy org_crud_record_tag_links on public.record_tag_links for all using (organization_id = public.current_user_organization_id()) with check (organization_id = public.current_user_organization_id());

-- Communications policies
create policy org_select_conversations on public.conversations for select using (organization_id = public.current_user_organization_id());
create policy org_crud_conversations on public.conversations for all using (organization_id = public.current_user_organization_id()) with check (organization_id = public.current_user_organization_id());
create policy org_select_messages on public.messages for select using (organization_id = public.current_user_organization_id());
create policy org_insert_messages on public.messages for insert with check (organization_id = public.current_user_organization_id());
create policy org_select_call_logs on public.call_logs for select using (organization_id = public.current_user_organization_id());
create policy org_crud_call_logs on public.call_logs for all using (organization_id = public.current_user_organization_id()) with check (organization_id = public.current_user_organization_id());

-- Bookings policies
create policy org_select_appointments on public.appointments for select using (organization_id = public.current_user_organization_id());
create policy org_crud_appointments on public.appointments for all using (organization_id = public.current_user_organization_id()) with check (organization_id = public.current_user_organization_id());

-- Sales & Opportunities policies
create policy org_crud_pipelines on public.pipelines for all using (organization_id = public.current_user_organization_id()) with check (organization_id = public.current_user_organization_id());
create policy org_crud_pipeline_stages on public.pipeline_stages for all using (
  exists (select 1 from public.pipelines p where p.id = public.pipeline_stages.pipeline_id and p.organization_id = public.current_user_organization_id())
) with check (
  exists (select 1 from public.pipelines p where p.id = public.pipeline_stages.pipeline_id and p.organization_id = public.current_user_organization_id())
);
create policy org_select_opportunities on public.opportunities for select using (organization_id = public.current_user_organization_id() and (owner_user_id = auth.uid() or public.is_org_owner() or public.has_permission('view_all_opportunities')));
create policy org_crud_opportunities on public.opportunities for all using (organization_id = public.current_user_organization_id()) with check (organization_id = public.current_user_organization_id());
create policy org_select_proposals on public.proposals for select using (organization_id = public.current_user_organization_id() and (owner_user_id = auth.uid() or public.is_org_owner() or public.has_permission('view_all_proposals')));
create policy org_crud_proposals on public.proposals for all using (organization_id = public.current_user_organization_id()) with check (organization_id = public.current_user_organization_id());
create policy org_crud_proposal_items on public.proposal_items for all using (
  exists (select 1 from public.proposals p where p.id = public.proposal_items.proposal_id and p.organization_id = public.current_user_organization_id())
) with check (
  exists (select 1 from public.proposals p where p.id = public.proposal_items.proposal_id and p.organization_id = public.current_user_organization_id())
);

-- Automation policies
create policy org_crud_automation_rules on public.automation_rules for all using (organization_id = public.current_user_organization_id()) with check (organization_id = public.current_user_organization_id());
create policy org_select_automation_runs on public.automation_runs for select using (organization_id = public.current_user_organization_id());
create policy org_insert_automation_runs on public.automation_runs for insert with check (organization_id = public.current_user_organization_id());

-- Revenue & Reporting policies
create policy org_crud_revenue_events on public.revenue_events for all using (organization_id = public.current_user_organization_id()) with check (organization_id = public.current_user_organization_id());
create policy org_crud_source_attributions on public.source_attributions for all using (organization_id = public.current_user_organization_id()) with check (organization_id = public.current_user_organization_id());

-- Retention policies
create policy org_crud_review_requests on public.review_requests for all using (organization_id = public.current_user_organization_id()) with check (organization_id = public.current_user_organization_id());
create policy org_crud_referrals on public.referrals for all using (organization_id = public.current_user_organization_id()) with check (organization_id = public.current_user_organization_id());

-- Admin & Settings policies
create policy org_crud_integration_credentials on public.integration_credentials for all using (organization_id = public.current_user_organization_id() and (public.is_org_owner() or public.has_permission('manage_integrations'))) with check (organization_id = public.current_user_organization_id());
create policy org_crud_custom_field_definitions on public.custom_field_definitions for all using (organization_id = public.current_user_organization_id() and (public.is_org_owner() or public.has_permission('manage_custom_fields'))) with check (organization_id = public.current_user_organization_id());
create policy org_crud_custom_field_values on public.custom_field_values for all using (organization_id = public.current_user_organization_id()) with check (organization_id = public.current_user_organization_id());
