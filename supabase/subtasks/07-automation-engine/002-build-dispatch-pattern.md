# Build dispatch pattern

## Goal
Route qualifying events into queued automation runs.

## Deliverables
- Create `enqueue_automation_run()`
- Define event producer points

## Dependencies
- automation tables exist

## Implementation Notes
- Begin with manual dispatch from app logic or edge functions.

## Acceptance Criteria
- Triggering logic can queue a run for a target record
