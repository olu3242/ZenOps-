# Create tasks tags and record links

## Goal
Support operational follow-up and lightweight record labeling.

## Deliverables
- Create `tasks`, `tags`, and `record_tag_links`

## Dependencies
- users exist

## Implementation Notes
- `tasks` uses a polymorphic target pattern with `related_object_type` and `related_record_id`.

## Acceptance Criteria
- Tasks can point to multiple object types
- Tags can be attached to records
