-- ZenOps: 012_seed_test_data.sql
-- Comprehensive test data for development and QA

-- Disable RLS temporarily for seeding (as superuser)
ALTER TABLE public.organizations DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.teams DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.roles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.accounts DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.contacts DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.lead_sources DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.campaigns DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.leads DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.inquiry_events DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.pipelines DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.pipeline_stages DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.opportunities DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.proposals DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.tags DISABLE ROW LEVEL SECURITY;

-- Insert test organization
INSERT INTO public.organizations (id, name, industry, timezone, subscription_plan, status, onboarding_status, default_currency)
VALUES ('550e8400-e29b-41d4-a716-446655440000'::uuid, 'ZenOps Demo', 'SaaS', 'America/New_York', 'starter', 'active', 'completed', 'USD');

-- Insert test teams
INSERT INTO public.teams (id, organization_id, name, description)
VALUES 
  ('550e8400-e29b-41d4-a716-446655440001'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, 'Sales', 'Sales team'),
  ('550e8400-e29b-41d4-a716-446655440002'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, 'Support', 'Customer support team');

-- Insert test profiles
INSERT INTO public.profiles (id, organization_id, name, license_type, is_system, is_active)
VALUES
  ('550e8400-e29b-41d4-a716-446655440010'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, 'Admin', 'standard', true, true),
  ('550e8400-e29b-41d4-a716-446655440011'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, 'Sales User', 'standard', false, true),
  ('550e8400-e29b-41d4-a716-446655440012'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, 'Support User', 'standard', false, true);

-- Insert test roles
INSERT INTO public.roles (id, organization_id, name, hierarchy_level, can_approve_proposals, can_manage_users, can_view_team_records)
VALUES
  ('550e8400-e29b-41d4-a716-446655440020'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, 'Admin', 0, true, true, true),
  ('550e8400-e29b-41d4-a716-446655440021'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, 'Sales Manager', 1, true, false, true),
  ('550e8400-e29b-41d4-a716-446655440022'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, 'Sales Rep', 2, false, false, false);

-- NOTE: Users require auth.users entries. They should be created via Supabase Admin API.
-- For testing, use: supabase/seed/seed-users.sql or create users via dashboard UI
-- Placeholder UUIDs for developers to reference:
-- Admin: 00000000-0000-0000-0000-000000000001 (admin@zenops.demo)
-- Sales Manager: 00000000-0000-0000-0000-000000000002 (sales@zenops.demo)
-- Sales Rep: 00000000-0000-0000-0000-000000000003 (john@zenops.demo)
-- Support: 00000000-0000-0000-0000-000000000004 (support@zenops.demo)

-- Users skipped: Insert actual auth users via Supabase Admin API first

-- Insert test account (owner_user_id will be set once users are created)
INSERT INTO public.accounts (id, organization_id, owner_user_id, name, industry, website, phone, status)
VALUES ('550e8400-e29b-41d4-a716-446655440100'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, NULL, 'Acme Corporation', 'Technology', 'www.acme.com', '+1-800-555-1000', 'active');

-- Insert test contacts (owner_user_id will be set once users are created)
INSERT INTO public.contacts (id, organization_id, account_id, owner_user_id, first_name, last_name, email, phone, lifecycle_status, source_primary)
VALUES
  ('550e8400-e29b-41d4-a716-446655440200'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, '550e8400-e29b-41d4-a716-446655440100'::uuid, NULL, 'Michael', 'Chen', 'michael.chen@acme.com', '+1-800-555-2000', 'active', 'website'),
  ('550e8400-e29b-41d4-a716-446655440201'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, '550e8400-e29b-41d4-a716-446655440100'::uuid, NULL, 'Emma', 'Johnson', 'emma.johnson@acme.com', '+1-800-555-2001', 'active', 'referral');

-- Insert test lead sources
INSERT INTO public.lead_sources (id, organization_id, name, type, platform, is_active)
VALUES
  ('550e8400-e29b-41d4-a716-446655440300'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, 'Website Form', 'inbound', 'web', true),
  ('550e8400-e29b-41d4-a716-446655440301'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, 'Demo Request', 'inquiry', 'web', true),
  ('550e8400-e29b-41d4-a716-446655440302'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, 'Cold Call', 'outbound', 'phone', true);

-- Insert test campaign (owner_user_id will be set once users are created)
INSERT INTO public.campaigns (id, organization_id, owner_user_id, name, type, status, start_date, goal)
VALUES ('550e8400-e29b-41d4-a716-446655440400'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, NULL, 'Q1 2026 Sales Push', 'email', 'active', '2026-01-01', '50 qualified leads');

-- Insert test leads (assigned_user_id will be set once users are created)
INSERT INTO public.leads (id, organization_id, contact_id, account_id, lead_source_id, assigned_user_id, campaign_id, team_id, status, qualification_status, urgency_score, source_channel, first_response_due_at, metadata)
VALUES
  ('550e8400-e29b-41d4-a716-446655440500'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, '550e8400-e29b-41d4-a716-446655440200'::uuid, '550e8400-e29b-41d4-a716-446655440100'::uuid, '550e8400-e29b-41d4-a716-446655440300'::uuid, NULL, '550e8400-e29b-41d4-a716-446655440400'::uuid, '550e8400-e29b-41d4-a716-446655440001'::uuid, 'new', 'unreviewed', 85, 'form', now() + interval '15 minutes', '{"source":"website_form","intent":"demo"}'::jsonb),
  ('550e8400-e29b-41d4-a716-446655440501'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, '550e8400-e29b-41d4-a716-446655440201'::uuid, '550e8400-e29b-41d4-a716-446655440100'::uuid, '550e8400-e29b-41d4-a716-446655440301'::uuid, NULL, '550e8400-e29b-41d4-a716-446655440400'::uuid, '550e8400-e29b-41d4-a716-446655440001'::uuid, 'new', 'unreviewed', 65, 'inquiry', now() + interval '15 minutes', '{"source":"demo_request","intent":"evaluation"}'::jsonb);

