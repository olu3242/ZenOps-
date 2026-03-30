-- ZenOps: rls.sql
-- Apply after tables and helper functions are created.

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

-- Communications, bookings, sales, automation, revenue, retention, admin policies are included in the full package and can be extended here as needed.
