# Backend API for the Voyage chat app.
from flask import *
from flask_restx import Api, Resource
import os
from database_connector import queryDB, executeOnDB
import jwt
import datetime
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename
from flask_cors import CORS
from functools import wraps


app = Flask(__name__)
app.config['SECRET_KEY'] = 'voyage_super_secret_key_123'
CORS(app)
api = Api(app, version='1.0', title='Voyage API', description='API for Voyage Chat App')

UPLOAD_FOLDER = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'static/profile_pictures')
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}

if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def token_required(f):
    # Check that the request has a valid JWT token.
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        if 'Authorization' in request.headers:
            auth_header = request.headers['Authorization']
            if auth_header.startswith('Bearer '):
                token = auth_header.split(' ')[1]

        if not token:
            return {'message': 'Token is missing!'}, 401

        try:
            data = jwt.decode(token, app.config['SECRET_KEY'], algorithms=["HS256"])
            g.current_user = data
        except jwt.ExpiredSignatureError:
            return {'message': 'Token has expired!'}, 401
        except jwt.InvalidTokenError:
            return {'message': 'Token is invalid!'}, 401

        return f(*args, **kwargs)
    return decorated


@app.route("/")
def hello_world():
    # The root page is not used by this API.
    abort(404)

@api.route("/users/register")
class Register(Resource):
    # Create a new user account.
    def post(self):
        try:
            json_data = request.get_json(force=True)
            username = json_data['username']
            password = json_data['password']

            # Store a password hash instead of the plain password.
            password_hash = generate_password_hash(password, method='pbkdf2:sha256')

            sql = "INSERT INTO users(username, password_hash) VALUES (%s, %s);"
            if executeOnDB(sql, (username, password_hash)):
                return {'message': 'User created successfully'}, 201
            else:
                return {'message': 'Failed to create user, username might already exist.'}, 400

        except Exception as e:
            print(e)
            return {'message': 'An error occurred'}, 400

@api.route("/users/login")
class Login(Resource):
    # Log in a user and return a JWT token.
    def post(self):
        try:
            json_data = request.get_json(force=True)
            username = json_data['username']
            password = json_data['password']

            sql = "SELECT user_id, password_hash FROM users WHERE username = %s;"
            user_records = queryDB(sql, (username,))

            if not user_records:
                return {'message': 'Invalid credentials'}, 401

            user_id = user_records[0][0]
            stored_hash = user_records[0][1]

            if check_password_hash(stored_hash, password):
                token = jwt.encode({
                    'user_id': str(user_id),
                    'username': username,
                    'exp': datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(hours=24)
                }, app.config['SECRET_KEY'], algorithm="HS256")

                return jsonify({
                    "success": True,
                    "data": {
                        "token": token,
                        "user_id": str(user_id)
                    }
                })
            else:
                return {'message': 'Invalid credentials'}, 401

        except Exception as e:
            print(e)
            return {'message': 'An error occurred'}, 400

@api.route("/auth/verify")
class AuthVerify(Resource):
    # Check if the saved login token is still valid.
    @token_required
    def get(self):
        return {'message': 'Token is valid'}, 200

