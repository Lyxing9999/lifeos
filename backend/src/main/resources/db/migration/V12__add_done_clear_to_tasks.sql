ALTER TABLE tasks
    ADD COLUMN IF NOT EXISTS done_cleared_at TIMESTAMP WITH TIME ZONE;

ALTER TABLE task_completions
    ADD COLUMN IF NOT EXISTS cleared_at TIMESTAMP WITH TIME ZONE;

CREATE INDEX IF NOT EXISTS idx_tasks_user_done_cleared_at
    ON tasks(user_id, done_cleared_at);

CREATE INDEX IF NOT EXISTS idx_task_completions_user_date_cleared
    ON task_completions(user_id, completion_date, cleared_at);