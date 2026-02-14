import 'package:flutter/material.dart';

class TitleScreen extends StatefulWidget {
	const TitleScreen({super.key});

	@override
	State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
	bool _showLoginFields = false;

	void _showLoginForm() {
		setState(() {
			_showLoginFields = true;
		});
	}

	void _placeholderCallbackForButtons() {}

	@override
	Widget build(BuildContext context) {
		const backgroundColor = Color(0xFF8B1E4B);
		final buttonStyle = ElevatedButton.styleFrom(
			padding: const EdgeInsets.symmetric(vertical: 16.0),
			backgroundColor: Colors.white,
			disabledBackgroundColor: Colors.white,
			foregroundColor: backgroundColor,
			disabledForegroundColor: backgroundColor,
			textStyle: const TextStyle(
				fontSize: 16,
				fontWeight: FontWeight.w600,
			),
		);

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
								ElevatedButton(
									onPressed: _showLoginForm,
									style: buttonStyle,
									child: const Text('Log in'),
								),
								const SizedBox(height: 16),
								ElevatedButton(
									onPressed: _placeholderCallbackForButtons,
									style: buttonStyle,
									child: const Text('Sign up'),
								),
								if (_showLoginFields) ...[
									const SizedBox(height: 24),
									TextField(
										style: const TextStyle(color: Colors.white),
										decoration: InputDecoration(
											labelText: 'Username',
											labelStyle: const TextStyle(color: Colors.white),
											enabledBorder: OutlineInputBorder(
												borderSide: BorderSide(
													color: Colors.white.withValues(alpha: 0.6),
												),
											),
											focusedBorder: const OutlineInputBorder(
												borderSide: BorderSide(color: Colors.white),
											),
										),
									),
									const SizedBox(height: 12),
									TextField(
										obscureText: true,
										style: const TextStyle(color: Colors.white),
										decoration: InputDecoration(
											labelText: 'Password',
											labelStyle: const TextStyle(color: Colors.white),
											enabledBorder: OutlineInputBorder(
												borderSide: BorderSide(
													color: Colors.white.withValues(alpha: 0.6),
												),
											),
											focusedBorder: const OutlineInputBorder(
												borderSide: BorderSide(color: Colors.white),
											),
										),
									),
								],
							],
						),
					),
				),
			),
		);
	}
}