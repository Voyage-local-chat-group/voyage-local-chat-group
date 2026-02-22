-- Query to list message count per joined chatroom
SELECT
    c.chatroom_name AS "Chatroom",
    COUNT(m.message_id) AS "Messages"
FROM
    users u
    JOIN chatroom_memberships cm ON u.user_id = cm.user_id
    JOIN chatrooms c ON cm.chatroom_id = c.chatroom_id
    JOIN messages m ON c.chatroom_id = m.chatroom_id
WHERE
    u.user_id = $user
GROUP BY c.chatroom_id;