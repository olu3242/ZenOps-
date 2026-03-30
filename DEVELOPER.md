# ZenOps Developer Documentation

## 📋 Project Overview

ZenOps is a **fully-featured CRM and Business Automation platform** built with:
- **Backend**: Supabase PostgreSQL + Deno Edge Functions
- **Frontend**: React 18 + TypeScript (Admin Dashboard)
- **Security**: Row-Level Security (RLS) policies for multi-tenant data isolation
- **Database**: 12 migrations covering schema, security, and seed data

## 🚀 Quick Start

### Prerequisites
- Node.js 16+ 
- Supabase CLI v2.75+
- Git
- PostgreSQL 13+ (local or use Supabase)

### 1. Setup Backend (Supabase)

```bash
cd c:\Cdev\ZenOps

# Install dependencies
npm install -g supabase

# Login to Supabase
supabase login

# Link to project
supabase link --project-ref utxmazyyufvupeygmhpw

# Deploy migrations
supabase db push --linked

# Deploy Edge Functions
supabase functions deploy
```

### 2. Seed Test Users

```bash
cd supabase/seed

# Set environment variables
export SUPABASE_ADMIN_KEY=your_admin_key_here

# Run user seeding script
node seed-users.js
```

### 3. Setup Frontend (Admin Dashboard)

```bash
cd admin

# Install dependencies
npm install

# Update .env with your Supabase keys
# REACT_APP_SUPABASE_URL=https://utxmazyyufvupeygmhpw.supabase.co
# REACT_APP_SUPABASE_ANON_KEY=your_anon_key

# Start dev server
npm start
```

Visit http://localhost:3000 and login with test credentials.

---

## 📚 API Documentation

### Authentication

**Endpoint**: `/auth/v1/token`

```bash
curl -X POST https://utxmazyyufvupeygmhpw.supabase.co/auth/v1/token \
  -H "Content-Type: application/json" \
  -d '{
    "email": "sales@zenops.demo",
    "password": "Test123!",
    "grant_type": "password"
  }'
```

**Response**:
```json
{
  "access_token": "eyJhbGc...",
  "refresh_token": "...",
  "user": {
    "id": "00000000-0000-0000-0000-000000000002",
    "email": "sales@zenops.demo"
  }
}
```

### Leads API

