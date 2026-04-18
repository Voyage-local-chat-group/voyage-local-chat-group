# Place for backend development - python and flask/sqlite
from flask import *
from flask_restx import Api, Resource
import os
from database_connector import queryDB, executeOnDB # 导入修改后的函数
import jwt
import datetime
from werkzeug.security import generate_password_hash, check_password_hash
from flask_cors import CORS
from functools import wraps # 导入 wraps 用于创建装饰器


app = Flask(__name__)
# In a real app, this should be an environment variable
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