@api.route("/user/<uuid:user_id>")
class User(Resource):
    # Return profile data for one user.
    @token_required
    def get(self, user_id):
        sql = "SELECT username, avatar_url, bio, account_status, created_at, show_online_status, age_verified FROM users WHERE user_id = %s;"
        user = queryDB(sql, (str(user_id),))

        if not user:
            abort(404, description="User not found")

        user_data = {
            "user_id": str(user_id),
            "username": user[0][0],
            "avatar_url": user[0][1],
            "bio": user[0][2],
            "account_status": user[0][3],
            "created_at": user[0][4].isoformat(),
            "show_online_status": user[0][5],
            "age_verified": user[0][6]
        }
        return jsonify(user_data)

    # Update the current user's own profile (bio and username).
    @token_required
    def put(self, user_id):
        if str(user_id) != g.current_user['user_id']:
            return {'message': 'Permission denied: You can only edit your own profile.'}, 403

        try:
            json_data = request.get_json(force=True)
            bio = json_data.get('bio')
            username = json_data.get('username')
            
            updates = []
            params = []
            
            if bio is not None:
                if len(bio) > 150:
                    return {'message': 'Bio must be 150 characters or less.'}, 400
                updates.append("bio = %s")
                params.append(bio)
                
            if username is not None:
                if len(username) < 3 or len(username) > 25:
                    return {'message': 'Username must be between 3 and 25 characters.'}, 400
                updates.append("username = %s")
                params.append(username)
            
            show_online_status = json_data.get('show_online_status')
            if show_online_status is not None:
                updates.append("show_online_status = %s")
                params.append(bool(show_online_status))
            
            if not updates:
                return {'message': 'Nothing to update.'}, 400
                
            params.append(str(user_id))
            sql = f"UPDATE users SET {', '.join(updates)}, updated_at = NOW() WHERE user_id = %s;"
            
            if executeOnDB(sql, tuple(params)):
                new_token = None
                if username:
                    # Generate a new token since the username (identity) has changed.
                    new_token = jwt.encode({
                        'user_id': str(user_id),
                        'username': username,
                        'exp': datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(hours=24)
                    }, app.config['SECRET_KEY'], algorithm="HS256")
                
                return {
                    'message': 'Profile updated successfully', 
                    'username': username,
                    'token': new_token
                }, 200
            else:
                return {'message': 'Failed to update profile (username might be taken)'}, 400
        except Exception as e:
            print(e)
            return {'message': 'An error occurred'}, 400

    # Delete the current user's account.
    @token_required
    def delete(self, user_id):
        if str(user_id) != g.current_user['user_id']:
            return {'message': 'Permission denied.'}, 403

        try:
            # Note: Database constraints (FOREIGN KEYs) should handle clean-up if configured for CASCADE.
            # Otherwise, manual deletion of messages/memberships would be needed here.
            sql = "DELETE FROM users WHERE user_id = %s;"
            if executeOnDB(sql, (str(user_id),)):
                return {'message': 'Account deleted successfully'}, 200
            else:
                return {'message': 'Failed to delete account'}, 500
        except Exception as e:
            print(e)
            return {'message': 'An error occurred'}, 400

@api.route("/user/change-password")
class ChangePassword(Resource):
    # Change the current user's password.
    @token_required
    def post(self):
        try:
            json_data = request.get_json(force=True)
            old_password = json_data.get('old_password')
            new_password = json_data.get('new_password')
            user_id = g.current_user['user_id']

            if not old_password or not new_password:
                return {'message': 'Both old and new passwords are required'}, 400

            sql = "SELECT password_hash FROM users WHERE user_id = %s;"
            rows = queryDB(sql, (user_id,))
            if not rows:
                return {'message': 'User not found'}, 404
            
            stored_hash = rows[0][0]
            if not check_password_hash(stored_hash, old_password):
                return {'message': 'Incorrect old password'}, 401
            
            new_hash = generate_password_hash(new_password, method='pbkdf2:sha256')
            update_sql = "UPDATE users SET password_hash = %s, updated_at = NOW() WHERE user_id = %s;"
            if executeOnDB(update_sql, (new_hash, user_id)):
                return {'message': 'Password updated successfully'}, 200
            else:
                return {'message': 'Failed to update password'}, 500
        except Exception as e:
            print(e)
            return {'message': 'An error occurred'}, 400

