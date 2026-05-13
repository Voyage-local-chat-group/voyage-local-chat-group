import 'package:flutter/material.dart';

import '../palette.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Settings')),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.badge, color: primaryColour),
            title: Text('Profile details'),
            subtitle: Text('Manage your username, avatar, and bio'),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.email, color: primaryColour),
            title: Text('Email address'),
            subtitle: Text('Update your sign-in email'),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.password, color: primaryColour),
            title: Text('Password'),
            subtitle: Text('Change your account password'),
          ),
        ],
      ),
    );
  }
}
