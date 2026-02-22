import 'package:flutter/material.dart';
import '../palette.dart';

class ProfileScreen extends StatefulWidget {
	const ProfileScreen({super.key});

	@override
	State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
	final PageController _carouselController = PageController(viewportFraction: 0.9);

	@override
	void dispose() {
		_carouselController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {

		return Scaffold(
			backgroundColor: primaryColourShadow,

			bottomNavigationBar: NavigationBar(
				backgroundColor: primaryColour,
				indicatorColor: Colors.white,
				surfaceTintColor: Colors.white,
				shadowColor:primaryColourShadow,
				labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
				destinations: const <Widget>[
				NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
				NavigationDestination(icon: Icon(Icons.chat), label: 'Chatrooms'),
				NavigationDestination(icon: Icon(Icons.map), label: 'Map'),
				NavigationDestination(
					selectedIcon: Icon(Icons.settings),
					icon: Icon(Icons.settings_outlined),
					label: 'Settings',
				),
				],
			),
      body: Text('Profile screen :thumbsup:')
    );
  }
}