@api.route("/user/upload-avatar")
class UploadAvatar(Resource):
    # Upload and update the profile picture for the current user.
    @token_required
    def post(self):
        try:
            if 'file' not in request.files:
                return {'message': 'No file part'}, 400
            
            file = request.files['file']
            if file.filename == '':
                return {'message': 'No selected file'}, 400
            
            if file and file.filename and allowed_file(file.filename):
                filename = secure_filename(file.filename)
                user_id = g.current_user['user_id']
                ext = filename.rsplit('.', 1)[1].lower()
                # Create a unique filename using user_id and timestamp
                new_filename = f"{user_id}_{int(datetime.datetime.now().timestamp())}.{ext}"
                
                file_path = os.path.join(UPLOAD_FOLDER, new_filename)
                file.save(file_path)
                
                # Store the relative path to be served by Flask static
                avatar_url = f"static/profile_pictures/{new_filename}"
                
                sql = "UPDATE users SET avatar_url = %s, updated_at = NOW() WHERE user_id = %s;"
                if executeOnDB(sql, (avatar_url, user_id)):
                    return {
                        'message': 'Avatar updated successfully', 
                        'avatar_url': avatar_url
                    }, 200
                else:
                    return {'message': 'Failed to update database'}, 500
            
            return {'message': 'File type not allowed'}, 400
        except Exception as e:
            print(f"Upload error: {e}")
            return {'message': 'An error occurred during upload'}, 500

@api.route("/users/search")
class UserSearch(Resource):
    # Search users by username.
    @token_required
    def get(self):
        try:
            query = request.args.get('q', '')
            if not query:
                return {'success': True, 'data': []}, 200

            sql = "SELECT user_id, username FROM users WHERE username ILIKE %s LIMIT 20;"
            results = queryDB(sql, (f'%{query}%',))

            users = [{'user_id': str(row[0]), 'username': row[1]} for row in results]
            return {'success': True, 'data': users}, 200

        except Exception as e:
            print(e)
            return {'message': 'An error occurred'}, 400

@api.route("/settings/notifications")
class NotificationSettings(Resource):
    # Get or update the current user's notification preference.
    @token_required
    def get(self):
        try:
            user_id = g.current_user['user_id']
            rows = queryDB(
                "SELECT notifications_enabled FROM users WHERE user_id = %s;",
                (user_id,)
            )
            enabled = bool(rows[0][0]) if rows else True
            return {'success': True, 'notifications_enabled': enabled}, 200
        except Exception as e:
            print(e)
            return {'message': 'An error occurred'}, 400

    @token_required
    def put(self):
        try:
            json_data = request.get_json(force=True)
            enabled = bool(json_data.get('notifications_enabled', True))
            user_id = g.current_user['user_id']

            if executeOnDB(
                "UPDATE users SET notifications_enabled = %s, updated_at = NOW() WHERE user_id = %s;",
                (enabled, user_id)
            ):
                return {'success': True, 'notifications_enabled': enabled}, 200
            return {'message': 'Failed to update notification setting'}, 500
        except Exception as e:
            print(e)
            return {'message': 'An error occurred'}, 400

@api.route("/chatrooms/mine")
class MyChatrooms(Resource):
    # Get all chatrooms joined by the current user.
    @token_required
    def get(self):
        try:
            user_id = g.current_user['user_id']
            sql = """
                SELECT c.chatroom_id, c.chatroom_name, c.chatroom_type, lm.content, lm.sent_at
                FROM chatrooms c
                JOIN chatroom_memberships cm ON c.chatroom_id = cm.chatroom_id
                LEFT JOIN LATERAL (
                    SELECT content, sent_at
                    FROM messages
                    WHERE chatroom_id = c.chatroom_id AND deleted_at IS NULL
                    ORDER BY sent_at DESC
                    LIMIT 1
                ) lm ON TRUE
                WHERE cm.user_id = %s AND cm.left_at IS NULL;
            """
            rows = queryDB(sql, (user_id,))

            chatrooms = []
            for row in rows:
                chatroom_type = row[2]
                if chatroom_type == 'Direct Message':
                    type_label = 'dm'
                    other = queryDB("""
                        SELECT u.username FROM users u
                        JOIN chatroom_memberships cm ON u.user_id = cm.user_id
                        WHERE cm.chatroom_id = %s AND u.user_id != %s AND cm.left_at IS NULL
                        LIMIT 1;
                    """, (str(row[0]), user_id))
                    display_name = other[0][0] if other else row[1]
                else:
                    type_label = 'group'
                    display_name = row[1]
                chatrooms.append({
                    'chatroom_id': str(row[0]),
                    'chatroom_name': row[1],
                    'display_name': display_name,
                    'type': type_label,
                    'last_message': row[3] or '',
                    'last_time': row[4].isoformat() if row[4] else None
                })

            return {'success': True, 'data': chatrooms}, 200

        except Exception as e:
            print(e)
            return {'message': 'An error occurred'}, 400

