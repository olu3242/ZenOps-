-- ZenOps: 010_retention_admin.sql
create table if not exists public.review_requests (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  contact_id uuid not null references public.contacts(id),
  opportunity_id uuid references public.opportunities(id),
  appointment_id uuid references public.appointments(id),
  sent_by_user_id uuid references public.users(id),
  status text not null default 'pending',
  channel text not null,
  requested_at timestamptz,
  completed_at timestamptz,
  rating_value integer,
  review_url text,
  created_at timestamptz not null default now()
);
create table if not exists public.referrals (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  referring_contact_id uuid not null references public.contacts(id),
  referred_contact_id uuid references public.contacts(id),
  converted_opportunity_id uuid references public.opportunities(id),
  status text not null default 'new',
  incentive_type text,
  created_at timestamptz not null default now()
);
create table if not exists public.integration_credentials (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  provider_name text not null,
  status text not null default 'disconnected',
  encrypted_secret_ref text,
  connected_by_user_id uuid references public.users(id),
  last_sync_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.custom_field_definitions (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  object_type text not null,
  field_name_api text not null,
  field_label text not null,
  data_type text not null,
  is_required boolean not null default false,
  help_text text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, object_type, field_name_api)
);
create table if not exists public.custom_field_values (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  custom_field_definition_id uuid not null references public.custom_field_definitions(id) on delete cascade,
  related_record_id uuid not null,
  value_text text,
  value_number numeric(18,4),
  value_boolean boolean,
  value_date date,
  value_json jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists idx_review_requests_org on public.review_requests(organization_id, status);
create index if not exists idx_referrals_org on public.referrals(organization_id, status);
create index if not exists idx_integration_credentials_org on public.integration_credentials(organization_id);
create index if not exists idx_custom_field_definitions_org on public.custom_field_definitions(organization_id, object_type);
create index if not exists idx_custom_field_values_org on public.custom_field_values(organization_id, custom_field_definition_id);
drop trigger if exists trg_integration_credentials_updated_at on public.integration_credentials;
create trigger trg_integration_credentials_updated_at before update on public.integration_credentials for each row execute function public.set_updated_at();
drop trigger if exists trg_custom_field_definitions_updated_at on public.custom_field_definitions;
create trigger trg_custom_field_definitions_updated_at before update on public.custom_field_definitions for each row execute function public.set_updated_at();
drop trigger if exists trg_custom_field_values_updated_at on public.custom_field_values;
create trigger trg_custom_field_values_updated_at before update on public.custom_field_values for each row execute function public.set_updated_at();
