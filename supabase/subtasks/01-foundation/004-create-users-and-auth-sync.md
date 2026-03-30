# Create users and auth sync

## Goal
Map Supabase Auth users into the public users table.

## Deliverables
- Create `users`
- Create `handle_new_auth_user()`
- Add auth.users trigger

## Dependencies
- profiles and roles created

## Implementation Notes
- Metadata must include organization_id, profile_id, and role_id during user provisioning.

## Acceptance Criteria
- New auth user inserts a row in `public.users`
- Duplicate insert is safely ignored
