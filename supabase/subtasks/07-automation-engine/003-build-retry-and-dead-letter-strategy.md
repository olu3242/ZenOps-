# Build retry and dead letter strategy

## Goal
Prevent transient failures from silently dropping automation actions.

## Deliverables
- Document retry_count lifecycle
- Add dead-letter handling plan

## Dependencies
- automation_runs exists

## Implementation Notes
- Use exponential backoff in edge workers.

## Acceptance Criteria
- Failed runs can be retried and terminal failures are visible
