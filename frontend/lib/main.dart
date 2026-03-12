import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'views/title_screen.dart';
import 'views/home_screen.dart';

const backendURL = "http://10.0.2.2:5000";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('jwt_token');

  runApp(MyApp(initialToken: token));
}

class MyApp extends StatelessWidget {
  final String? initialToken;
  const MyApp({super.key, this.initialToken});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: initialToken != null ? const HomeScreen() : const TitleScreen(),
    );
  }
}
