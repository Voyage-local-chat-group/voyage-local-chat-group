import 'package:flutter/material.dart';
import '../palette.dart';
import '../widgets/navigation_bars.dart';

class MapScreen extends StatefulWidget {
    const MapScreen({super.key});

    @override
    State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
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
                        Container(
                            constraints: const BoxConstraints.expand(height: 200),
                            child: Image.asset("assets/images/placeholder.png", fit: BoxFit.cover),
                        ),
                        Container(
                            color: Colors.white,
                            child: const Text("Map"),
                        ),
                    ],
                ),
            ),
        );
    }
}