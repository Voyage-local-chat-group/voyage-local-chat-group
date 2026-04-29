CREATE TYPE account_status_enum AS ENUM ('Online', 'Away', 'Do Not Disturb','Offline');
CREATE TABLE users(
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(25) NOT NULL,
    password_hash TEXT NOT NULL,
    avatar_url TEXT NOT NULL DEFAULT 'profile-pictures/default.png',
    bio VARCHAR(150),
    account_status account_status_enum NOT NULL DEFAULT 'Online',
    age_verified BOOLEAN NOT NULL DEFAULT FALSE,
    show_online_status BOOLEAN NOT NULL DEFAULT TRUE,
    notifications_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE user_blocks(
    blocker_id UUID NOT NULL,
    blocked_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    PRIMARY KEY (blocker_id, blocked_id),
    FOREIGN KEY (blocker_id) REFERENCES users(user_id),
    FOREIGN KEY (blocked_id) REFERENCES users(user_id)
);

CREATE TYPE chatroom_type_enum AS ENUM ('Private Group','Direct Message','Locational Chatroom');
CREATE TABLE chatrooms(
    chatroom_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chatroom_type chatroom_type_enum NOT NULL,
    chatroom_name VARCHAR(64) NOT NULL,
    coords_bottom_right CHAR(64),
    coords_top_left CHAR(64)
    author_id UUID,
    FOREIGN KEY (author_id) REFERENCES users(user_id)
);

CREATE TABLE chatroom_memberships(
    user_id UUID NOT NULL,
    chatroom_id UUID NOT NULL,
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    left_at TIMESTAMPTZ,

    PRIMARY KEY (user_id,chatroom_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (chatroom_id) REFERENCES chatrooms(chatroom_id)
);

CREATE TABLE messages(
    message_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chatroom_id UUID NOT NULL,
    sender_id UUID NOT NULL,
    content TEXT,
    sent_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    edited_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,

    FOREIGN KEY (chatroom_id) REFERENCES chatrooms(chatroom_id),
    FOREIGN KEY (sender_id) REFERENCES users(user_id)
);

CREATE TABLE attachments(
    attachment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID NOT NULL,
    file_url TEXT NOT NULL,

    FOREIGN KEY (message_id) REFERENCES messages(message_id)
);


CREATE TYPE report_type_enum AS ENUM ('User','Chatroom');
CREATE TABLE message_reports(
    report_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID NOT NULL,
    message_id UUID NOT NULL,
    report_type report_type_enum NOT NULL,
    content TEXT NOT NULL,

    FOREIGN KEY (sender_id) REFERENCES users(user_id),
    FOREIGN KEY (message_id) REFERENCES messages(message_id)
);

CREATE TABLE message_mentions(
    message_id UUID NOT NULL,
    mentioned_user UUID NOT NULL,

    PRIMARY KEY (message_id,mentioned_user),
    FOREIGN KEY (message_id) REFERENCES messages(message_id),
    FOREIGN KEY (mentioned_user) REFERENCES users(user_id)
);

CREATE TABLE dm_requests(
    request_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chatroom_id UUID NOT NULL,
    sender UUID NOT NULL,
    recipient UUID NOT NULL,

    FOREIGN KEY (chatroom_id) REFERENCES chatrooms(chatroom_id),
    FOREIGN KEY (sender) REFERENCES users(user_id),
    FOREIGN KEY (recipient) REFERENCES users(user_id)
);