@api.route("/chatrooms/dm")
class DirectMessageChatroom(Resource):
    # Create or reuse a direct message chatroom.
    @token_required
    def post(self):
        try:
            json_data = request.get_json(force=True)
            other_user_id = json_data['user_id']
            current_user_id = g.current_user['user_id']

            sql = """
                SELECT c.chatroom_id FROM chatrooms c
                JOIN chatroom_memberships cm1 ON c.chatroom_id = cm1.chatroom_id
                JOIN chatroom_memberships cm2 ON c.chatroom_id = cm2.chatroom_id
                WHERE c.chatroom_type = 'Direct Message'
                AND cm1.user_id = %s AND cm1.left_at IS NULL
                AND cm2.user_id = %s AND cm2.left_at IS NULL;
            """
            existing = queryDB(sql, (current_user_id, other_user_id))
            if existing:
                return {'data': {'chatroom_id': str(existing[0][0])}}, 200

            user1 = queryDB("SELECT username FROM users WHERE user_id = %s;", (current_user_id,))
            user2 = queryDB("SELECT username FROM users WHERE user_id = %s;", (other_user_id,))
            if not user1 or not user2:
                return {'message': 'User not found'}, 404

            name = f"{user1[0][0]}__{user2[0][0]}"

            if not executeOnDB(
                "INSERT INTO chatrooms(chatroom_type, chatroom_name) VALUES ('Direct Message', %s);",
                (name,)
            ):
                return {'message': 'Failed to create chatroom'}, 500

            result = queryDB(
                "SELECT chatroom_id FROM chatrooms WHERE chatroom_name = %s AND chatroom_type = 'Direct Message' ORDER BY chatroom_id DESC LIMIT 1;",
                (name,)
            )
            if not result:
                return {'message': 'Failed to retrieve chatroom'}, 500

            chatroom_id = str(result[0][0])

            executeOnDB(
                "INSERT INTO chatroom_memberships(user_id, chatroom_id) VALUES (%s, %s);",
                (current_user_id, chatroom_id)
            )
            executeOnDB(
                "INSERT INTO chatroom_memberships(user_id, chatroom_id) VALUES (%s, %s);",
                (other_user_id, chatroom_id)
            )

            return {'data': {'chatroom_id': chatroom_id}}, 201

        except Exception as e:
            print(e)
            return {'message': 'An error occurred'}, 400

