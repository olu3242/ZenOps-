# Build contact match function

## Goal
Match incoming submissions to existing contacts or create a new record.

## Deliverables
- Create `match_or_create_contact()`
- Add test cases for email and phone matching

## Dependencies
- contacts table exists

## Implementation Notes
- Prefer exact email/phone match initially.

## Acceptance Criteria
- Existing contact is reused when possible
- New contact is created otherwise
