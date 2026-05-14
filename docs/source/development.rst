Developer Guide
===============

.. _backend:
Backend
-------

^^^^^^^^^^^^^
Install Guide
^^^^^^^^^^^^^

1. Install the latest version of Python 3.
2. Install PostgreSQL and run the following in the PSQL terminal:

   .. code-block:: sql

      CREATE USER "Voyage" WITH PASSWORD 'password';
      CREATE DATABASE voyage OWNER "Voyage";

3. Clone the Git repo and run ``cd backend`` in your preferred code editor.
4. Run the SQL schema to set up the tables:

   .. code-block:: bash

      psql -U Voyage -d voyage -f database_create.sql

5. Create a virtual environment with ``python3 -m venv venv`` and activate it with ``source venv/bin/activate`` (Mac/Unix) or ``venv\Scripts\activate`` (Windows).
6. Run ``pip install -r requirements.txt`` to install the required dependencies.

^^^^^^^^^^^^^
Usage Guide
^^^^^^^^^^^^^

The API can be accessed at http://127.0.0.1:5001/.

1. Clone the Git repo and run ``cd backend`` in your preferred code editor.
2. Run ``python3 run.py`` to start the backend server.

^^^^^^^^^^^^^
Components
^^^^^^^^^^^^^

- Database: PostgreSQL database (named ``voyage``)
- Database Connector: Python script that connects the PostgreSQL database to the rest of the backend.
- Location Manager: Python script that interfaces with the Location API to pull map data and push it to the frontend.
- User Manager: Python script that manages distributing and storing updates to users.
- Chatroom Manager: Python script that manages distributing and storing updates to chatrooms.
- User Validator: Python script that ensures users have permissions to access any particular resources (chatrooms, profiles, etc.)

.. _frontend:
Frontend
--------

Built with Dart and Flutter, running as a web application in Chrome. Goes in ``/frontend/``

^^^^^^^^^^^^^
Prerequisites
^^^^^^^^^^^^^

- Flutter (2.1GB)
- A modern web browser (Chrome recommended)

^^^^^^^^^^^^^
Install Guide
^^^^^^^^^^^^^

1. Install Flutter as described here: https://docs.flutter.dev/install/quick
2. Enable Flutter web support by running ``flutter config --enable-web``

^^^^^^^^^^^^^
Test Instructions
^^^^^^^^^^^^^

1. Pull this repository and open it with your preferred code editor.
2. Run ``cd frontend`` in the terminal.
3. Run ``flutter run -d chrome`` to launch the app in Chrome.

^^^^^^^^^^^^^
Build Instructions
^^^^^^^^^^^^^

1. Pull this repository and open it with your preferred code editor.
2. Run ``cd frontend`` in the terminal.
3. Run ``flutter build web`` to compile the app for web.

.. _goals:
Developer Goals
---------------

Scope of the project is to produce an application (and accompanying backend) that covers all possible User and System requirements as listed in Coursework Item 1.