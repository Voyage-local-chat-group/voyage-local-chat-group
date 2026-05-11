ALTER TABLE users
ALTER COLUMN notifications_enabled SET DEFAULT TRUE;

UPDATE users
SET notifications_enabled = TRUE
WHERE notifications_enabled = FALSE;

CREATE TABLE IF NOT EXISTS notification_reads(
    user_id UUID NOT NULL,
    message_id UUID NOT NULL,
    read_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    PRIMARY KEY (user_id, message_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (message_id) REFERENCES messages(message_id)
);
