-- ZenOps: 009_revenue_reporting.sql
create table if not exists public.revenue_events (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  opportunity_id uuid not null references public.opportunities(id),
  contact_id uuid not null references public.contacts(id),
  account_id uuid references public.accounts(id),
  event_type text not null,
  amount numeric(12,2) not null,
  occurred_at timestamptz not null default now(),
  source_system text,
  external_reference text,
  created_at timestamptz not null default now()
);
create table if not exists public.source_attributions (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  opportunity_id uuid not null references public.opportunities(id) on delete cascade,
  lead_source_id uuid not null references public.lead_sources(id),
  campaign_id uuid references public.campaigns(id),
  attribution_model text not null,
  weight_percent numeric(5,2) not null,
  attributed_amount numeric(12,2),
  created_at timestamptz not null default now()
);
create index if not exists idx_revenue_events_org on public.revenue_events(organization_id, occurred_at desc);
create index if not exists idx_revenue_events_opp on public.revenue_events(opportunity_id);
create index if not exists idx_source_attributions_opp on public.source_attributions(opportunity_id);
create or replace function public.apply_default_attribution(p_opportunity_id uuid) returns void language plpgsql security definer as $$
declare v_org_id uuid; v_lead_source_id uuid;
begin
  select o.organization_id, l.lead_source_id into v_org_id, v_lead_source_id
  from public.opportunities o
  left join public.leads l on l.id = o.source_lead_id
  where o.id = p_opportunity_id;
  if v_lead_source_id is not null then
    insert into public.source_attributions (organization_id,opportunity_id,lead_source_id,attribution_model,weight_percent,attributed_amount)
    values (v_org_id,p_opportunity_id,v_lead_source_id,'first_touch',100.00,null);
  end if;
end;
$$;
create or replace function public.mark_opportunity_won(p_opportunity_id uuid, p_amount numeric) returns void language plpgsql security definer as $$
declare v_opp public.opportunities%rowtype;
begin
  select * into v_opp from public.opportunities where id = p_opportunity_id;
  if not found then raise exception 'Opportunity not found'; end if;
  update public.opportunities set status = 'won', amount_estimated = coalesce(p_amount, amount_estimated), updated_at = now() where id = p_opportunity_id;
  insert into public.revenue_events (organization_id,opportunity_id,contact_id,account_id,event_type,amount,occurred_at,source_system)
  values (v_opp.organization_id,v_opp.id,v_opp.contact_id,v_opp.account_id,'won',coalesce(p_amount, v_opp.amount_estimated, 0),now(),'zenops');
  perform public.apply_default_attribution(p_opportunity_id);
end;
$$;