-- Insert inquiry events
INSERT INTO public.inquiry_events (id, organization_id, lead_id, contact_id, source_type, event_type, raw_payload_json)
VALUES
  ('550e8400-e29b-41d4-a716-446655440600'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, '550e8400-e29b-41d4-a716-446655440500'::uuid, '550e8400-e29b-41d4-a716-446655440200'::uuid, 'form', 'form_submit', '{"name":"Michael Chen","email":"michael.chen@acme.com","message":"interested in demo"}'::jsonb),
  ('550e8400-e29b-41d4-a716-446655440601'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, '550e8400-e29b-41d4-a716-446655440501'::uuid, '550e8400-e29b-41d4-a716-446655440201'::uuid, 'form', 'form_submit', '{"name":"Emma Johnson","email":"emma.johnson@acme.com","message":"want to schedule a call"}'::jsonb);

-- NOTE: Tasks require an owner_user_id (not nullable). Skipped until users are created.
-- Insert test tasks manually after creating users:
-- INSERT INTO public.tasks (id, organization_id, related_object_type, related_record_id, owner_user_id, created_by_user_id, task_type, priority, status, subject, description, due_at)
-- VALUES
--   ('550e8400-e29b-41d4-a716-446655440700'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, 'lead', '550e8400-e29b-41d4-a716-446655440500'::uuid, <user_id>, NULL, 'followup', 'high', 'open', 'Follow up with Michael Chen', 'Call to discuss demo requirements', now() + interval '1 day'),
--   ('550e8400-e29b-41d4-a716-446655440701'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, 'lead', '550e8400-e29b-41d4-a716-446655440501'::uuid, <user_id>, NULL, 'meeting', 'high', 'open', 'Schedule call with Emma Johnson', 'Coordinate demo call time', now() + interval '2 days');

-- Insert test tags
INSERT INTO public.tags (id, organization_id, name, color, is_active)
VALUES
  ('550e8400-e29b-41d4-a716-446655440800'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, 'VIP', '#ff0000', true),
  ('550e8400-e29b-41d4-a716-446655440801'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, 'Enterprise', '#0066cc', true),
  ('550e8400-e29b-41d4-a716-446655440802'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, 'SMB', '#00cc66', true);

-- Insert pipelines
INSERT INTO public.pipelines (id, organization_id, name, object_type, is_default, is_active)
VALUES ('550e8400-e29b-41d4-a716-446655440900'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, 'Standard Sales', 'opportunity', true, true);

-- Insert pipeline stages
INSERT INTO public.pipeline_stages (id, pipeline_id, name, sequence_order, probability_percent, stage_category)
VALUES
  ('550e8400-e29b-41d4-a716-446655440910'::uuid, '550e8400-e29b-41d4-a716-446655440900'::uuid, 'Prospecting', 1, 10, 'open'),
  ('550e8400-e29b-41d4-a716-446655440911'::uuid, '550e8400-e29b-41d4-a716-446655440900'::uuid, 'Qualification', 2, 25, 'open'),
  ('550e8400-e29b-41d4-a716-446655440912'::uuid, '550e8400-e29b-41d4-a716-446655440900'::uuid, 'Proposal', 3, 50, 'open'),
  ('550e8400-e29b-41d4-a716-446655440913'::uuid, '550e8400-e29b-41d4-a716-446655440900'::uuid, 'Negotiation', 4, 75, 'open'),
  ('550e8400-e29b-41d4-a716-446655440914'::uuid, '550e8400-e29b-41d4-a716-446655440900'::uuid, 'Closed Won', 5, 100, 'closed'),
  ('550e8400-e29b-41d4-a716-446655440915'::uuid, '550e8400-e29b-41d4-a716-446655440900'::uuid, 'Closed Lost', 6, 0, 'closed');

-- NOTE: Opportunities require an owner_user_id (not nullable). Skipped until users are created.
-- Insert opportunities manually after creating users:
-- INSERT INTO public.opportunities (id, organization_id, contact_id, account_id, owner_user_id, team_id, pipeline_id, current_stage_id, name, amount_estimated, expected_close_date, status, service_type)
-- VALUES
--   ('550e8400-e29b-41d4-a716-446655440950'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, '550e8400-e29b-41d4-a716-446655440200'::uuid, '550e8400-e29b-41d4-a716-446655440100'::uuid, <user_id>, '550e8400-e29b-41d4-a716-446655440001'::uuid, '550e8400-e29b-41d4-a716-446655440900'::uuid, '550e8400-e29b-41d4-a716-446655440911'::uuid, 'Acme - Enterprise Plan', 25000.00, '2026-04-30', 'open', 'enterprise'),
--   ('550e8400-e29b-41d4-a716-446655440951'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, '550e8400-e29b-41d4-a716-446655440201'::uuid, '550e8400-e29b-41d4-a716-446655440100'::uuid, <user_id>, '550e8400-e29b-41d4-a716-446655440001'::uuid, '550e8400-e29b-41d4-a716-446655440900'::uuid, '550e8400-e29b-41d4-a716-446655440910'::uuid, 'Acme - Starter Plan', 5000.00, '2026-05-15', 'open', 'starter');

-- Re-enable RLS
ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lead_sources ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.campaigns ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inquiry_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pipelines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pipeline_stages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.opportunities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.proposals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;
