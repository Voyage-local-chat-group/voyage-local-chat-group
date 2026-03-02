import 'package:flutter/material.dart';
import '../palette.dart';
import '../views/home_screen.dart';
import '../views/dm_list.dart';
import '../views/notifications_screen.dart';
import '../views/settings_screen.dart';
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

  void _navigateToScreen(BuildContext context, int index) {
    Widget screen;
    switch (index) {
      case 0:
        screen = const HomeScreen();
        break;
      case 1:
        screen = const DmList();
        break;
      case 2:
        screen = const NotificationsScreen();
        break;
      case 3:
        screen = const SettingsScreen();
        break;
      default:
        screen = const HomeScreen();
    }
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      backgroundColor: primaryColourPastel,
      indicatorColor: Colors.white,
      surfaceTintColor: Colors.white,
      shadowColor: primaryColourShadow,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        onDestinationSelected(index);
        _navigateToScreen(context, index);
      },
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