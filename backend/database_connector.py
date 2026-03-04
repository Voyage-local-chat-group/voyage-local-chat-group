import sqlite3
import os

def queryDB(sql_query):
    data = None
    return data

def receiveData(data):
    # Honestly this might be redundant.
    return None

# Resets the database to the schema depicted in database_create.sql
def firstBoot():
    open("database.db","w")

    

connector = sqlite3.connect("database.db")