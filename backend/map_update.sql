ALTER TABLE chatrooms
ADD COLUMN IF NOT EXISTS author_id UUID REFERENCES users(user_id);
