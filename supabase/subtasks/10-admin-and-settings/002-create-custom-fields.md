# Create custom fields

## Goal
Support organization-defined fields without altering base tables.

## Deliverables
- Create `custom_field_definitions` and `custom_field_values`

## Dependencies
- organizations exist

## Implementation Notes
- This uses a polymorphic target pattern through `related_record_id`.

## Acceptance Criteria
- Orgs can define custom fields and save values against records
