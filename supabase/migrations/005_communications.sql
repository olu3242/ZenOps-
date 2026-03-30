-- ZenOps: 005_communications.sql
create table if not exists public.conversations (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  contact_id uuid not null references public.contacts(id),
  lead_id uuid references public.leads(id),
  opportunity_id uuid,
  owner_user_id uuid references public.users(id),
  channel_type text not null,
  status text not null default 'open',
  last_message_at timestamptz,
  ai_summary text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  sender_type text not null,
  sender_user_id uuid references public.users(id),
  direction text not null,
  channel text not null,
  content text not null,
  template_key text,
  delivery_status text,
  sent_at timestamptz,
  read_at timestamptz,
  ai_intent text,
  ai_sentiment text,
  created_at timestamptz not null default now()
);
create table if not exists public.call_logs (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id),
  contact_id uuid not null references public.contacts(id),
  lead_id uuid references public.leads(id),
  opportunity_id uuid,
  conversation_id uuid references public.conversations(id),
  owner_user_id uuid references public.users(id),
  direction text not null,
  outcome text,
  duration_seconds integer,
  recording_url text,
  transcript text,
  ai_summary text,
  started_at timestamptz not null,
  ended_at timestamptz,
  created_at timestamptz not null default now()
);
create index if not exists idx_conversations_org on public.conversations(organization_id);
create index if not exists idx_conversations_contact on public.conversations(contact_id);
create index if not exists idx_messages_conversation on public.messages(conversation_id, created_at desc);
create index if not exists idx_call_logs_contact on public.call_logs(contact_id, started_at desc);
drop trigger if exists trg_conversations_updated_at on public.conversations;
create trigger trg_conversations_updated_at before update on public.conversations for each row execute function public.set_updated_at();
