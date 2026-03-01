import 'package:flutter/material.dart';
import '../palette.dart';

class SettingsScreen extends StatefulWidget {
	const SettingsScreen({super.key});

	@override
	State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
	final PageController _carouselController = PageController(viewportFraction: 0.9);

bool _notificationsEnabled = true;

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
            body: SafeArea(
        child: Column(
          children: [
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