-- ZenOps: 002_foundation_tables.sql

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  industry text,
  timezone text not null default 'UTC',
  subscription_plan text not null default 'starter',
  status text not null default 'active',
  onboarding_status text not null default 'pending',
  default_currency text not null default 'USD',
  owner_user_id uuid,
  settings jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.teams (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  name text not null,
  description text,
  manager_user_id uuid,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.profiles (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid references public.organizations(id),
  name text not null,
  description text,
  license_type text not null default 'standard',
  is_system boolean not null default false,
  is_active boolean not null default true,
  object_permissions jsonb not null default '{}'::jsonb,
  field_permissions jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.roles (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  name text not null,
  parent_role_id uuid references public.roles(id),
  hierarchy_level integer not null default 0,
  can_approve_proposals boolean not null default false,
  can_manage_users boolean not null default false,
  can_view_team_records boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.permission_sets (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid references public.organizations(id),
  name text not null,
  description text,
  permissions_json jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  organization_id uuid not null references public.organizations(id),
  team_id uuid references public.teams(id),
  profile_id uuid not null references public.profiles(id),
  role_id uuid not null references public.roles(id),
  email citext not null unique,
  first_name text not null,
  last_name text not null,
  phone text,
  job_title text,
  status text not null default 'active',
  locale text,
  avatar_url text,
  last_login_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'organizations_owner_user_fk') then
    alter table public.organizations add constraint organizations_owner_user_fk foreign key (owner_user_id) references public.users(id);
  end if;
end $$;

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'teams_manager_user_fk') then
    alter table public.teams add constraint teams_manager_user_fk foreign key (manager_user_id) references public.users(id);
  end if;
end $$;

create table if not exists public.user_permission_assignments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  permission_set_id uuid not null references public.permission_sets(id) on delete cascade,
  assigned_by_user_id uuid references public.users(id),
  assigned_at timestamptz not null default now(),
  unique (user_id, permission_set_id)
);

create table if not exists public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  user_id uuid references public.users(id),
  object_type text not null,
  record_id uuid,
  action_type text not null,
  field_name text,
  old_value_json jsonb,
  new_value_json jsonb,
  context_json jsonb not null default '{}'::jsonb,
  occurred_at timestamptz not null default now(),
  ip_address inet
);

create index if not exists idx_teams_org on public.teams(organization_id);
create index if not exists idx_profiles_org on public.profiles(organization_id);
create index if not exists idx_roles_org on public.roles(organization_id);
create index if not exists idx_permission_sets_org on public.permission_sets(organization_id);
create index if not exists idx_users_org on public.users(organization_id);
create index if not exists idx_users_team on public.users(team_id);
create index if not exists idx_users_role on public.users(role_id);
create index if not exists idx_audit_logs_org on public.audit_logs(organization_id, occurred_at desc);

drop trigger if exists trg_organizations_updated_at on public.organizations;
create trigger trg_organizations_updated_at before update on public.organizations for each row execute function public.set_updated_at();
drop trigger if exists trg_teams_updated_at on public.teams;
create trigger trg_teams_updated_at before update on public.teams for each row execute function public.set_updated_at();
drop trigger if exists trg_profiles_updated_at on public.profiles;
create trigger trg_profiles_updated_at before update on public.profiles for each row execute function public.set_updated_at();
drop trigger if exists trg_roles_updated_at on public.roles;
create trigger trg_roles_updated_at before update on public.roles for each row execute function public.set_updated_at();
drop trigger if exists trg_permission_sets_updated_at on public.permission_sets;
create trigger trg_permission_sets_updated_at before update on public.permission_sets for each row execute function public.set_updated_at();
drop trigger if exists trg_users_updated_at on public.users;
create trigger trg_users_updated_at before update on public.users for each row execute function public.set_updated_at();
