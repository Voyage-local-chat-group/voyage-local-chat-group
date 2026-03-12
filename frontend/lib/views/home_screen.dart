import 'package:flutter/material.dart';
import '../palette.dart';
import '../widgets/navigation_bars.dart';
import './map_screen.dart';
import './messages_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _carouselController = PageController(
    viewportFraction: 0.9,
  );
  int _selectedNavIndex = 0;

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

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
            TopNavigationBar(onProfileTap: () {}),
            Expanded(
              child: IndexedStack(
                index: _selectedNavIndex,
                children: [
                  const MapScreen(),
                  const MessagesScreen(),
                  const Center(
                    child: Text(
                      'Notifications screen',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Settings screen',
                      style: TextStyle(fontSize: 18),
                    ),
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
