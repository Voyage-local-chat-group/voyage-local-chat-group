import datetime
import os
import sys
import unittest
from unittest.mock import patch

import jwt

sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from app import app


class VoyageApiTests(unittest.TestCase):
    def setUp(self):
        app.config["TESTING"] = True
        self.client = app.test_client()
        self.user_id = "11111111-1111-1111-1111-111111111111"
        self.other_user_id = "22222222-2222-2222-2222-222222222222"
        self.chatroom_id = "33333333-3333-3333-3333-333333333333"
        self.token = jwt.encode(
            {
                "user_id": self.user_id,
                "username": "alice",
                "exp": datetime.datetime.now(datetime.timezone.utc)
                + datetime.timedelta(hours=1),
            },
            app.config["SECRET_KEY"],
            algorithm="HS256",
        )

    def auth_headers(self):
        return {"Authorization": f"Bearer {self.token}"}

    @patch("app.executeOnDB", return_value=True)
    def test_register_creates_user(self, execute_on_db):
        response = self.client.post(
            "/users/register",
            json={"username": "alice", "password": "password123"},
        )

        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.get_json()["message"], "User created successfully")
        self.assertTrue(execute_on_db.called)

    @patch("app.check_password_hash", return_value=True)
    @patch("app.queryDB")
    def test_login_returns_token(self, query_db, check_password_hash):
        query_db.return_value = [(self.user_id, "saved-password-hash")]

        response = self.client.post(
            "/users/login",
            json={"username": "alice", "password": "password123"},
        )

        body = response.get_json()
        self.assertEqual(response.status_code, 200)
        self.assertTrue(body["success"])
        self.assertIn("token", body["data"])
        self.assertEqual(body["data"]["user_id"], self.user_id)
        self.assertTrue(check_password_hash.called)

    @patch("app.queryDB", return_value=[])
    def test_login_rejects_unknown_user(self, query_db):
        response = self.client.post(
            "/users/login",
            json={"username": "missing", "password": "password123"},
        )

        self.assertEqual(response.status_code, 401)
        self.assertEqual(response.get_json()["message"], "Invalid credentials")

    def test_auth_verify_accepts_valid_token(self):
        response = self.client.get("/auth/verify", headers=self.auth_headers())

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.get_json()["message"], "Token is valid")

    def test_auth_verify_rejects_missing_token(self):
        response = self.client.get("/auth/verify")

        self.assertEqual(response.status_code, 401)
        self.assertEqual(response.get_json()["message"], "Token is missing!")

    @patch("app.queryDB")
    def test_user_search_returns_matching_users(self, query_db):
        query_db.return_value = [(self.other_user_id, "bob")]

        response = self.client.get(
            "/users/search?q=bo",
            headers=self.auth_headers(),
        )

        body = response.get_json()
        self.assertEqual(response.status_code, 200)
        self.assertTrue(body["success"])
        self.assertEqual(body["data"][0]["username"], "bob")

    @patch("app.queryDB")
    def test_get_chatroom_messages_returns_messages(self, query_db):
        sent_at = datetime.datetime(2026, 5, 2, 10, 30, tzinfo=datetime.timezone.utc)
        query_db.return_value = [
            ("44444444-4444-4444-4444-444444444444", "bob", "hello", sent_at)
        ]

        response = self.client.get(
            f"/chatrooms/{self.chatroom_id}/messages",
            headers=self.auth_headers(),
        )

        body = response.get_json()
        self.assertEqual(response.status_code, 200)
        self.assertTrue(body["success"])
        self.assertEqual(body["data"][0]["content"], "hello")
        self.assertEqual(body["data"][0]["sender_username"], "bob")

    @patch("app.executeOnDB", return_value=True)
    def test_send_message_saves_message(self, execute_on_db):
        response = self.client.post(
            f"/chatrooms/{self.chatroom_id}/messages",
            headers=self.auth_headers(),
            json={"content": "hello everyone"},
        )

        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.get_json()["message"], "Message sent")
        self.assertTrue(execute_on_db.called)

    @patch("app.queryDB")
    def test_notifications_returns_recent_messages(self, query_db):
        sent_at = datetime.datetime(2026, 5, 2, 11, 0, tzinfo=datetime.timezone.utc)
        query_db.side_effect = [
            [(True,)],
            [
                (
                    "55555555-5555-5555-5555-555555555555",
                    "bob",
                    "Bob chat",
                    "Direct Message",
                    "hi alice",
                    sent_at,
                    None,
                )
            ],
        ]

        response = self.client.get("/notifications", headers=self.auth_headers())

        body = response.get_json()
        self.assertEqual(response.status_code, 200)
        self.assertTrue(body["success"])
        self.assertEqual(body["data"][0]["title"], "bob sent you a message")
        self.assertEqual(body["data"][0]["message"], "hi alice")
        self.assertEqual(body["data"][0]["type"], "message")
        self.assertFalse(body["data"][0]["is_read"])
        self.assertEqual(body["unread_count"], 1)
        self.assertEqual(body["data"][0]["sender_username"], "bob")

    @patch("app.queryDB", return_value=[(False,)])
    def test_notifications_respects_disabled_setting(self, query_db):
        response = self.client.get("/notifications", headers=self.auth_headers())

        body = response.get_json()
        self.assertEqual(response.status_code, 200)
        self.assertTrue(body["success"])
        self.assertEqual(body["data"], [])
        self.assertEqual(body["unread_count"], 0)

    @patch("app.executeOnDB", return_value=True)
    def test_notification_can_be_marked_as_read(self, execute_on_db):
        response = self.client.patch(
            "/notifications/55555555-5555-5555-5555-555555555555/read",
            headers=self.auth_headers(),
        )

        body = response.get_json()
        self.assertEqual(response.status_code, 200)
        self.assertTrue(body["success"])
        self.assertTrue(execute_on_db.called)

    @patch("app.executeOnDB", return_value=True)
    def test_all_notifications_can_be_marked_as_read(self, execute_on_db):
        response = self.client.patch(
            "/notifications/read-all",
            headers=self.auth_headers(),
        )

        body = response.get_json()
        self.assertEqual(response.status_code, 200)
        self.assertTrue(body["success"])
        self.assertTrue(execute_on_db.called)

    @patch("app.executeOnDB", return_value=True)
    def test_notification_setting_can_be_updated(self, execute_on_db):
        response = self.client.put(
            "/settings/notifications",
            headers=self.auth_headers(),
            json={"notifications_enabled": False},
        )

        body = response.get_json()
        self.assertEqual(response.status_code, 200)
        self.assertTrue(body["success"])
        self.assertFalse(body["notifications_enabled"])
        self.assertTrue(execute_on_db.called)

    @patch("app.executeOnDB", return_value=True)
    @patch("app.queryDB")
    def test_join_chatroom_adds_user_to_room(self, query_db, execute_on_db):
        query_db.side_effect = [
            [],
            [(self.chatroom_id, "Coffee Shop")],
        ]

        response = self.client.post(
            "/chatrooms/join",
            headers=self.auth_headers(),
            json={"chatroom_id": self.chatroom_id},
        )

        body = response.get_json()
        self.assertEqual(response.status_code, 200)
        self.assertTrue(body["success"])
        self.assertEqual(body["data"]["chatroom_name"], "Coffee Shop")
        self.assertTrue(execute_on_db.called)

    @patch("app.queryDB")
    def test_locational_chatrooms_return_map_data(self, query_db):
        query_db.return_value = [
            (
                self.chatroom_id,
                "Guildhall Square",
                "50.7990,-1.0920   ",
                "50.7980,-1.0910   ",
                self.user_id,
            )
        ]

        response = self.client.get(
            "/chatrooms/locational",
            headers=self.auth_headers(),
        )

        body = response.get_json()
        self.assertEqual(response.status_code, 200)
        self.assertTrue(body["success"])
        self.assertEqual(body["data"][0]["chatroom_name"], "Guildhall Square")
        self.assertEqual(body["data"][0]["coords_top_left"], "50.7990,-1.0920")
        self.assertEqual(body["data"][0]["author_id"], self.user_id)

    @patch("app.executeOnDB", return_value=True)
    @patch("app.queryDB")
    def test_create_locational_chatroom_saves_coordinates(
        self, query_db, execute_on_db
    ):
        query_db.return_value = [(self.chatroom_id,)]

        response = self.client.post(
            "/chatrooms/locational",
            headers=self.auth_headers(),
            json={
                "chatroom_name": "Harbour Chat",
                "coords_top_left": "50.8050,-1.1000",
                "coords_bottom_right": "50.7950,-1.0900",
            },
        )

        body = response.get_json()
        self.assertEqual(response.status_code, 201)
        self.assertTrue(body["success"])
        self.assertEqual(body["data"]["chatroom_id"], self.chatroom_id)
        self.assertTrue(execute_on_db.called)


if __name__ == "__main__":
    unittest.main()
