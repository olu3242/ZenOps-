# Apply RLS policies

## Goal
Enable row-level security across tenant-owned tables.

## Deliverables
- Run `sql/policies/rls.sql`
- Verify table coverage

## Dependencies
- all core tables exist and helper functions compile

## Implementation Notes
- Apply in staging first.
- Test with at least two organizations and multiple roles.

## Acceptance Criteria
- Cross-tenant access is blocked
- Allowed access flows still work
