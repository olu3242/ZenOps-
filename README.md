# ZenOps - Complete CRM & Business Automation Platform

**Production-Ready SaaS Backend** | **React Admin Dashboard** | **8 Serverless Functions** | **Row-Level Security**

![Status](https://img.shields.io/badge/Status-Production%20Ready-brightgreen) ![Database](https://img.shields.io/badge/Database-PostgreSQL%2013%2B-blue) ![Functions](https://img.shields.io/badge/Functions-Deno%2FEdge-purple) ![Frontend](https://img.shields.io/badge/Frontend-React%2018-blueviolet)

## 🎯 What is ZenOps?

ZenOps is a **complete, production-ready CRM platform** built for SaaS companies. It includes:

- ✅ **Multi-tenant database** with 34 tables and 12 migrations
- ✅ **8 serverless Edge Functions** for automations and webhooks
- ✅ **Row-Level Security (RLS)** for organization-level data isolation
- ✅ **React admin dashboard** for leads, contacts, and opportunities
- ✅ **REST API** with role-based access control
- ✅ **Test data seeding** ready to go
- ✅ **Complete documentation** and Postman collection

## 🚀 Quick Start (5 minutes)

### 1. Clone & Setup Backend

```bash
cd c:\Cdev\ZenOps

# Link to Supabase project
supabase link --project-ref utxmazyyufvupeygmhpw

# Deploy all migrations (001-012)
supabase db push --linked

# Deploy Edge Functions
supabase functions deploy
```

### 2. Create Test Users

```bash
cd supabase/seed
export SUPABASE_ADMIN_KEY=your_admin_key_here
node seed-users.js
```

### 3. Run Admin Dashboard

```bash
cd admin
npm install
npm start
```

Visit **http://localhost:3000**  
Login: `sales@zenops.demo` / `Test123!`

## 📊 Architecture Overview

### Database (PostgreSQL)
- **12 migrations** with 1,500+ lines of SQL
- **34 tables** covering CRM, automation, revenue, retention
- **Row-Level Security** policies on every table
- **Helper functions** for permission checking and org isolation

### Edge Functions (Deno)
1. **lead-intake** - Form webhook handler
2. **appointment-reminders** - Scheduled notification sender
3. **first-response-sla** - SLA monitoring & escalation
4. **missed-call-handler** - Follow-up task creator
5. **opportunity-won** - Revenue event tracker
6. **proposal-followup** - Auto-follow-up generator
7. **review-request** - Feedback request handler
8. **role-access-refresh** - Permission validator

### Frontend (React 18)
- **Login page** - Secure auth with Supabase
- **Dashboard** - Real-time stats (leads, contacts, opps, tasks)
- **Leads page** - Prospect management
- **Contacts page** - CRM contact directory
- **Opportunities page** - Sales pipeline view

## 📁 Project Structure

```
zenops/
├── supabase/
│   ├── migrations/
│   │   ├── 001_extensions.sql
│   │   ├── 002_foundation_tables.sql
│   │   ├── 003_security_access.sql
│   │   ├── 004_crm_core.sql
│   │   ├── 005_communications.sql
│   │   ├── 006_bookings.sql
│   │   ├── 007_sales.sql
│   │   ├── 008_automation.sql
│   │   ├── 009_revenue_reporting.sql
│   │   ├── 010_retention_admin.sql
│   │   ├── 011_rls_policies.sql
│   │   └── 012_seed_test_data.sql
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
│   │   ├── rpc/
│   │   └── views/
│   └── seed/
│       ├── seed.sql
│       ├── seed-users.js
│       └── seed-users-guide.md
├── admin/
│   ├── src/
│   │   ├── context/
│   │   ├── components/
│   │   ├── pages/
│   │   └── App.tsx
│   └── package.json
├── postman-collection.json
├── DEVELOPER.md
└── README.md (this file)
```

## 🔐 Security Features

### Row-Level Security (RLS)
- ✅ Organization-level data isolation
- ✅ Role-based access control (3 tiers)
- ✅ Permission checking at DB level
- ✅ 60+ RLS policies across all tables

### Authentication
- ✅ JWT-based auth (Supabase Auth)
- ✅ Token refresh mechanism
- ✅ Secure session management
- ✅ Email/password login

## 📡 API Reference

### Database Queries (REST API)

**Get Leads** (auto-filtered by RLS)
```bash
curl -H "Authorization: Bearer {token}" \
  https://utxmazyyufvupeygmhpw.supabase.co/rest/v1/leads
```

**Get Contacts**
```bash
curl -H "Authorization: Bearer {token}" \
  https://utxmazyyufvupeygmhpw.supabase.co/rest/v1/contacts
```

### Webhooks (Edge Functions)

**Submit a Lead**
```bash
curl -X POST https://utxmazyyufvupeygmhpw.supabase.co/functions/v1/lead-intake \
  -H "Content-Type: application/json" \
  -H "x-organization-id: 550e8400-e29b-41d4-a716-446655440000" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+1-800-555-1234",
    "message": "Interested in demo",
    "source": "website_form"
  }'
```

See **[DEVELOPER.md](./DEVELOPER.md)** for full API documentation.

## 🧪 Test Data Included

Pre-seeded (migration 012):
- 1 organization (ZenOps Demo)
- 2 teams (Sales, Support)
- 3 roles (Admin, Manager, Rep)
- 2 contacts (Michael Chen, Emma Johnson)
- 2 leads with forms
- 1 account (Acme Corporation)
- 2 opportunities ($5K and $25K)
- 3 lead sources
- Sales pipeline (6 stages)

### Test User Accounts

Create via `supabase/seed/seed-users.js`:

| Email | Role | Password |
|-------|------|----------|
| admin@zenops.demo | Admin | Test123! |
| sales@zenops.demo | Sales Manager | Test123! |
| john@zenops.demo | Sales Rep | Test123! |
| support@zenops.demo | Support Agent | Test123! |

## 📖 Documentation

- **[DEVELOPER.md](./DEVELOPER.md)** - Full technical docs, API reference, troubleshooting
- **[supabase/seed/seed-users-guide.md](./supabase/seed/seed-users-guide.md)** - User creation guide
- **[postman-collection.json](./postman-collection.json)** - Postman API tests
- **Function docs** - See `supabase/functions/*/README.md`

## 🔄 Development Workflow

### Local Setup
```bash
# Start Supabase locally
supabase start

# Deploy functions locally
supabase functions serve

# Start dashboard
cd admin && npm start
```

### Making Changes
```bash
# Edit migrations or functions
vim supabase/migrations/new_feature.sql

# Test locally
supabase db push

# Deploy to production
supabase db push --linked

# Commit changes
git add . && git commit -m "feat: ..."
git push origin main
```

## ✅ Execution Order (Auto-Applied)

Supabase CLI applies migrations in order:

1. ✅ 001_extensions.sql - PostgreSQL extensions
2. ✅ 002_foundation_tables.sql - Orgs, users, teams, roles
3. ✅ 003_security_access.sql - RLS helpers & auth functions
4. ✅ 004_crm_core.sql - Leads, contacts, accounts, campaigns
5. ✅ 005_communications.sql - Messages, calls, conversations
6. ✅ 006_bookings.sql - Appointments, reminders
7. ✅ 007_sales.sql - Pipelines, opportunities, proposals
8. ✅ 008_automation.sql - Rules, workflows
9. ✅ 009_revenue_reporting.sql - Events, forecasts
10. ✅ 010_retention_admin.sql - Retention, settings
11. ✅ 011_rls_policies.sql - Row-level security (60+ policies)
12. ✅ 012_seed_test_data.sql - Test data

## 🧩 Key Concepts

### Multi-Tenancy
Each organization is fully isolated:
- Users only see their org's data
- RLS prevents cross-org leakage
- No application-level permission checks needed

### Role Hierarchy
Three-tier access model:
- **Admin** - Full org access, user management
- **Manager** - Team-level access, approvals
- **Rep** - Own record access only

### Event-Driven Architecture
Async processing via Edge Functions:
- Lead form → Webhook → Lead intake function
- Lead created → Automation rules → Tasks generated
- Opportunity won → Revenue event → Forecast updated

## 🚀 Production Deployment

### Prerequisites
- Supabase project created
- Admin API key available
- PostgreSQL 13+
- Deno runtime (for functions)

### Deployment Steps
```bash
# 1. Authenticate
supabase login

# 2. Link project
supabase link --project-ref your_project_ref

# 3. Push migrations
supabase db push --linked

# 4. Deploy functions
supabase functions deploy

# 5. Create users
cd supabase/seed && node seed-users.js

# 6. Deploy dashboard (e.g., Vercel)
cd admin && npm run build && vercel deploy --prod
```

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| "RLS denies access" | Check user's organization_id |
| "Column doesn't exist" | Run `supabase db pull` |
| "Function not found" | Deploy with `supabase functions deploy --linked` |
| "Auth failed" | Verify test user exists and credentials are correct |

See **[DEVELOPER.md](./DEVELOPER.md#-troubleshooting)** for detailed guide.

## 💡 Features Implemented

- [x] Multi-tenant PostgreSQL schema
- [x] Row-Level Security policies
- [x] 8 production-ready Edge Functions
- [x] User authentication system
- [x] Role-based access control
- [x] Lead management
- [x] Contact & account CRM
- [x] Sales pipeline
- [x] Task automation
- [x] Revenue tracking
- [x] Admin dashboard (React)
- [x] REST API documentation
- [x] Postman collection
- [x] Test data seeding

## 📞 Next Steps

1. **Read [DEVELOPER.md](./DEVELOPER.md)** - Full technical documentation
2. **Create test users**: `cd supabase/seed && node seed-users.js`
3. **Start dashboard**: `cd admin && npm start`
4. **Import Postman**: Use `postman-collection.json` to test APIs
5. **Review migrations**: Check `supabase/migrations/` to understand schema

## 📄 Notes

- This is a production-ready starter pack for SaaS CRMs
- All migrations auto-apply in dependency order
- RLS enforces security at DB level (not app level)
- Test users created via Supabase Admin API (see seed guide)
- Edge Functions use Deno runtime with Supabase SDK

---

**Status**: ✅ Production Ready  
**Last Updated**: March 30, 2026  
**Version**: 1.0.0  
**Built with**: Supabase + Deno + React 18 + PostgreSQL

Let's build something amazing! 🚀
