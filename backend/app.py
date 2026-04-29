# Place for backend development - python and flask/sqlite
from flask import *
from flask_restx import Api, Resource
import os
from database_connector import queryDB, executeOnDB
import jwt
import datetime
from werkzeug.security import generate_password_hash, check_password_hash
from flask_cors import CORS
from functools import wraps


app = Flask(__name__)
app.config['SECRET_KEY'] = 'voyage_super_secret_key_123'
CORS(app)
api = Api(app, version='1.0', title='Voyage API', description='API for Voyage Chat App')

def token_required(f):
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
    abort(404)

@api.route("/users/register")
class Register(Resource):
    def post(self):
        try:
            json_data = request.get_json(force=True)
            username = json_data['username']
            password = json_data['password']

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
    @token_required
    def get(self):
        return {'message': 'Token is valid'}, 200

@api.route("/user/<uuid:user_id>")
class User(Resource):
    @token_required
    def get(self, user_id):
        sql = "SELECT username, avatar_url, bio, account_status, created_at FROM users WHERE user_id = %s;"
        user = queryDB(sql, (str(user_id),))

        if not user:
            abort(404, description="User not found")

        user_data = {
            "user_id": str(user_id),
            "username": user[0][0],
            "avatar_url": user[0][1],
            "bio": user[0][2],
            "account_status": user[0][3],
            "created_at": user[0][4].isoformat()
        }
        return jsonify(user_data)

    @token_required
    def put(self, user_id):
        if str(user_id) != g.current_user['user_id']:
            return {'message': 'Permission denied: You can only edit your own profile.'}, 403

        try:
            return {'message': 'Profile updated successfully'}, 200
        except Exception as e:
            print(e)
            return {'message': 'An error occurred'}, 400

@api.route("/users/search")
class UserSearch(Resource):
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

@api.route("/chatrooms/mine")
class MyChatrooms(Resource):
    @token_required
    def get(self):
        try:
            user_id = g.current_user['user_id']
            sql = """
                SELECT c.chatroom_id, c.chatroom_name, c.chatroom_type
                FROM chatrooms c
                JOIN chatroom_memberships cm ON c.chatroom_id = cm.chatroom_id
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
                    'type': type_label
                })

            return {'success': True, 'data': chatrooms}, 200

        except Exception as e:
            print(e)
            return {'message': 'An error occurred'}, 400

@api.route("/chatrooms/dm")
class DirectMessageChatroom(Resource):
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
        


@api.route("/chatrooms/group")
class GroupChat(Resource):
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
