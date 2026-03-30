# Build audit log admin view

## Goal
Expose audit history safely for admins.

## Deliverables
- Admin query/view for `audit_logs`
- UI contract for filters

## Dependencies
- audit_logs and permission model exist

## Implementation Notes
- Restrict access to admins and users with `view_audit_logs`.

## Acceptance Criteria
- Admins can filter audit history by object type, record id, action, and user
