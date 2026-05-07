ALTER TABLE users
    ADD COLUMN IF NOT EXISTS email_verified BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE users
    ADD COLUMN IF NOT EXISTS google_subject VARCHAR(120);

ALTER TABLE users
    ADD COLUMN IF NOT EXISTS picture_url VARCHAR(500);

CREATE UNIQUE INDEX IF NOT EXISTS ux_users_google_subject
    ON users(google_subject);