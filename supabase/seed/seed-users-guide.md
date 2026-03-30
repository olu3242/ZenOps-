# Test Users Setup Guide

The test data includes an organization, teams, contacts, and leads. However, **users must be created separately** because they require entries in the `auth.users` table (managed by Supabase Authentication).

## Test User Accounts

Create the following users through the Supabase Dashboard or Admin API:

| Email              | Password | Role           | Organization  |
|--------------------|----------|----------------|----------------|
| admin@zenops.demo  | Test123! | Admin          | ZenOps Demo    |
| sales@zenops.demo  | Test123! | Sales Manager  | ZenOps Demo    |
| john@zenops.demo   | Test123! | Sales Rep      | ZenOps Demo    |
| support@zenops.demo| Test123! | Support Agent  | ZenOps Demo    |

## Setup Steps

### Option 1: Via Supabase Dashboard (Easiest)

1. Go to **Authentication > Users** in your Supabase project dashboard
2. Click **Add User**
3. For each user above:
   - Email: `<email@zenops.demo>`
   - Password: `Test123!`
   - Auto Confirm: ✓ (check if available)

### Option 2: Via Supabase Admin API

Use the Supabase Admin SDK with your admin credentials:

```typescript
import { createClient } from '@supabase/supabase-js'

const adminClient = createClient(
  'https://utxmazyyufvupeygmhpw.supabase.co',
  'YOUR_ADMIN_KEY', // Not the anon key
)

const users = [
  { email: 'admin@zenops.demo', password: 'Test123!' },
  { email: 'sales@zenops.demo', password: 'Test123!' },
  { email: 'john@zenops.demo', password: 'Test123!' },
  { email: 'support@zenops.demo', password: 'Test123!' },
]

for (const user of users) {
  const { data, error } = await adminClient.auth.admin.createUser({
    email: user.email,
    password: user.password,
    email_confirm: true,
  })
  console.log(data.user.id, data.user.email)
}
```

Capture the UUIDs returned and use them in the next step.

### Step 2: Insert Users into Public Schema

Once you have the auth user UUIDs, run this SQL in the Supabase SQL Editor:

```sql
-- Replace UUID values with actual auth.users IDs from step 1
INSERT INTO public.users (id, organization_id, team_id, profile_id, role_id, email, first_name, last_name, phone, job_title, status)
VALUES
  ('<admin_uuid>'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, '550e8400-e29b-41d4-a716-446655440001'::uuid, '550e8400-e29b-41d4-a716-446655440010'::uuid, '550e8400-e29b-41d4-a716-446655440020'::uuid, 'admin@zenops.demo', 'Admin', 'User', '+1-800-555-0101', 'Administrator', 'active'),
  ('<sales_uuid>'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, '550e8400-e29b-41d4-a716-446655440001'::uuid, '550e8400-e29b-41d4-a716-446655440011'::uuid, '550e8400-e29b-41d4-a716-446655440021'::uuid, 'sales@zenops.demo', 'Sarah', 'Sales', '+1-800-555-0102', 'Sales Manager', 'active'),
  ('<john_uuid>'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, '550e8400-e29b-41d4-a716-446655440001'::uuid, '550e8400-e29b-41d4-a716-446655440011'::uuid, '550e8400-e29b-41d4-a716-446655440022'::uuid, 'john@zenops.demo', 'John', 'Doe', '+1-800-555-0103', 'Sales Rep', 'active'),
  ('<support_uuid>'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, '550e8400-e29b-41d4-a716-446655440002'::uuid, '550e8400-e29b-41d4-a716-446655440012'::uuid, '550e8400-e29b-41d4-a716-446655440022'::uuid, 'support@zenops.demo', 'Jessica', 'Support', '+1-800-555-0104', 'Support Agent', 'active');
```

### Step 3: Seed Tasks and Opportunities

Once users are created, add tasks and opportunities with the user IDs:

**Run in SQL Editor:**

