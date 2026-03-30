# Create leads and inquiry events

## Goal
Capture inbound interest and preserve the raw event ledger.

## Deliverables
- Create `leads` and `inquiry_events`
- Add assignment and SLA fields

## Dependencies
- contacts, lead_sources, campaigns exist

## Implementation Notes
- `contact_id` remains nullable until match/merge happens.

## Acceptance Criteria
- Form leads insert successfully
- Inquiry events persist raw payloads
