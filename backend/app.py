# Place for backend development - python and flask/sqlite
from flask import *
from flask_restx import Api, reqparse,Resource,fields
import os
from database_connector import *
import json


app = Flask(__name__)
api = Api(app)

@app.route("/")
def hello_world():
    abort(404)

@api.route("/users")
class Users(Resource):
    def get(self):
        users = queryDB("SELECT * FROM users;")
        return jsonify(users)
    
    def post(self):
        try:
            json_data = request.get_json(force=True)
            username = json_data['username']
            password_hash = "TestPassword"
            executeOnDB(f"INSERT INTO users(username,password_hash) VALUES ('{username}','{password_hash}');")
            return Response(status=200)
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