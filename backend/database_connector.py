import psycopg2
import os

def databaseConnect():
    # Create a connection to the PostgreSQL database.
    try:
        # Connect to the local database using the given login details.
        connection = psycopg2.connect(host="localhost",dbname="app", user="Voyage", password="Voyage")
        print("Connected to database!")
        return connection
    except (psycopg2.DatabaseError, Exception) as error:
        # Show the error if the connection fails.
        print(f"Database connection error: {error}")
        # Return None so the program knows the connection did not work.
        return None

def queryDB(sql_query, params=None):
    # Run a query that reads data from the database.
    data = []
    db = databaseConnect()
    if not db:
        # Return an empty list if the database connection failed.
        return data
    try:
        # A cursor sends SQL commands to the database.
        with db.cursor() as cursor:
            # Execute the SQL query with optional parameters.
            cursor.execute(sql_query, params)
            # If the query returns data, get all rows.
            if cursor.description:
                data = cursor.fetchall()
    except (psycopg2.DatabaseError, Exception) as error:
        # Print any query error.
        print(f"Query error: {error}")
    finally:
        # Always close the database connection.
        if db:
            db.close()
    return data

def executeOnDB(sql_query, params=None):
    # Run a query that changes data in the database.
    success = False
    db = databaseConnect()
    if not db:
        # Stop if the database connection failed.
        return success
    try:
        with db.cursor() as cursor:
            cursor.execute(sql_query, params)
        # Save the changes.
        db.commit()
        success = True
    except (psycopg2.DatabaseError, Exception) as error:
        print(f"Execution error: {error}")
        if db:
            # Undo changes if something goes wrong.
            db.rollback() 
    finally:
        if db:
            db.close()
    return success

# Resets the database to the schema depicted in database_create.sql
def firstBoot():
    # Set up or reset the database.
    try:
        db = databaseConnect()
        if not db:
            print("Failed to connect to database. Aborting initialization.")
            return
        
        # Find the database_create.sql file in the same folder.
        sql_file_path = os.path.join(os.path.dirname(__file__), 'database_create.sql')
        # Read the SQL file.
        command = open(sql_file_path,'r').read()
        
        with db.cursor() as cursor:
            cursor.execute(command)
        
        # Save the database setup.
        db.commit() 
        print("Successful database initialisation!")

    except (psycopg2.DatabaseError, Exception) as error:
        print(f"Database initialization failed: {error}")
        if 'db' in locals() and db:
            # Undo setup changes if there is an error.
            db.rollback()
    finally:
        if 'db' in locals() and db:
            db.close()

if __name__ == '__main__':
    # This code runs only when this file is run directly.
    print("Running database first boot initialization...")
    # Ask before resetting the database.
    confirm = input("This will reset your database. Are you sure? (y/N): ")
    if confirm.lower() == 'y':
        firstBoot()
    else:
        print("Initialization cancelled.")
