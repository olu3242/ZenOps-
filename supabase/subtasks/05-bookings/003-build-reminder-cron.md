# Build reminder cron

## Goal
Prepare reminder jobs for upcoming appointments.

## Deliverables
- Edge function spec for reminder processing
- Scheduled invocation plan

## Dependencies
- appointments and communications model exist

## Implementation Notes
- Include idempotency so reminders are not sent twice.

## Acceptance Criteria
- A scheduled job can identify reminder-eligible appointments
