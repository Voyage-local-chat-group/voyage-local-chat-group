import 'package:flutter/material.dart';

import 'home_screen.dart';
import '../palette.dart';

class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  void _showLoginForm() {
    Navigator.of(context).push(DismissibleDialog<void>());
  }

  void _placeholderCallbackForButtons() {}

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      backgroundColor: Colors.white,
      disabledBackgroundColor: Colors.white,
      foregroundColor: primaryColour,
      disabledForegroundColor: primaryColour,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );

    return Scaffold(
      backgroundColor: primaryColourShadow,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DismissibleDialog<T> extends PopupRoute<T> {
  @override
  Color? get barrierColor => Colors.black.withAlpha(0x50);

  // This allows the popup to be dismissed by tapping the scrim or by pressing
  // the escape key on the keyboard.
  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Dismissible Dialog';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Center(
      // Provide DefaultTextStyle to ensure that the dialog's text style
      // matches the rest of the text in the app.
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyMedium!,
        // UnconstrainedBox is used to make the dialog size itself
        // to fit to the size of the content.
        child: UnconstrainedBox(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Column(
              children: <Widget>[
                Text(
                  'Login',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: primaryColour),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 300,
                  height: 50,
                  child: Material(
                    child: TextField(
                      style: const TextStyle(color: darkGrey),
                      cursorColor: primaryColour,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: const TextStyle(color: primaryColourShadow),
                        filled: true,
                        fillColor: primaryColourPastel,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: primaryColour.withValues(alpha: 0.6),
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColour),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 300,
                  height: 50,
                  child: Material(
                    child: TextField(
                      obscureText: true,
                      style: const TextStyle(color: darkGrey),
                      cursorColor: primaryColour,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: primaryColourShadow),
                        filled: true,
                        fillColor: primaryColourPastel,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: primaryColour.withValues(alpha: 0.6),
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColour),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const HomeScreen(),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor: Colors.white,
                      disabledBackgroundColor: Colors.white,
                      foregroundColor: primaryColour,
                      disabledForegroundColor: primaryColour,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Confirm'),
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
