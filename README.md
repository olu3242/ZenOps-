# ZenOps Supabase Build Package

## Execution order
1. migrations/001_extensions.sql
2. migrations/002_foundation_tables.sql
3. migrations/003_security_access.sql
4. migrations/004_crm_core.sql
5. migrations/005_communications.sql
6. migrations/006_bookings.sql
7. migrations/007_sales.sql
8. migrations/008_automation.sql
9. migrations/009_revenue_reporting.sql
10. migrations/010_retention_admin.sql
11. seed/seed.sql
12. sql/policies/rls.sql
13. sql/views/views.sql
14. sql/rpc/functions.sql

## Notes
- This is a practical starter pack for ZenOps.
- Apply RLS only after validating helper functions and seed users.
- Review indexes, audit coverage, and provider secret handling before production.
