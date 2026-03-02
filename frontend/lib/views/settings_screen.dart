import 'package:flutter/material.dart';
import '../widgets/navigation_bars.dart';
import '../palette.dart';

class SettingsScreen extends StatefulWidget {
    const SettingsScreen({super.key});

    @override
    State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
    int _selectedNavIndex = 3;
    bool _notificationsEnabled = true;

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: offWhite,
            bottomNavigationBar: BottomNavigationBarWidget(
                selectedIndex: _selectedNavIndex,
                onDestinationSelected: (index) {
                    setState(() {
                        _selectedNavIndex = index;
                    });
                },
            ),
            body: SafeArea(
                child: Column(
                    children: [
                        TopNavigationBar(
                            onProfileTap: () {
                                // Navigate to profile
                            },
                        ),
                        Container(
                            padding: const EdgeInsets.all(16.0),
                            child: const Text(
                                'Settings',
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                        ),
                        Expanded(
                            child: ListView(
                                children: [
                                    ListTile(
                                        title: const Text('Notifications'),
                                        trailing: Switch(
                                            value: _notificationsEnabled,
                                            onChanged: (bool value) {
                                                setState(() {
                                                    _notificationsEnabled = value;
                                                });
                                            },
                                        ),
                                    ),
                                    ListTile(
                                        title: const Text('Account Settings'),
                                        onTap: () {
                                        },
                                    ),
                                    ListTile(
                                        title: const Text('Privacy Settings'),
                                        onTap: () {
                                        },
                                    ),
                                ],
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}