```sql
-- Insert test tasks
INSERT INTO public.tasks (id, organization_id, related_object_type, related_record_id, owner_user_id, created_by_user_id, task_type, priority, status, subject, description, due_at)
VALUES
  ('550e8400-e29b-41d4-a716-446655440700'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, 'lead', '550e8400-e29b-41d4-a716-446655440500'::uuid, '<john_uuid>'::uuid, '<sales_uuid>'::uuid, 'followup', 'high', 'open', 'Follow up with Michael Chen', 'Call to discuss demo requirements', now() + interval '1 day'),
  ('550e8400-e29b-41d4-a716-446655440701'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, 'lead', '550e8400-e29b-41d4-a716-446655440501'::uuid, '<sales_uuid>'::uuid, '<sales_uuid>'::uuid, 'meeting', 'high', 'open', 'Schedule call with Emma Johnson', 'Coordinate demo call time', now() + interval '2 days');

-- Insert test opportunities
INSERT INTO public.opportunities (id, organization_id, contact_id, account_id, owner_user_id, team_id, pipeline_id, current_stage_id, name, amount_estimated, expected_close_date, status, service_type)
VALUES
  ('550e8400-e29b-41d4-a716-446655440950'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, '550e8400-e29b-41d4-a716-446655440200'::uuid, '550e8400-e29b-41d4-a716-446655440100'::uuid, '<john_uuid>'::uuid, '550e8400-e29b-41d4-a716-446655440001'::uuid, '550e8400-e29b-41d4-a716-446655440900'::uuid, '550e8400-e29b-41d4-a716-446655440911'::uuid, 'Acme - Enterprise Plan', 25000.00, '2026-04-30', 'open', 'enterprise'),
  ('550e8400-e29b-41d4-a716-446655440951'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, '550e8400-e29b-41d4-a716-446655440201'::uuid, '550e8400-e29b-41d4-a716-446655440100'::uuid, '<sales_uuid>'::uuid, '550e8400-e29b-41d4-a716-446655440001'::uuid, '550e8400-e29b-41d4-a716-446655440900'::uuid, '550e8400-e29b-41d4-a716-446655440910'::uuid, 'Acme - Starter Plan', 5000.00, '2026-05-15', 'open', 'starter');
```

## Test Data Summary

After completion, you'll have:

- ✅ 1 Organization: "ZenOps Demo"
- ✅ 2 Teams: "Sales", "Support"
- ✅ 4 Users: Admin, Sales Manager, Sales Rep, Support Agent
- ✅ 1 Account: "Acme Corporation"
- ✅ 2 Contacts: Michael Chen, Emma Johnson
- ✅ 2 Leads: With form inquiry events from both contacts
- ✅ 3 Lead Sources: Website Form, Demo Request, Cold Call
- ✅ 2 Tasks: Followup with Michael, Meeting with Emma
- ✅ 2 Opportunities: Enterprise and Starter plans
- ✅ Sales Pipeline: With 6 stages (Prospecting → Closed Won/Lost)
- ✅ 3 Tags: VIP, Enterprise, SMB

## Reference UUIDs

```
Organization: 550e8400-e29b-41d4-a716-446655440000
Sales Team:   550e8400-e29b-41d4-a716-446655440001
Support Team: 550e8400-e29b-41d4-a716-446655440002
Acme Account: 550e8400-e29b-41d4-a716-446655440100
Michael (Contact): 550e8400-e29b-41d4-a716-446655440200
Emma (Contact):    550e8400-e29b-41d4-a716-446655440201
Lead 1: 550e8400-e29b-41d4-a716-446655440500
Lead 2: 550e8400-e29b-41d4-a716-446655440501
```

## Testing the Setup

Once users are created:

1. Log in with one of the test accounts to the app UI (if available)
2. Verify RLS policies work by checking data visibility per user/organization
3. Test the webhook functions (lead-intake, etc.) with the organization ID
4. Test role-based access control with different user roles
