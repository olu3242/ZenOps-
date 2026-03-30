# Enable extensions

## Goal
Enable the base PostgreSQL extensions required by ZenOps.

## Deliverables
- Apply `001_extensions.sql`
- Confirm `pgcrypto`, `citext`, and `pg_trgm` are active

## Dependencies
- Supabase project created

## Implementation Notes
- Run this before any table migration.
- `citext` is used for case-insensitive email matching.

## Acceptance Criteria
- All three extensions are enabled successfully
- No migration errors
