-- ZenOps: 007_sales.sql
create table if not exists public.pipelines (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  name text not null,
  object_type text not null,
  is_default boolean not null default false,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.pipeline_stages (
  id uuid primary key default gen_random_uuid(),
  pipeline_id uuid not null references public.pipelines(id) on delete cascade,
  name text not null,
  sequence_order integer not null,
  probability_percent integer not null default 0,
  stage_category text not null default 'open',
  sla_hours integer,
  is_active boolean not null default true,
  unique (pipeline_id, sequence_order)
);
create table if not exists public.opportunities (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  contact_id uuid not null references public.contacts(id),
  account_id uuid references public.accounts(id),
  source_lead_id uuid references public.leads(id),
  owner_user_id uuid not null references public.users(id),
  team_id uuid references public.teams(id),
  pipeline_id uuid not null references public.pipelines(id),
  current_stage_id uuid not null references public.pipeline_stages(id),
  name text not null,
  amount_estimated numeric(12,2),
  expected_close_date date,
  status text not null default 'open',
  service_type text,
  priority text,
  loss_reason text,
  win_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
do $$ begin if not exists (select 1 from pg_constraint where conname = 'leads_converted_opportunity_fk') then alter table public.leads add constraint leads_converted_opportunity_fk foreign key (converted_opportunity_id) references public.opportunities(id); end if; end $$;
create table if not exists public.proposals (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  opportunity_id uuid not null references public.opportunities(id) on delete cascade,
  contact_id uuid not null references public.contacts(id),
  owner_user_id uuid not null references public.users(id),
  status text not null default 'draft',
  version_number integer not null default 1,
  total_amount numeric(12,2),
  sent_at timestamptz,
  viewed_at timestamptz,
  accepted_at timestamptz,
  rejected_at timestamptz,
  expiration_date date,
  public_link_token text unique,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.proposal_items (
  id uuid primary key default gen_random_uuid(),
  proposal_id uuid not null references public.proposals(id) on delete cascade,
  product_name text not null,
  description text,
  quantity numeric(12,2) not null default 1,
  unit_price numeric(12,2) not null default 0,
  line_total numeric(12,2) generated always as (quantity * unit_price) stored
);
create index if not exists idx_pipelines_org on public.pipelines(organization_id);
create index if not exists idx_opportunities_org on public.opportunities(organization_id);
create index if not exists idx_opportunities_owner on public.opportunities(owner_user_id);
create index if not exists idx_opportunities_stage on public.opportunities(current_stage_id);
create index if not exists idx_proposals_opportunity on public.proposals(opportunity_id);
drop trigger if exists trg_pipelines_updated_at on public.pipelines;
create trigger trg_pipelines_updated_at before update on public.pipelines for each row execute function public.set_updated_at();
drop trigger if exists trg_opportunities_updated_at on public.opportunities;
create trigger trg_opportunities_updated_at before update on public.opportunities for each row execute function public.set_updated_at();
drop trigger if exists trg_proposals_updated_at on public.proposals;
create trigger trg_proposals_updated_at before update on public.proposals for each row execute function public.set_updated_at();
create or replace function public.convert_lead_to_opportunity(p_lead_id uuid, p_owner_user_id uuid) returns uuid language plpgsql security definer as $$
declare v_lead public.leads%rowtype; v_pipeline_id uuid; v_stage_id uuid; v_opp_id uuid;
begin
  select * into v_lead from public.leads where id = p_lead_id;
  if not found then raise exception 'Lead not found'; end if;
  select p.id into v_pipeline_id from public.pipelines p where p.organization_id = v_lead.organization_id and p.object_type = 'opportunity' and p.is_default = true limit 1;
  select ps.id into v_stage_id from public.pipeline_stages ps where ps.pipeline_id = v_pipeline_id order by ps.sequence_order asc limit 1;
  insert into public.opportunities (organization_id,contact_id,account_id,source_lead_id,owner_user_id,team_id,pipeline_id,current_stage_id,name,status)
  values (v_lead.organization_id,coalesce(v_lead.contact_id, v_lead.converted_contact_id),v_lead.account_id,v_lead.id,p_owner_user_id,v_lead.team_id,v_pipeline_id,v_stage_id,'Opportunity from Lead ' || v_lead.id::text,'open')
  returning id into v_opp_id;
  update public.leads set converted_opportunity_id = v_opp_id, status = 'converted', updated_at = now() where id = p_lead_id;
  return v_opp_id;
end;
$$;
