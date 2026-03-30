# Build opportunity won function

## Goal
Handle status update and revenue event creation together.

## Deliverables
- Create `mark_opportunity_won()`
- Invoke `apply_default_attribution()`

## Dependencies
- opportunities, revenue_events, source_attributions exist

## Implementation Notes
- Good candidate for audit logging as the next hardening step.

## Acceptance Criteria
- Marking an opportunity won inserts a corresponding revenue event
