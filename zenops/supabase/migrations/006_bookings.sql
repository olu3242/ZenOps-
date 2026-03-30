-- ZenOps: 006_bookings.sql
create table if not exists public.appointments (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  contact_id uuid not null references public.contacts(id),
  lead_id uuid references public.leads(id),
  opportunity_id uuid,
  provider_user_id uuid references public.users(id),
  booked_by_user_id uuid references public.users(id),
  status text not null default 'scheduled',
  appointment_type text,
  start_at timestamptz not null,
  end_at timestamptz not null,
  location text,
  reminder_status text,
  no_show_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (end_at > start_at)
);
create index if not exists idx_appointments_org on public.appointments(organization_id, start_at);
create index if not exists idx_appointments_contact on public.appointments(contact_id);
create index if not exists idx_appointments_provider on public.appointments(provider_user_id, start_at);
drop trigger if exists trg_appointments_updated_at on public.appointments;
create trigger trg_appointments_updated_at before update on public.appointments for each row execute function public.set_updated_at();
create or replace function public.book_appointment(payload jsonb) returns uuid language plpgsql security definer as $$
declare v_appointment_id uuid;
begin
  insert into public.appointments (organization_id,contact_id,lead_id,opportunity_id,provider_user_id,booked_by_user_id,status,appointment_type,start_at,end_at,location)
  values ((payload ->> 'organization_id')::uuid,(payload ->> 'contact_id')::uuid,(payload ->> 'lead_id')::uuid,(payload ->> 'opportunity_id')::uuid,(payload ->> 'provider_user_id')::uuid,auth.uid(),coalesce(payload ->> 'status', 'scheduled'),payload ->> 'appointment_type',(payload ->> 'start_at')::timestamptz,(payload ->> 'end_at')::timestamptz,payload ->> 'location')
  returning id into v_appointment_id;
  return v_appointment_id;
end;
$$;