@api.route("/chatrooms/locational")
class LocationalChatrooms(Resource):
    # Get all local map chatrooms.
    @token_required
    def get(self):
        try:
            rows = queryDB(
                "SELECT chatroom_id, chatroom_name, coords_top_left, coords_bottom_right, author_id FROM chatrooms WHERE chatroom_type = 'Locational Chatroom';",
                ()
            )

            chatrooms = []
            for row in rows:
                chatrooms.append({
                    'chatroom_id': str(row[0]),
                    'chatroom_name': row[1],
                    'coords_top_left': row[2].strip() if row[2] else None,
                    'coords_bottom_right': row[3].strip() if row[3] else None,
                    'author_id': str(row[4]) if row[4] else None,
                })

            return {'success': True, 'data': chatrooms}, 200

        except Exception as e:
            print(e)
            return {'message': 'An error occurred'}, 400


    # Create a new local map chatroom.
    @token_required
    def post(self):
        try:
            json_data = request.get_json(force=True)
            chatroom_name = json_data.get('chatroom_name')
            coords_top_left = json_data.get('coords_top_left')
            coords_bottom_right = json_data.get('coords_bottom_right')
            author_id = g.current_user['user_id']

            if not chatroom_name or not coords_top_left or not coords_bottom_right:
                return {'message': 'chatroom_name, coords_top_left, and coords_bottom_right are required'}, 400

            executeOnDB(
                "INSERT INTO chatrooms(chatroom_type, chatroom_name, coords_top_left, coords_bottom_right, author_id) VALUES ('Locational Chatroom', %s, %s, %s, %s);",
                (chatroom_name, coords_top_left, coords_bottom_right, author_id)
            )

            new_room = queryDB(
                "SELECT chatroom_id FROM chatrooms WHERE chatroom_name = %s AND chatroom_type = 'Locational Chatroom' ORDER BY chatroom_id DESC LIMIT 1;",
                (chatroom_name,)
            )

            if not new_room:
                return {'message': 'Failed to create chatroom'}, 500

            chatroom_id = str(new_room[0][0])

            return {'success': True, 'data': {'chatroom_id': chatroom_id, 'chatroom_name': chatroom_name}}, 201

        except Exception as e:
            print(e)
            return {'message': 'An error occurred'}, 400

    # Delete local chatrooms created by the current user.
    @token_required
    def delete(self):
        try:
            user_id = g.current_user['user_id']
            executeOnDB(
                "DELETE FROM messages WHERE chatroom_id IN (SELECT chatroom_id FROM chatrooms WHERE chatroom_type = 'Locational Chatroom' AND author_id = %s);",
                (user_id,)
            )
            executeOnDB(
                "DELETE FROM chatroom_memberships WHERE chatroom_id IN (SELECT chatroom_id FROM chatrooms WHERE chatroom_type = 'Locational Chatroom' AND author_id = %s);",
                (user_id,)
            )
            executeOnDB(
                "DELETE FROM chatrooms WHERE chatroom_type = 'Locational Chatroom' AND author_id = %s;",
                (user_id,)
            )
            return {'success': True, 'message': 'All locational chatrooms deleted'}, 200
        except Exception as e:
            print(e)
            return {'message': 'An error occurred'}, 400

@api.route("/chatrooms/join")
class JoinChatroom(Resource):
    # Add the current user to a chatroom.
    @token_required
    def post(self):
        try:
            json_data = request.get_json(force=True)
            chatroom_id = json_data.get('chatroom_id')
            user_id = g.current_user['user_id']

            if not chatroom_id:
                return {'success': False, 'message': 'chatroom_id required'}, 400

            existing = queryDB(
                'SELECT * FROM chatroom_memberships WHERE user_id = %s AND chatroom_id = %s AND left_at IS NULL;',
                (user_id, chatroom_id)
            )
            if not existing:
                executeOnDB(
                    'INSERT INTO chatroom_memberships (user_id, chatroom_id) VALUES (%s, %s);',
                    (user_id, chatroom_id)
                )

            room = queryDB(
                'SELECT chatroom_id, chatroom_name FROM chatrooms WHERE chatroom_id = %s;',
                (chatroom_id,)
            )
            if not room:
                return {'success': False, 'message': 'Chatroom not found'}, 404

            return {'success': True, 'data': {'chatroom_id': str(room[0][0]), 'chatroom_name': room[0][1]}}, 200
        except Exception as e:
            print(e)
            return {'message': 'An error occurred'}, 400

