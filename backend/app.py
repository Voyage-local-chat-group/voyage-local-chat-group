# Place for backend development - python and flask/sqlite
from flask import *
from flask_restx import Api, reqparse,Resource,fields
import os
from database_connector import *
import json
import jwt
import datetime
from werkzeug.security import generate_password_hash, check_password_hash
from flask_cors import CORS


app = Flask(__name__)
# In a real app, this should be an environment variable
app.config['SECRET_KEY'] = 'voyage_super_secret_key_123'
CORS(app)
api = Api(app)

@app.route("/")
def hello_world():
    abort(404)

@api.route("/users/register", methods=['POST'])
class Register(Resource):
    def post(self):
        try:
            json_data = request.get_json(force=True)
            username = json_data['username']
            password = json_data['password']
            
            # Hash the password
            password_hash = generate_password_hash(password)
            
            # Use parametrized queries to prevent SQL injection ideally, but for now we follow the existing pattern
            # and just escape single quotes (this is a simplified example, in production use proper parameterization)
            safe_username = username.replace("'", "''")
            safe_hash = password_hash.replace("'", "''")
            executeOnDB(f"INSERT INTO users(username, password_hash) VALUES ('{safe_username}', '{safe_hash}');")
            return Response(status=200)
        except Exception as Error:
            print(Error)
            abort(400)

@api.route("/users/login", methods=['POST'])
class Login(Resource):
    def post(self):
        try:
            json_data = request.get_json(force=True)
            username = json_data['username']
            password = json_data['password']
            
            safe_username = username.replace("'", "''")
            user_records = queryDB(f"SELECT user_id, password_hash FROM users WHERE username = '{safe_username}';")
            
            if not user_records or len(user_records) == 0:
                print("User not found")
                abort(401, description="Invalid credentials")
                
            user_id = user_records[0][0]
            password_hash = user_records[0][1]
            
            if check_password_hash(password_hash, password):
                # Issue JWT
                token = jwt.encode({
                    'user_id': str(user_id),
                    'username': username,
                    'exp': datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(hours=24)
                }, app.config['SECRET_KEY'], algorithm="HS256")
                
                return jsonify({
                    "access_token": token,
                    "user_id": str(user_id),
                    "username": username
                })
            else:
                print("Invalid password")
                abort(401, description="Invalid credentials")
            
        except Exception as Error:
            print(Error)
            abort(400)
    
@api.route("/user/<uuid:user_id>", methods=['GET','PUT'])
class User(Resource):
    def get(self,user_id):
        user = queryDB(f"SELECT * FROM users WHERE user_id = '{user_id}';")
        return jsonify(user)
    
    def put(self):
        try:
            json_data = request.get_json(force=True)
            return Response(status=200)
        except Exception as Error:
            print(Error)
            abort(400)