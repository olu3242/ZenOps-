# Build user permission assignments

## Goal
Support additive permissions by assigning permission sets to users.

## Deliverables
- Create `user_permission_assignments`
- Add uniqueness constraint

## Dependencies
- users and permission_sets exist

## Implementation Notes
- Keep assignment history via `assigned_by_user_id` and `assigned_at`.

## Acceptance Criteria
- Duplicate assignment is blocked
- Valid assignments insert successfully
