# Create profiles roles and permission sets

## Goal
Create the baseline access-control entities.

## Deliverables
- Create `profiles`, `roles`, `permission_sets`
- Add indexes and updated_at triggers

## Dependencies
- organizations table created

## Implementation Notes
- Profiles are baseline access templates.
- Roles drive hierarchy and visibility.
- Permission sets are additive.

## Acceptance Criteria
- Tables are queryable
- Foreign keys are valid
- Triggers update `updated_at`
