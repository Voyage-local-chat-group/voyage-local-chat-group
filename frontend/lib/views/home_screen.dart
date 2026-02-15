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

		return Scaffold(
			backgroundColor: backgroundColor,
			body: SafeArea(
				child: Center(
					child: Padding(
						padding: const EdgeInsets.symmetric(horizontal: 32.0),
						child: Column(
							mainAxisAlignment: MainAxisAlignment.center,
							crossAxisAlignment: CrossAxisAlignment.stretch,
							children: [
								const Text(
									'Local Chat App',
									textAlign: TextAlign.center,
									style: TextStyle(
										color: Colors.white,
										fontSize: 24,
										fontWeight: FontWeight.w700,
										letterSpacing: 1,
									),
								),
								const SizedBox(height: 16),
								Container(
									height: 140,
									width: 140,
									margin: const EdgeInsets.only(bottom: 40.0),
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
												fontSize: 20,
												letterSpacing: 2,
												fontWeight: FontWeight.w600,
											),
										),
									),
								),
							],
						),
					),
				),
			),
		);
	}
}