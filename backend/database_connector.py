import psycopg2
import os

def queryDB(sql_query):
    db = databaseConnect()
    with db.cursor() as cursor:
        cursor.execute(sql_query)
        data = cursor.fetchall()
        cursor.close()
    db.close()
    return data

def receiveData(data):
    # Honestly this might be redundant.
    return None

# Resets the database to the schema depicted in database_create.sql
def firstBoot():
    try:
        db = databaseConnect()
        command = open('database_create.sql','r').read()
        with db.cursor() as cursor:
            cursor.execute(command)
            cursor.close()
        print("Successful database initialisation!")
        db.close()
    except (psycopg2.DatabaseError, Exception) as error:
        print(error)

def databaseConnect():
    try:
        with psycopg2.connect(host="localhost",dbname="app", user="chatlus", password="chatlus") as connection:
            print("Connected to database!")
            return connection
    except (psycopg2.DatabaseError, Exception) as error:
        print(error)