@api.route("/chatrooms/<uuid:chatroom_id>/messages")
class ChatroomMessages(Resource):
    # Get all messages in one chatroom.
    @token_required
    def get(self, chatroom_id):
        try:
            sql = """
                SELECT m.message_id, u.username, m.content, m.sent_at
                FROM messages m
                JOIN users u ON m.sender_id = u.user_id
                WHERE m.chatroom_id = %s AND m.deleted_at IS NULL
                ORDER BY m.sent_at ASC;
            """
            rows = queryDB(sql, (str(chatroom_id),))

            messages = [{
                'message_id': str(row[0]),
                'sender_username': row[1],
                'content': row[2],
                'sent_at': row[3].isoformat()
            } for row in rows]

            return {'success': True, 'data': messages}, 200

        except Exception as e:
            print(e)
            return {'message': 'An error occurred'}, 400

    # Send a new message to one chatroom.
    @token_required
    def post(self, chatroom_id):
        try:
            json_data = request.get_json(force=True)
            content = json_data['content']
            sender_id = g.current_user['user_id']

            sql = "INSERT INTO messages(chatroom_id, sender_id, content) VALUES (%s, %s, %s);"
            if executeOnDB(sql, (str(chatroom_id), sender_id, content)):
                return {'message': 'Message sent'}, 201
            else:
                return {'message': 'Failed to send message'}, 500

        except Exception as e:
            print(e)
            return {'message': 'An error occurred'}, 400

@api.route("/notifications")
class Notifications(Resource):
    # Get recent message notifications for the current user.
    @token_required
    def get(self):
        try:
            user_id = g.current_user['user_id']
            settings = queryDB(
                "SELECT notifications_enabled FROM users WHERE user_id = %s;",
                (user_id,)
            )
            if settings and not settings[0][0]:
                return {'success': True, 'data': [], 'unread_count': 0}, 200

            sql = """
                SELECT m.message_id, u.username, c.chatroom_name, c.chatroom_type, m.content, m.sent_at, nr.read_at
                FROM messages m
                JOIN users u ON m.sender_id = u.user_id
                JOIN chatrooms c ON m.chatroom_id = c.chatroom_id
                JOIN chatroom_memberships cm ON c.chatroom_id = cm.chatroom_id
                LEFT JOIN notification_reads nr
                    ON nr.message_id = m.message_id
                    AND nr.user_id = %s
                WHERE cm.user_id = %s
                AND cm.left_at IS NULL
                AND m.sent_at >= cm.joined_at
                AND m.sender_id != %s
                AND m.deleted_at IS NULL
                ORDER BY m.sent_at DESC
                LIMIT 30;
            """
            rows = queryDB(sql, (user_id, user_id, user_id))

            notifications = []
            unread_count = 0
            for row in rows:
                chatroom_type = row[3]
                sender_username = row[1]
                chatroom_name = row[2]
                is_read = row[6] is not None
                if not is_read:
                    unread_count += 1

                if chatroom_type == 'Direct Message':
                    title = f'{sender_username} sent you a message'
                    notification_type = 'message'
                else:
                    title = f'{sender_username} sent a message in {chatroom_name}'
                    notification_type = 'group'
                notifications.append({
                    'id': str(row[0]),
                    'title': title,
                    'message': row[4],
                    'time': row[5].isoformat(),
                    'type': notification_type,
                    'is_read': is_read,
                    'sender_username': sender_username,
                    'chatroom_name': chatroom_name,
                })

            return {'success': True, 'data': notifications, 'unread_count': unread_count}, 200

        except Exception as e:
            print(e)
            return {'message': 'An error occurred'}, 400

@api.route("/notifications/<uuid:message_id>/read")
class NotificationRead(Resource):
    # Mark one message notification as read for the current user.
    @token_required
    def patch(self, message_id):
        try:
            user_id = g.current_user['user_id']
            success = executeOnDB(
                """
                INSERT INTO notification_reads(user_id, message_id)
                VALUES (%s, %s)
                ON CONFLICT (user_id, message_id) DO UPDATE SET read_at = NOW();
                """,
                (user_id, str(message_id))
            )
            if success:
                return {'success': True, 'message': 'Notification marked as read'}, 200
            return {'message': 'Failed to mark notification as read'}, 500
        except Exception as e:
            print(e)
            return {'message': 'An error occurred'}, 400

