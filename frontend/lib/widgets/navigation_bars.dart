import 'package:flutter/material.dart';
import '../palette.dart';
import '../views/profile_screen.dart';

class TopNavigationBar extends StatelessWidget {
  final VoidCallback? onProfileTap;

  const TopNavigationBar({
    super.key,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: primaryColour,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Local Chat App',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNavigationBarWidget extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const BottomNavigationBarWidget({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      backgroundColor: primaryColourPastel,
      indicatorColor: Colors.white,
      surfaceTintColor: Colors.white,
      shadowColor: const Color.fromARGB(255, 62, 56, 59),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: const <Widget>[
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.chat), label: 'Messages'),
        NavigationDestination(icon: Icon(Icons.notifications), label: 'Notifications'),
        NavigationDestination(
          selectedIcon: Icon(Icons.settings),
          icon: Icon(Icons.settings_outlined),
          label: 'Settings',
        ),
      ],
    );
  }
}