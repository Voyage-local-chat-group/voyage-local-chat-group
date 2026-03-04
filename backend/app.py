# Place for backend development - python and flask/sqlite
from flask import *
from flask_restx import Api

app = Flask(__name__)


@app.route("/")
def hello_world():
    abort(404)

@app.route("/api/users",methods=["GET"])
def showUsers():
    users = ["No users! Set up the database!"]
    return users

@app.route("/api/chatrooms",methods=["GET"])
def listChatrooms():
    chatrooms = ["No chatrooms! Set up the database!"]
    return chatrooms