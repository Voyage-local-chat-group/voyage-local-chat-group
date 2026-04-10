import psycopg2
import os

def databaseConnect():
    try:
        connection = psycopg2.connect(host="localhost",dbname="app", user="Voyage", password="Voyage")
        print("Connected to database!")
        return connection
    except (psycopg2.DatabaseError, Exception) as error:
        print(f"Database connection error: {error}")
        return None

def queryDB(sql_query, params=None):
    data = []
    db = databaseConnect()
    if not db:
        return data
    try:
        with db.cursor() as cursor:
            cursor.execute(sql_query, params)
            if cursor.description:
                data = cursor.fetchall()
    except (psycopg2.DatabaseError, Exception) as error:
        print(f"Query error: {error}")
    finally:
        if db:
            db.close()
    return data

def executeOnDB(sql_query, params=None):
    success = False
    db = databaseConnect()
    if not db:
        return success
    try:
        with db.cursor() as cursor:
            cursor.execute(sql_query, params)
        db.commit()
        success = True
    except (psycopg2.DatabaseError, Exception) as error:
        print(f"Execution error: {error}")
        if db:
            db.rollback() 
    finally:
        if db:
            db.close()
    return success

def receiveData(data):
    # Honestly this might be redundant.
    return None

# Resets the database to the schema depicted in database_create.sql
def firstBoot():
    try:
        db = databaseConnect()
        if not db:
            print("Failed to connect to database. Aborting initialization.")
            return
        
        sql_file_path = os.path.join(os.path.dirname(__file__), 'database_create.sql')
        command = open(sql_file_path,'r').read()
        
        with db.cursor() as cursor:
            cursor.execute(command)
        
        db.commit() 
        print("Successful database initialisation!")

    except (psycopg2.DatabaseError, Exception) as error:
        print(f"Database initialization failed: {error}")
        if 'db' in locals() and db:
            db.rollback()
    finally:
        if 'db' in locals() and db:
            db.close()

if __name__ == '__main__':
    print("Running database first boot initialization...")
    confirm = input("This will reset your database. Are you sure? (y/N): ")
    if confirm.lower() == 'y':
        firstBoot()
    else:
        print("Initialization cancelled.")