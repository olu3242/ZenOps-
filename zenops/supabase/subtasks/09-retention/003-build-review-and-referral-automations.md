# Build review and referral automations

## Goal
Send review asks and follow up with referral requests when appropriate.

## Deliverables
- Define post-service automation flows
- Log review request records

## Dependencies
- review_requests, referrals, automation engine exist

## Implementation Notes
- Avoid referral asks before a positive signal is captured.

## Acceptance Criteria
- Eligible service completion events can enqueue review or referral workflows
