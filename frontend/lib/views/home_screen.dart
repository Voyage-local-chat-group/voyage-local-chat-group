import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
	const HomeScreen({super.key});

	@override
	State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

	@override
	Widget build(BuildContext context) {
		const backgroundColor = Color(0xFF8B1E4B);
		const backgroundColorLite = Color.fromARGB(255, 223, 92, 147);

		return Scaffold(
			backgroundColor: backgroundColor,

			bottomNavigationBar: NavigationBar(
				backgroundColor: backgroundColorLite,
				indicatorColor: Colors.white,
				surfaceTintColor: Colors.white,
				shadowColor:backgroundColor,
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
					mainAxisAlignment: MainAxisAlignment.start,
					crossAxisAlignment: CrossAxisAlignment.center,
					children: [
						Padding(
							padding: const EdgeInsets.symmetric(horizontal: 32.0,vertical:8.0),
							child: Row(
								mainAxisAlignment: MainAxisAlignment.start,
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
									const SizedBox(width:8),
									Container(
										height: 48,
										width: 48,
										decoration: BoxDecoration(
											color: Colors.white.withValues(alpha: 0.12),
											shape: BoxShape.circle,
											border: Border.all(
												color: Colors.white.withValues(alpha: 0.24),
												width: 2,
											),
										),
										child: const Center(
											child: Text(
												'LOGO',
												style: TextStyle(
													color: Colors.white,
													fontSize: 8,
													letterSpacing: 2,
													fontWeight: FontWeight.w600,
												),
											),
										),
									),
								],
							),
						),
						Padding(
							padding: const EdgeInsets.symmetric(horizontal: 32.0),
							child: Center(
								child: Text(
									'Home Screen',
									textAlign: TextAlign.center,
									style: TextStyle(
										color: Colors.white,
										fontSize: 24,
										fontWeight: FontWeight.w700,
										letterSpacing: 1,
									),
								),
							),
						),
						],
					),
			),
		);
	}
}