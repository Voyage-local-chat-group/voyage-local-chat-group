Developer Guide
===============

.. _backend:
Backend
-------

^^^^^^^^^^^^^
Install Guide
^^^^^^^^^^^^^

1. Install the latest version of Python.
2. Install PSQL and run `CREATE USER chatlus;CREATE DATABASE app;` in the PSQL terminal. This might be trickier so I need to update the install guide for this.
3. Clone the Git repo and run `cd backend` in your preferred code editor.
4. Create a virtual environment with `python -m venv venv` and activate it with `venv\Scripts\activate` (Windows) or `source venv/bin/activate` (Unix).
5. Run `pip install -r requirements.txt` to get the required dependencies installed.

^^^^^^^^^^^^^
Usage Guide
^^^^^^^^^^^^^

The API can be accessed currently at http://127.0.0.1:5000/<api_route>.

1. Clone the Git repo and run `cd backend` in your preferred code editor.
2. Run `flask run` to start the backend server.

^^^^^^^^^^^^^
Components
^^^^^^^^^^^^^
- Database: SQLite file that lives in the /backend/ folder
- Database Connector: Python script that connects the PSQL database to the rest of the backend.
- Location Manager: Python script that interfaces with the Location API to pull map data and push it to the frontend.
- User Manager: Python script that manages distributing and storing updates to users.
- Chatroom Manager: Python script that manages distributing and storing updates to chatrooms.
- User Validator: Python script that ensures users have permissions to access any particular resources (chatrooms, profiles, etc.)


.. _frontend:
Frontend
--------

Technologies are currently Dart and Flutter, as well as Android Studio Goes in ``/frontend/``

^^^^^^^^^^^^^
Prerequisites
^^^^^^^^^^^^^

- Flutter (2.1GB)
- Android Studio (1.4GB) + SDK (2.4GB) (And more.)

^^^^^^^^^^^^^
Install Guide
^^^^^^^^^^^^^

1. Install Flutter as described here: https://docs.flutter.dev/install/quick
2. Install Android Studio as described here: https://developer.android.com/studio/install
3. Set it up for use with Flutter as described here: https://docs.flutter.dev/platform-integration/android/setup

^^^^^^^^^^^^^
Test Instructions
^^^^^^^^^^^^^

1. Pull this repository and open it with your preferred Code Editor
2. Run ``cd frontend`` in the terminal.
3. Setup your device:

* Run ``flutter emulators --launch [Emulator_Name]`` to launch your Android Emulator
* Run ``???`` to connect to your actual phone.

4. Run ``flutter run`` in the terminal to open your Android Emulator/Device and run the app.

^^^^^^^^^^^^^
Build Instructions
^^^^^^^^^^^^^

1. Pull this repository and open it with your preferred Code Editor
2. Run ``cd frontend`` in the terminal.
3. Run ``flutter build`` in the terminal to compile app.


.. _goals:
Developer Goals
---------------
Scope of the project is to produce an application (and accompanying backend) that covers all possible User and System requirements as listed in Coursework Item 1.



