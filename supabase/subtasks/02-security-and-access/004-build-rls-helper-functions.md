# Build RLS helper functions

## Goal
Create helper functions used by row-level security policies.

## Deliverables
- `current_user_id()`
- `current_user_organization_id()`
- `current_user_role_id()`
- `current_user_profile_id()`
- `is_org_owner()`
- `has_permission()`
- `can_view_team_record()`

## Dependencies
- users table exists

## Implementation Notes
- Keep helpers stable and side-effect free.

## Acceptance Criteria
- All helper functions compile
- Helpers return expected values
