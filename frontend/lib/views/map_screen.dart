import 'package:flutter/material.dart';
import '../palette.dart';

class MapScreen extends StatefulWidget {
	const MapScreen({super.key});

	@override
	State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
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
        child:Column(
          children:[
            Container(
              // Imagine this is the map.
              constraints:BoxConstraints.expand(height:200),
              child:Image.asset("assets/images/placeholder.png",fit:BoxFit.cover)
            ),
            Container(
              color:Colors.white,
              child: Text("Map")
            ),
          ],
        ),
      ),
    );
  }
}