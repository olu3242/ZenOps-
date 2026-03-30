# Create organizations and teams

## Goal
Create the tenant root and team routing structure.

## Deliverables
- Apply the relevant sections of `002_foundation_tables.sql`
- Validate `organizations` and `teams` tables

## Dependencies
- 001-enable-extensions complete

## Implementation Notes
- Keep tenant ownership explicit with `organization_id`.
- Do not add cascade deletes from organizations.

## Acceptance Criteria
- Tables exist
- Indexes exist
- `updated_at` triggers work
