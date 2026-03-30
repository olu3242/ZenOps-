-- ZenOps: 004_crm_core.sql
create table if not exists public.accounts (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  owner_user_id uuid references public.users(id),
  name text not null,
  industry text,
  website text,
  phone text,
  billing_address jsonb not null default '{}'::jsonb,
  status text not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.contacts (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  account_id uuid references public.accounts(id),
  owner_user_id uuid references public.users(id),
  first_name text not null,
  last_name text not null,
  phone text,
  email citext,
  preferred_contact_method text,
  address jsonb not null default '{}'::jsonb,
  lifecycle_status text not null default 'active',
  do_not_contact boolean not null default false,
  source_primary text,
  last_activity_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.lead_sources (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  name text not null,
  type text not null,
  platform text,
  campaign_tracking_code text,
  is_active boolean not null default true,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.campaigns (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  owner_user_id uuid references public.users(id),
  name text not null,
  type text not null,
  status text not null default 'draft',
  start_date date,
  end_date date,
  budget_amount numeric(12,2),
  source_platform text,
  goal text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.leads (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  contact_id uuid references public.contacts(id),
  account_id uuid references public.accounts(id),
  lead_source_id uuid not null references public.lead_sources(id),
  assigned_user_id uuid references public.users(id),
  team_id uuid references public.teams(id),
  campaign_id uuid references public.campaigns(id),
  status text not null default 'new',
  qualification_status text not null default 'unreviewed',
  urgency_score integer,
  source_channel text,
  first_response_due_at timestamptz,
  first_response_at timestamptz,
  converted_contact_id uuid references public.contacts(id),
  converted_opportunity_id uuid,
  notes_summary_ai text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.inquiry_events (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  lead_id uuid not null references public.leads(id) on delete cascade,
  contact_id uuid references public.contacts(id),
  source_type text not null,
  event_type text not null,
  raw_payload_json jsonb not null default '{}'::jsonb,
  captured_at timestamptz not null default now(),
  handled_at timestamptz,
  handled_by_user_id uuid references public.users(id)
);
create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  related_object_type text not null,
  related_record_id uuid not null,
  owner_user_id uuid not null references public.users(id),
  created_by_user_id uuid references public.users(id),
  task_type text not null,
  priority text not null default 'normal',
  status text not null default 'open',
  due_at timestamptz,
  completed_at timestamptz,
  subject text not null,
  description text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.tags (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  name text not null,
  color text,
  is_active boolean not null default true
);
create table if not exists public.record_tag_links (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  tag_id uuid not null references public.tags(id) on delete cascade,
  related_object_type text not null,
  related_record_id uuid not null,
  created_at timestamptz not null default now()
);
create index if not exists idx_accounts_org on public.accounts(organization_id);
create index if not exists idx_contacts_org on public.contacts(organization_id);
create index if not exists idx_contacts_email on public.contacts(email);
create index if not exists idx_contacts_phone on public.contacts(phone);
create index if not exists idx_lead_sources_org on public.lead_sources(organization_id);
create index if not exists idx_campaigns_org on public.campaigns(organization_id);
create index if not exists idx_leads_org on public.leads(organization_id);
create index if not exists idx_leads_assigned_user on public.leads(assigned_user_id);
create index if not exists idx_leads_team on public.leads(team_id);
create index if not exists idx_leads_status on public.leads(status);
create index if not exists idx_inquiry_events_lead on public.inquiry_events(lead_id);
create index if not exists idx_tasks_org_owner on public.tasks(organization_id, owner_user_id, status);
create index if not exists idx_record_tag_links_target on public.record_tag_links(related_object_type, related_record_id);
drop trigger if exists trg_accounts_updated_at on public.accounts;
create trigger trg_accounts_updated_at before update on public.accounts for each row execute function public.set_updated_at();
drop trigger if exists trg_contacts_updated_at on public.contacts;
create trigger trg_contacts_updated_at before update on public.contacts for each row execute function public.set_updated_at();
drop trigger if exists trg_lead_sources_updated_at on public.lead_sources;
create trigger trg_lead_sources_updated_at before update on public.lead_sources for each row execute function public.set_updated_at();
drop trigger if exists trg_campaigns_updated_at on public.campaigns;
create trigger trg_campaigns_updated_at before update on public.campaigns for each row execute function public.set_updated_at();
drop trigger if exists trg_leads_updated_at on public.leads;
create trigger trg_leads_updated_at before update on public.leads for each row execute function public.set_updated_at();
drop trigger if exists trg_tasks_updated_at on public.tasks;
create trigger trg_tasks_updated_at before update on public.tasks for each row execute function public.set_updated_at();
create or replace function public.match_or_create_contact(p_organization_id uuid,p_email citext,p_phone text,p_first_name text,p_last_name text) returns uuid language plpgsql security definer as $$
declare v_contact_id uuid;
begin
  select c.id into v_contact_id from public.contacts c
  where c.organization_id = p_organization_id and ((p_email is not null and c.email = p_email) or (p_phone is not null and c.phone = p_phone))
  limit 1;
  if v_contact_id is null then
    insert into public.contacts (organization_id, email, phone, first_name, last_name)
    values (p_organization_id, p_email, p_phone, coalesce(p_first_name, 'Unknown'), coalesce(p_last_name, 'Contact'))
    returning id into v_contact_id;
  end if;
  return v_contact_id;
end;
$$;
create or replace function public.create_lead_from_form(payload jsonb) returns uuid language plpgsql security definer as $$
declare v_org_id uuid; v_contact_id uuid; v_lead_source_id uuid; v_lead_id uuid;
begin
  v_org_id := (payload ->> 'organization_id')::uuid;
  select id into v_lead_source_id from public.lead_sources where organization_id = v_org_id and name = coalesce(payload ->> 'lead_source_name', 'Website Form') limit 1;
  if v_lead_source_id is null then
    insert into public.lead_sources (organization_id, name, type)
    values (v_org_id, coalesce(payload ->> 'lead_source_name', 'Website Form'), 'web')
    returning id into v_lead_source_id;
  end if;
  v_contact_id := public.match_or_create_contact(v_org_id, (payload ->> 'email')::citext, payload ->> 'phone', payload ->> 'first_name', payload ->> 'last_name');
  insert into public.leads (organization_id, contact_id, lead_source_id, source_channel, metadata, first_response_due_at)
  values (v_org_id, v_contact_id, v_lead_source_id, 'form', payload, now() + interval '15 minutes')
  returning id into v_lead_id;
  insert into public.inquiry_events (organization_id, lead_id, contact_id, source_type, event_type, raw_payload_json)
  values (v_org_id, v_lead_id, v_contact_id, 'form', 'form_submit', payload);
  return v_lead_id;
end;
$$;
