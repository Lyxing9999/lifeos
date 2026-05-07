
ALTER TABLE schedule_blocks ADD COLUMN archived BOOLEAN NOT NULL DEFAULT FALSE;

CREATE INDEX idx_schedule_user_archived ON schedule_blocks(user_id, archived);