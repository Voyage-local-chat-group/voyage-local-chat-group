import 'package:flutter/material.dart';

import '../palette.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Security')),
      body: ListView(
        children: const [
          SwitchListTile(
            secondary: Icon(Icons.visibility, color: primaryColour),
            title: Text('Show online status'),
            subtitle: Text('Allow other users to see when you are online'),
            value: true,
            onChanged: null,
          ),
          Divider(height: 1),
          SwitchListTile(
            secondary: Icon(Icons.location_on, color: primaryColour),
            title: Text('Share location'),
            subtitle: Text('Use location for nearby chatrooms'),
            value: true,
            onChanged: null,
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.block, color: primaryColour),
            title: Text('Blocked users'),
            subtitle: Text('Review users you have blocked'),
          ),
        ],
      ),
    );
  }
}
