import 'package:flutter/material.dart';
import '../widgets/navigation_bars.dart';
import '../palette.dart';

class NotificationsScreen extends StatefulWidget {
    const NotificationsScreen({super.key});

    @override
    State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
    int _selectedNavIndex = 2;

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
                        const Expanded(
                            child: Center(
                                child: Text('Notifications screen'),
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}