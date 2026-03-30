# Build lead conversion RPC

## Goal
Convert qualified leads into opportunities using a controlled function.

## Deliverables
- Create `convert_lead_to_opportunity()`
- Update source lead with converted opportunity id

## Dependencies
- opportunities, pipelines, stages exist

## Implementation Notes
- Default into the first stage of the default opportunity pipeline.

## Acceptance Criteria
- Conversion returns an opportunity id and marks the lead converted
