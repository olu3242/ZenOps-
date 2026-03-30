# Create integration credentials

## Goal
Store provider connection metadata without storing secrets directly in plain text.

## Deliverables
- Create `integration_credentials`

## Dependencies
- organizations and users exist

## Implementation Notes
- `encrypted_secret_ref` should point to a secret manager reference rather than raw secret content.

## Acceptance Criteria
- Provider connection records can be created and updated
