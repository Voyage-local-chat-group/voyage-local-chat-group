import 'package:flutter/material.dart';
import '../palette.dart';
import '../widgets/navigation_bars.dart';

class MessagesScreen extends StatefulWidget {
	const MessagesScreen({super.key});

	@override
	State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  int _selectedNavIndex = 0;
	final PageController _carouselController = PageController(viewportFraction: 0.9);

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
            TopNavigationBar(
              onProfileTap: () {
                // Navigate to profile
              },
            ),
            const Expanded(
              child: Center(
                child: Text('To-Do: Put Messages Here'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}