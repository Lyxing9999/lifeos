ALTER TABLE tasks
    ADD COLUMN IF NOT EXISTS achieved_date DATE;

ALTER TABLE tasks
    ADD COLUMN IF NOT EXISTS paused BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE tasks
    ADD COLUMN IF NOT EXISTS paused_at TIMESTAMP WITH TIME ZONE;

ALTER TABLE tasks
    ADD COLUMN IF NOT EXISTS pause_until DATE;

CREATE INDEX IF NOT EXISTS idx_tasks_user_achieved_date
    ON tasks(user_id, achieved_date);

CREATE INDEX IF NOT EXISTS idx_tasks_user_paused
    ON tasks(user_id, paused);