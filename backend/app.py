# Place for backend development - python and flask/sqlite
from flask import Flask, request
from flask_restx import Api

app = Flask(__name__)


@app.route("/")
def hello_world():
    return "<p>Not for browsers!</p>"

@app.route("/users",methods=["GET"])
def showUsers():
    users = ["No users! Set up the database!"]
    return users