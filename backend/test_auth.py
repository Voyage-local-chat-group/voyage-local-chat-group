from app import app
import json

client = app.test_client()
username = "testuser_auth"
password = "testpassword123"

print("Testing /users/register...")
try:
    resp = client.post("/users/register", json={"username": username, "password": password})
    print(f"Status Code: {resp.status_code}")
    print(f"Response: {resp.data.decode('utf-8')}")
except Exception as e:
    print(f"Register Failed: {e}")

print("\nTesting /users/login...")
try:
    resp = client.post("/users/login", json={"username": username, "password": password})
    print(f"Status Code: {resp.status_code}")
    if resp.status_code == 200:
        data = resp.get_json()
        print(f"JWT Token: {data.get('access_token')}")
        print(f"User ID: {data.get('user_id')}")
    else:
        print(f"Response: {resp.data.decode('utf-8')}")
except Exception as e:
    print(f"Login Failed: {e}")
