import 'package:flutter/material.dart';
import '../widgets/navigation_bars.dart';
import '../palette.dart';

class ProfileScreen extends StatefulWidget {
    const ProfileScreen({super.key});

    @override
    State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
    int _selectedNavIndex = 0;

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
                                child: Text('Profile screen'),
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}