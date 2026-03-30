# Build inbound webhook handlers

## Goal
Process inbound provider webhooks into the CRM and conversation model.

## Deliverables
- Edge functions for lead intake and missed-call handling
- Normalized payload mapping

## Dependencies
- leads, inquiry_events, conversations, and messages exist

## Implementation Notes
- Start with Twilio-compatible webhook payloads.

## Acceptance Criteria
- Missed calls create events and can trigger text-back workflows
