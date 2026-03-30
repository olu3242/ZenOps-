# Build booking RPC

## Goal
Expose a secure booking entry point through a database function.

## Deliverables
- Create `book_appointment(payload jsonb)`

## Dependencies
- appointments table exists

## Implementation Notes
- Validate `end_at > start_at` at table and app level.

## Acceptance Criteria
- Function inserts a valid appointment and returns its id
