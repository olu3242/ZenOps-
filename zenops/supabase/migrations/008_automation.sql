-- ZenOps: 008_automation.sql
create table if not exists public.automation_rules (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  name text not null,
  object_type text not null,
  trigger_event text not null,
  entry_criteria_json jsonb not null default '{}'::jsonb,
  actions_json jsonb not null default '[]'::jsonb,
  is_active boolean not null default true,
  version_number integer not null default 1,
  created_by_user_id uuid references public.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.automation_runs (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  automation_rule_id uuid not null references public.automation_rules(id) on delete cascade,
  object_type text not null,
  record_id uuid not null,
  status text not null default 'queued',
  retry_count integer not null default 0,
  started_at timestamptz,
  completed_at timestamptz,
  error_message text,
  action_results_json jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
create index if not exists idx_automation_rules_org on public.automation_rules(organization_id, is_active);
create index if not exists idx_automation_runs_org_status on public.automation_runs(organization_id, status, created_at);
drop trigger if exists trg_automation_rules_updated_at on public.automation_rules;
create trigger trg_automation_rules_updated_at before update on public.automation_rules for each row execute function public.set_updated_at();
create or replace function public.enqueue_automation_run(rule_id uuid,p_object_type text,p_record_id uuid) returns uuid language plpgsql security definer as $$
declare v_org_id uuid; v_run_id uuid;
begin
  select organization_id into v_org_id from public.automation_rules where id = rule_id;
  insert into public.automation_runs (organization_id,automation_rule_id,object_type,record_id,status)
  values (v_org_id,rule_id,p_object_type,p_record_id,'queued') returning id into v_run_id;
  return v_run_id;
end;
$$;
