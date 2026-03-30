# Create conversations

## Goal
Create the conversation wrapper for inbound and outbound communication.

## Deliverables
- Create `conversations`
- Add contact, lead, and optional opportunity lookups

## Dependencies
- contacts and leads exist

## Implementation Notes
- Keep `opportunity_id` nullable to support pre-sale threads.

## Acceptance Criteria
- Conversation records store channel and ownership cleanly
