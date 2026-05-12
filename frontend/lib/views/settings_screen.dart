import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'account_settings_screen.dart';
import 'privacy_security_screen.dart';
import '../main.dart';

// Screen for changing app settings.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Stores the local notification switch value.
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSetting();
  }

  Future<void> _loadNotificationSetting() async {
    // First load the saved phone setting, then ask the backend if possible.
    final prefs = await SharedPreferences.getInstance();
    final savedValue = prefs.getBool('notifications_enabled') ?? true;
    if (mounted) {
      setState(() {
        _notificationsEnabled = savedValue;
      });
    }

    final token = prefs.getString('jwt_token');
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('$backendURL/settings/notifications'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200 && mounted) {
        final body = jsonDecode(response.body);
        final backendValue = body['notifications_enabled'] ?? true;
        await prefs.setBool('notifications_enabled', backendValue);
        setState(() {
          _notificationsEnabled = backendValue;
        });
      }
    } catch (_) {
      // If the backend is not running, the saved local setting is still useful.
    }
  }

  Future<void> _updateNotificationSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);

    final token = prefs.getString('jwt_token');
    if (token == null) return;

    try {
      await http.put(
        Uri.parse('$backendURL/settings/notifications'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'notifications_enabled': value}),
      );
    } catch (_) {
      // The app keeps the local setting and can sync again later.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Settings',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, currentMode, _) {
              // Update the switch when the current theme changes.
              final isDarkMode = currentMode == ThemeMode.dark;
              return ValueListenableBuilder<Color>(
                valueListenable: colorNotifier,
                builder: (context, currentColor, _) {
                  return ListView(
                    children: [
                      SwitchListTile(
                        title: const Text('Dark Mode'),
                        subtitle: const Text('Toggle app appearance'),
                        value: isDarkMode,
                        onChanged: (bool value) async {
                          themeNotifier.value = value
                              ? ThemeMode.dark
                              : ThemeMode.light;
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('is_dark_mode', value);
                        },
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Notifications'),
                        subtitle: const Text('Receive push notifications'),
                        value: _notificationsEnabled,
                        onChanged: (bool value) async {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                          await _updateNotificationSetting(value);
                        },
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text('Account Settings'),
                        leading: const Icon(Icons.person),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => const AccountSettingsScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text('Privacy & Security'),
                        leading: const Icon(Icons.lock),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => const PrivacySecurityScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
