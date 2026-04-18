import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
    const SettingsScreen({super.key});

    @override
    State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
    bool _notificationsEnabled = true;

    @override
    Widget build(BuildContext context) {
        return Column(
            children: [
                Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                        'Settings',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                        ),
                    ),
                ),
                Expanded(
                    child: ValueListenableBuilder<ThemeMode>(
                        valueListenable: themeNotifier,
                        builder: (context, currentMode, _) {
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
                                                    themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
                                                    final prefs = await SharedPreferences.getInstance();
                                                    await prefs.setBool('is_dark_mode', value);
                                                },
                                            ),
                                            const Divider(),
                                            SwitchListTile(
                                                title: const Text('Notifications'),
                                                subtitle: const Text('Receive push notifications'),
                                                value: _notificationsEnabled,
                                                onChanged: (bool value) {
                                                    setState(() {
                                                        _notificationsEnabled = value;
                                                    });
                                                },
                                            ),
                                            const Divider(),
                                            ListTile(
                                                title: const Text('Account Settings'),
                                                leading: const Icon(Icons.person),
                                                trailing: const Icon(Icons.chevron_right),
                                                onTap: () {},
                                            ),
                                            const Divider(),
                                            ListTile(
                                                title: const Text('Privacy & Security'),
                                                leading: const Icon(Icons.lock),
                                                trailing: const Icon(Icons.chevron_right),
                                                onTap: () {},
                                            ),
                                        ],
                                    );
                                }
                            );
                        },
                    ),
                ),
            ],
        );
    }
}