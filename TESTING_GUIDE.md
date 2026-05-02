# Voyage Testing Guide

This guide explains how I would test the Voyage app from a beginner point of view. The aim of testing is to check that each important feature works as expected, and that the app handles common mistakes without crashing.

## Testing Approach

I split the testing into three parts:

1. Backend API testing
2. Frontend app testing
3. Full system testing

Backend testing checks whether the Flask server and database return the right data. Frontend testing checks whether the Flutter screens show the right interface and react correctly when the user taps buttons. Full system testing checks whether the frontend, backend, and database work together as one complete app.

## Backend Test Plan

| Feature | Test input | Expected result |
|---|---|---|
| Register user | New username and password | User is created and server returns status 201 |
| Register duplicate user | Existing username | Server rejects the request |
| Login user | Correct username and password | Server returns a JWT token |
| Login user with wrong password | Correct username, wrong password | Server returns an error |
| Verify token | Valid JWT token | Server confirms that the token is valid |
| Search users | A username keyword | Matching users are returned |
| Create direct message chat | Another user's id | A direct message chatroom is created or reused |
| Create group chat | Two or more user ids | A private group chatroom is created |
| Get my chatrooms | Valid logged-in user | User's chatrooms are returned |
| Create local chatroom | Name and map coordinates | Local chatroom is created |
| Join local chatroom | Existing chatroom id | User joins the chatroom |
| Send message | Chatroom id and message content | Message is saved |
| Get messages | Existing chatroom id | Chat history is returned |
| Get notifications | Logged-in user with new messages | New message notifications are returned |

## Frontend Test Plan

| Screen | What to test | Expected result |
|---|---|---|
| Login screen | Enter valid login details | User enters the home screen |
| Login screen | Enter wrong login details | Error message is shown |
| Sign up screen | Enter new account details | Account is created and user enters the app |
| Home screen | Tap bottom navigation buttons | Correct screen is shown |
| Map screen | Tap on the map and create chatroom | New local chatroom appears |
| Map screen | Tap an existing chatroom marker | Join option is shown |
| Messages screen | Start a DM | Chat screen opens |
| Chat screen | Send a message | Message appears in the chat |
| Notifications screen | Receive message from another user | Notification list updates automatically |
| Settings screen | Change settings toggles | Toggle values update on screen |

## Full System Test Plan

These tests are important because they prove that the whole app works together.

| Scenario | Steps | Expected result |
|---|---|---|
| New user journey | Register, log in, open map, create local chatroom | User can use the app from a fresh account |
| Local chatroom journey | Create chatroom, join it, send message | Chatroom and messages are saved in the database |
| Direct message journey | Search another user, open DM, send message | Both users can see the chat |
| Group chat journey | Select multiple users and create group | Group chat opens and messages can be sent |
| Notification journey | User A sends message to User B | User B sees a notification within a few seconds |

## How To Test Manually

### 1. Start the Backend

Open a terminal in the project folder:

```powershell
cd backend
py run.py
```

The backend should run on:

```text
http://127.0.0.1:5001
```

### 2. Start the Frontend

Open another terminal:

```powershell
cd frontend
flutter pub get
flutter run
```

Choose a browser, emulator, or connected device when Flutter asks.

### 3. Test Register And Login

1. Open the app.
2. Click Sign up.
3. Enter a new username and password.
4. Check that the app goes to the home screen.
5. Log out if available, or restart the app.
6. Log in with the same account.

Expected result: the user can register and log in successfully.

### 4. Test Local Chatrooms

1. Go to the Map screen.
2. Tap somewhere on the map.
3. Press the add button.
4. Check that a new chatroom marker appears.
5. Tap the marker.
6. Press Join Chatroom.

Expected result: the chat screen opens for that local chatroom.

### 5. Test Messages

1. Open a chatroom.
2. Type a message.
3. Press send.
4. Check that the message appears in the chat.
5. Restart the app and open the same chatroom again.

Expected result: the message is still there after restarting.

### 6. Test Direct Messages

1. Create two user accounts.
2. Log in as the first user.
3. Go to Messages.
4. Press the new message button.
5. Search for the second username.
6. Select that user and open the chat.
7. Send a message.

Expected result: the direct message chat opens and the message is saved.

### 7. Test Notifications

1. Log in as User A in one browser/device.
2. Log in as User B in another browser/device.
3. User A sends a message to User B.
4. User B opens the Notifications screen.
5. Wait up to 3 seconds.

Expected result: User B sees a new notification without pressing refresh.

## How To Run Automated Tests

### Frontend Tests

Run this from the frontend folder:

```powershell
cd frontend
flutter test
```

Expected result: Flutter runs the tests in the `test` folder.

### Backend Syntax Check

Run this from the project folder:

```powershell
py -m py_compile backend\app.py
```

Expected result: no error is printed.

## Evidence To Include In The Report

For the coursework report, include:

1. A screenshot of the backend running.
2. A screenshot of the Flutter app running.
3. A screenshot of `flutter test`.
4. A screenshot of backend API testing.
5. A table showing which tests passed or failed.
6. A short paragraph explaining any failed tests and how they were fixed.

## Beginner Reflection

At first, testing was not just about checking whether the app opened. I learned that each feature needs different test inputs, including normal inputs and incorrect inputs. For example, login should be tested with a correct password and also with a wrong password. Notifications should be tested with two users because one user needs to send a message and the other user needs to receive it. This makes the testing more reliable because it checks real user behaviour instead of only checking individual buttons.
