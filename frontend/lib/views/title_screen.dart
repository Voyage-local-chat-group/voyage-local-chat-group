import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'home_screen.dart';
import '../palette.dart';

class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  void _showLoginForm() {
    Navigator.of(context).push(DismissibleDialog<void>(isLogin: true));
  }

  void _placeholderCallbackForButtons() {
    Navigator.of(context).push(DismissibleDialog<void>(isLogin: false));
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      backgroundColor: Colors.white,
      disabledBackgroundColor: Colors.white,
      foregroundColor: const Color.fromARGB(255, 59, 52, 56),
      disabledForegroundColor: const Color.fromARGB(255, 73, 65, 70),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );

    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'VOYAGE',
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
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/voyage.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.white.withOpacity(0.1),
                          child: Icon(
                            Icons.chat_bubble_outline,
                            size: 50,
                            color: Colors.white.withOpacity(0.5),
                                               ),
                        );
                      },
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
  final bool isLogin;
  DismissibleDialog({required this.isLogin});

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
    return AuthDialogForm(isLogin: isLogin);
  }
}

class AuthDialogForm extends StatefulWidget {
  final bool isLogin;
  const AuthDialogForm({Key? key, required this.isLogin}) : super(key: key);

  @override
  _AuthDialogFormState createState() => _AuthDialogFormState();
}

class _AuthDialogFormState extends State<AuthDialogForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final url = widget.isLogin
        ? '$backendURL/users/login'
        : '$backendURL/users/register';

    try {
      final response = await http.post(
  Uri.parse(url),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'username': _usernameController.text,
    'password': _passwordController.text,
  }),
);
      final expectedCode = widget.isLogin ? 200 : 201;

      if (response.statusCode == expectedCode) {
  if (widget.isLogin) {
    debugPrint('LOGIN RESPONSE: ${response.body}');
    final data = jsonDecode(response.body);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', data['data']['token']);
          await prefs.setString('user_id', data['data']['user_id']);
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        } else {
          // Registration successful, log them in automatically
          final loginResponse = await http.post(
            Uri.parse('$backendURL/users/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': _usernameController.text,
              'password': _passwordController.text,
            }),
          );
          if (loginResponse.statusCode == 200) {
            final data = jsonDecode(loginResponse.body);
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('jwt_token', data['data']['token']);
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            }
          } else {
            setState(() {
              _errorMessage = 'Registered, but failed to auto-login.';
            });
          }
        }
      } else {
        setState(() {
          _errorMessage = widget.isLogin
              ? 'Invalid credentials'
              : 'Error registering';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().contains("get")
              ? "Rebuild your app! Hot restart needed for new plugins."
              : 'Network error occurred: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      // Provide DefaultTextStyle to ensure that the dialog's text style
      // matches the rest of the text in the app.
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyMedium!,
        // UnconstrainedBox is used to make the dialog size itself
        // fit to the size of the content, but let's give it a max width
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      widget.isLogin ? 'Login' : 'Sign Up',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(color: primaryColour),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Material(
                        child: TextField(
                          controller: _usernameController,
                          style: const TextStyle(color: darkGrey),
                          cursorColor: primaryColour,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            labelStyle: const TextStyle(
                              color: primaryColourShadow,
                            ),
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
                      width: double.infinity,
                      height: 50,
                      child: Material(
                        child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(color: darkGrey),
                          cursorColor: primaryColour,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: const TextStyle(
                              color: primaryColourShadow,
                            ),
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
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          backgroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[200],
                          foregroundColor: primaryColour,
                          disabledForegroundColor: Colors.grey,
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(),
                              )
                            : const Text('Confirm'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