**Get All Leads** (RLS-filtered by user's organization):
```bash
curl -H "Authorization: Bearer {access_token}" \
  https://utxmazyyufvupeygmhpw.supabase.co/rest/v1/leads
```

**Get Lead by ID**:
```bash
curl -H "Authorization: Bearer {access_token}" \
  'https://utxmazyyufvupeygmhpw.supabase.co/rest/v1/leads?id=eq.550e8400-e29b-41d4-a716-446655440500'
```

**Create Lead via Webhook**:
```bash
curl -X POST https://utxmazyyufvupeygmhpw.supabase.co/functions/v1/lead-intake \
  -H "Content-Type: application/json" \
  -H "x-organization-id: 550e8400-e29b-41d4-a716-446655440000" \
  -d '{
    "name": "John Smith",
    "email": "john@example.com",
    "phone": "+1-800-555-1234",
    "message": "interested in demo",
    "source": "website_form"
  }'
```

### Contacts API

**Get All Contacts**:
```bash
curl -H "Authorization: Bearer {access_token}" \
  https://utxmazyyufvupeygmhpw.supabase.co/rest/v1/contacts
```

### Opportunities API

**Get All Opportunities**:
```bash
curl -H "Authorization: Bearer {access_token}" \
  https://utxmazyyufvupeygmhpw.supabase.co/rest/v1/opportunities
```

---

## 🔧 Edge Functions

All functions are Deno-based serverless functions deployed to Supabase.

### 1. lead-intake

**Purpose**: Webhook handler for form submissions

**Endpoint**: `POST /functions/v1/lead-intake`

**Headers**:
```
x-organization-id: UUID
```

**Body**:
```json
{
  "name": string,
  "email": string,
  "phone": string,
  "message": string,
  "source": "website_form" | "phone" | "referral"
}
```

**Returns**: Created lead ID

**RLS Policy**: Validates organization_id header

### 2. appointment-reminders

**Purpose**: Send reminders for upcoming appointments (cron job)

**Endpoint**: `POST /functions/v1/appointment-reminders`

**Triggers**: Scheduled nightly (or manual call)

**Logic**:
1. Query appointments in next 24 hours
2. Fetch contact & provider email
3. Send reminder notification
4. Update appointment.reminder_status

### 3. first-response-sla

**Purpose**: Monitor SLA compliance and escalate overdue leads

**Endpoint**: `POST /functions/v1/first-response-sla`

**Body**:
```json
{
  "organization_id": UUID
}
```

**Logic**:
1. Find leads without first_response past due date
2. Create escalation task (high priority)
3. Mark lead as 'flagged'
4. Return escalation count

### 4. missed-call-handler

**Purpose**: Create follow-up tasks for missed calls

**Endpoint**: `POST /functions/v1/missed-call-handler`

**Body**:
```json
{
  "organization_id": UUID,
  "contact_id": UUID,
  "provider_user_id": UUID,
  "ring_time_seconds": number
}
```

**Returns**: Created task ID

### 5. opportunity-won

**Purpose**: Record revenue events when deals close

**Endpoint**: `POST /functions/v1/opportunity-won`

**Body**:
```json
{
  "organization_id": UUID,
  "opportunity_id": UUID,
  "deal_value": number,
  "won_date": ISO8601 date string
}
```

### 6. proposal-followup

**Purpose**: Auto-generate follow-ups for stale proposals

**Endpoint**: `POST /functions/v1/proposal-followup`

**Logic**:
1. Query proposals sent 3+ days ago
2. Create normal-priority follow-up tasks
3. Return count

### 7. review-request

**Purpose**: Handle post-service review requests

**Endpoint**: `POST /functions/v1/review-request`

**Body**:
```json
{
  "organization_id": UUID,
  "contact_id": UUID,
  "service_type": string
}
```

### 8. role-access-refresh

**Purpose**: Hourly permission verification

**Endpoint**: `POST /functions/v1/role-access-refresh`

**Logic**:
1. Iterate all users in organization
2. Validate role & profile existence
3. Ensure permissions are current
4. Return health stats

---

## 🔐 Row-Level Security (RLS)

All tables have RLS policies enforcing organization-level data isolation.

### Core RLS Pattern

```sql
-- Example: Organization data visibility
CREATE POLICY org_select_organizations ON public.organizations
  FOR SELECT
  USING (
    auth.uid() = owner_user_id 
    OR is_org_owner() 
    OR current_user_organization_id() = id
  );
```

### Multi-Level Access Control

**Patterns used**:
1. **Direct org_id check**: `organization_id = current_user_organization_id()`
2. **Owner check**: `owner_user_id = auth.uid()`
3. **Admin override**: `is_org_owner()`
4. **Role-based**: `has_permission('read_org_records')`
5. **Nested relationship**: EXISTS subquery through foreign keys (for pipeline_stages, etc.)

### RLS Helper Functions

All defined in `migrations/003_security_access.sql`:

```sql
-- Get current user's organization
current_user_organization_id() → UUID

-- Check if user is org owner
is_org_owner() → BOOLEAN

-- Check if user has permission
has_permission(permission_name TEXT) → BOOLEAN

-- Get user's role
current_user_role() → UUID
```

---

## 📊 Database Schema

### Core Tables

**organizations** - Multi-tenant container
```sql
id, name, industry, timezone, subscription_plan, status, owner_user_id
```

**users** - Organization members with roles
```sql
id (fk: auth.users), organization_id, team_id, profile_id, role_id, email, first_name, last_name, status
```

**teams** - Organizational units
```sql
id, organization_id, name, description, manager_user_id
```

**roles** - Role hierarchy
```sql
id, organization_id, name, hierarchy_level, can_approve_proposals, can_manage_users, can_view_team_records
```

**leads** - Prospects in pipeline
```sql
id, organization_id, contact_id, account_id, assigned_user_id, status, qualification_status, urgency_score, first_response_due_at, metadata (JSON)
```

**contacts** - People entries
```sql
id, organization_id, account_id, first_name, last_name, email, phone, lifecycle_status
```

**accounts** - Companies/Organizations per lead
```sql
id, organization_id, name, industry, website, phone
```

**opportunities** - Deals in sales pipeline
```sql
id, organization_id, contact_id, account_id, owner_user_id, pipeline_id, current_stage_id, name, amount_estimated, expected_close_date, status
```

**tasks** - Action items
```sql
id, organization_id, related_object_type (lead|opportunity|contact), related_record_id, owner_user_id, task_type, priority, status, due_at, subject
```

**proposals** - Sales documents
```sql
id, organization_id, opportunity_id, contact_id, owner_user_id, status, sent_at, expires_at, total_amount
```

---

## 🧪 Testing Guide

### 1. Using Postman

Import the collection:
```bash
postman-collection.json
```

**Steps**:
1. Set variables in Postman UI:
   - `SUPABASE_URL`: https://utxmazyyufvupeygmhpw.supabase.co
   - `ANON_KEY`: Your anon key
   - `ACCESS_TOKEN`: (auto-populated from login call)

2. Run "Sign In" to get access token

3. Test endpoints in order:
   - Leads API
   - Contacts API
   - Opportunities API
   - Edge Functions

### 2. Using cURL

```bash
# Get token
TOKEN=$(curl -s -X POST https://utxmazyyufvupeygmhpw.supabase.co/auth/v1/token \
  -H "Content-Type: application/json" \
  -d '{"email":"sales@zenops.demo","password":"Test123!","grant_type":"password"}' \
  | jq -r '.access_token')

# Query leads
curl -H "Authorization: Bearer $TOKEN" \
  https://utxmazyyufvupeygmhpw.supabase.co/rest/v1/leads | jq
```

### 3. RLS Testing

Test that users only see their org's data:

```bash
# Login as sales rep
curl -X POST https://utxmazyyufvupeygmhpw.supabase.co/auth/v1/token \
  -H "Content-Type: application/json" \
  -d '{"email":"john@zenops.demo","password":"Test123!","grant_type":"password"}'

# Try to access another organization (should be blocked by RLS)
curl -H "Authorization: Bearer {token}" \
  'https://utxmazyyufvupeygmhpw.supabase.co/rest/v1/leads?organization_id=eq.different-org-id'
# Returns: 0 rows (RLS blocks)
```

### 4. Edge Function Testing

```bash
# Test lead-intake webhook
curl -X POST https://utxmazyyufvupeygmhpw.supabase.co/functions/v1/lead-intake \
  -H "Content-Type: application/json" \
  -H "x-organization-id: 550e8400-e29b-41d4-a716-446655440000" \
  -d '{
    "name": "Test Lead",
    "email": "test@example.com",
    "phone": "+1-800-555-0000",
    "message": "Test",
    "source": "website_form"
  }'
```

---

## 📁 Project Structure

```
zenops/
├── supabase/
│   ├── migrations/
│   │   ├── 001-010: Schema & security setup
│   │   ├── 011: RLS policies
│   │   └── 012: Seed data
│   ├── functions/
│   │   ├── lead-intake/
│   │   ├── appointment-reminders/
│   │   ├── first-response-sla/
│   │   ├── missed-call-handler/
│   │   ├── opportunity-won/
│   │   ├── proposal-followup/
│   │   ├── review-request/
│   │   └── role-access-refresh/
│   ├── sql/
│   │   ├── bootstrap/
│   │   ├── policies/
│   │   ├── rpc/ (Database functions)
│   │   └── views/
│   └── seed/
│       ├── seed.sql
│       ├── seed-users.js (Admin API)
│       └── seed-users-guide.md
├── admin/ (React frontend)
│   ├── src/
│   │   ├── context/ (Auth context)
│   │   ├── components/ (Layout, ProtectedRoute)
│   │   ├── pages/ (Dashboard, Leads, Contacts, Opportunities)
│   │   └── App.tsx
│   ├── package.json
│   └── .env
└── README.md (This file)
```

---

## 🔄 Development Workflow

### 1. Local Development

```bash
# Start Supabase locally
supabase start

# Deploy functions locally
supabase functions deploy --no-verify-jwt

# In another terminal, start admin dashboard
cd admin && npm start
```

### 2. Making Database Changes

```bash
# Create new migration
supabase migration new add_feature_name

# Edit the file in supabase/migrations/
# Then apply locally
supabase db push

# Once tested, push to production
supabase db push --linked
```

### 3. Updating Functions

```bash
# Edit supabase/functions/function-name/index.ts
# Test locally
supabase functions serve

# Deploy to production
supabase functions deploy function-name --linked
```

### 4. Commit & Push

```bash
git add .
git commit -m "feat: add new feature"
git push origin main
```

---

## 💡 Key Concepts

### Multi-Tenancy
- Each organization fully isolated via RLS
- Users only see their organization's data
- No cross-org data leakage

### Role-Based Access Control
- 3 levels: Admin, Sales Manager, Sales Rep
- Hierarchy system allows role inheritance
- Permissions validated at DB level via RLS

### Event-Driven Architecture
- Edge Functions triggered by webhooks
- Async processing of leads, follow-ups, reminders
- Audit trail via updated_at timestamps

### Real-Time Updates
- Supabase Realtime (optional) for live dashboards
- Webhook integrations for external systems

---

## 🐛 Troubleshooting

### "RLS denies access"
- Check user's organization_id matches record
- Verify user roles are assigned
- Check RLS policy logs: `SELECT * FROM pg_stat_user_tables WHERE schemaname = 'public'`

### "Column does not exist"
- Run `supabase db pull` to sync schema
- Check migration order (001-012)
- Verify function params match schema

### "Webhook not triggering"
- Verify organization_id header is present
- Check Edge Function logs: Supabase Dashboard → Functions
- Ensure payload matches expected schema

### "Auth token invalid"
- Tokens expire after 1 hour; use refresh token
- Check browser DevTools → Application → Cookies for session

---

## 📞 Support

For issues:
1. Check Supabase logs: Dashboard → Functions → Logs
2. Review database logs: SQL Editor → Query performance
3. Verify RLS policies: `SELECT * FROM pg_policies`
4. Test with Postman collection first before deploying frontend code

---

## 🚀 Deployment Checklist

- [ ] All migrations pushed to production
- [ ] Edge Functions deployed and tested
- [ ] RLS policies verified
- [ ] Test users created and validated
- [ ] Admin dashboard environment variables set
- [ ] API endpoints responding correctly
- [ ] Webhook handlers working end-to-end
- [ ] Database backups configured
- [ ] Monitoring/alerts set up

---

**Last Updated**: March 30, 2026  
**Version**: 1.0.0  
**Maintainer**: ZenOps Team