@api.route("/notifications/read-all")
class NotificationsReadAll(Resource):
    # Mark all current message notifications as read for the current user.
    @token_required
    def patch(self):
        try:
            user_id = g.current_user['user_id']
            success = executeOnDB(
                """
                INSERT INTO notification_reads(user_id, message_id)
                SELECT %s, m.message_id
                FROM messages m
                JOIN chatroom_memberships cm ON m.chatroom_id = cm.chatroom_id
                WHERE cm.user_id = %s
                AND cm.left_at IS NULL
                AND m.sent_at >= cm.joined_at
                AND m.sender_id != %s
                AND m.deleted_at IS NULL
                ON CONFLICT (user_id, message_id) DO UPDATE SET read_at = NOW();
                """,
                (user_id, user_id, user_id)
            )
            if success:
                return {'success': True, 'message': 'All notifications marked as read'}, 200
            return {'message': 'Failed to mark notifications as read'}, 500
        except Exception as e:
            print(e)
            return {'message': 'An error occurred'}, 400
        


@api.route("/chatrooms/group")
class GroupChat(Resource):
    # Create or reuse a private group chatroom.
    @token_required
    def post(self):
        try:
            json_data = request.get_json(force=True)
            member_ids = json_data.get('member_ids', [])
            current_user = g.current_user['user_id']

            if current_user not in member_ids:
                member_ids.append(current_user)

            member_ids = sorted(set(member_ids))

            if len(member_ids) < 2:
                return {'message': 'Not enough members'}, 400

            sql = """
                SELECT c.chatroom_id
                FROM chatrooms c
                JOIN chatroom_memberships cm ON c.chatroom_id = cm.chatroom_id
                WHERE c.chatroom_type = 'Private Group'
                AND cm.left_at IS NULL
                AND cm.user_id = ANY(%s)
                GROUP BY c.chatroom_id
                HAVING COUNT(DISTINCT cm.user_id) = %s
                AND COUNT(DISTINCT cm.user_id) = (
                    SELECT COUNT(DISTINCT cm2.user_id)
                    FROM chatroom_memberships cm2
                    WHERE cm2.chatroom_id = c.chatroom_id
                    AND cm2.left_at IS NULL
                );
            """

            existing = queryDB(sql, (member_ids, len(member_ids)))
            if existing:
                return {'data': {'chatroom_id': str(existing[0][0])}}, 200

            placeholders = ','.join(['%s'] * len(member_ids))
            rows = queryDB(
                f"SELECT username FROM users WHERE user_id IN ({placeholders});",
                tuple(member_ids)
            )
            names = [r[0] for r in rows]
            group_name = ", ".join(names)

            executeOnDB(
                "INSERT INTO chatrooms(chatroom_type, chatroom_name) VALUES ('Private Group', %s);",
                (group_name,)
            )

            new_room = queryDB(
                "SELECT chatroom_id FROM chatrooms WHERE chatroom_name = %s AND chatroom_type = 'Private Group' ORDER BY chatroom_id DESC LIMIT 1;",
                (group_name,)
            )

            if not new_room:
                return {'message': 'Failed'}, 500

            chatroom_id = str(new_room[0][0])

            for uid in member_ids:
                executeOnDB(
                    "INSERT INTO chatroom_memberships(user_id, chatroom_id) VALUES (%s, %s);",
                    (uid, chatroom_id)
                )

            return {'data': {'chatroom_id': chatroom_id, 'name': group_name}}, 201

        except Exception as e:
            print(e)
            return {'message': 'Error'}, 400
