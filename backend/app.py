# Place for backend development - python and flask/sqlite
from flask import *
from flask_restx import Api, reqparse,Resource,fields

app = Flask(__name__)
api = Api(app)


@app.route("/")
def hello_world():
    abort(404)

@api.route("/users")
class Users(Resource):
    def get(self):
        users = ["Nothing! Set up the database!"]
        return users
    
@api.route("/user/<uuid:user_id>")
class User(Resource):
    def get(self,user_id):
        return user_id