import 'package:flutter/material.dart';
import '../palette.dart';

class MessagesScreen extends StatefulWidget {
	const MessagesScreen({super.key});

	@override
	State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
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
      body: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children:
          [
            Text('Messages screen :thumbsup:'),
            ListView(
              children: List<Widget>.generate(
                3,
                (int index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Text('Message')
                  ),
                ),
              ),
            )
          ]
          )
        )
    );
  }
}