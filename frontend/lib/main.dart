import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'views/title_screen.dart';
import 'views/home_screen.dart';
import 'palette.dart';

const backendURL = "http://127.0.0.1:5001";
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

final List<Color> appColorOptions = [
  primaryColour,
  Colors.indigo,
  Colors.teal,
  Colors.deepPurple,
  Colors.amber,
  Colors.deepOrange,
];
final ValueNotifier<Color> colorNotifier = ValueNotifier(appColorOptions[1]);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final isDarkMode = prefs.getBool('is_dark_mode') ?? false;
  themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;

  final colorIndex = prefs.getInt('theme_color_index') ?? 1;
  if (colorIndex >= 0 && colorIndex < appColorOptions.length) {
    colorNotifier.value = appColorOptions[colorIndex];
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: colorNotifier,
      builder: (_, Color currentColor, __) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (_, ThemeMode currentMode, __) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                brightness: Brightness.light,
                scaffoldBackgroundColor: offWhite,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: currentColor,
                  brightness: Brightness.light,
                  surface: Colors.white,
                ),
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: darkGrey,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: currentColor,
                  brightness: Brightness.dark,
                  surface: const Color.fromRGBO(40, 40, 40, 1),
                ),
                useMaterial3: true,
              ),
              themeMode: currentMode,
              // [已修改] App 的入口是 StartupGate，由它决定显示哪个页面
              home: const StartupGate(),
            );
          },
        );
      },
    );
  }
}

class StartupGate extends StatefulWidget {
  const StartupGate({super.key});

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (!mounted) return;

    if (token == null || token.isEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const TitleScreen()),
      );
      return;
    }

    final isValid = await _verifyToken(token);

    if (!mounted) return;

    if (isValid) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      await prefs.remove('jwt_token');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const TitleScreen()),
      );
    }
  }

  Future<bool> _verifyToken(String token) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 5);

    try {
      final request = await client.getUrl(Uri.parse('$backendURL/auth/verify'));
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      final response = await request.close();

      if (response.statusCode == 200) {
        return true;
      }

      debugPrint(
        'Token verification failed with status: ${response.statusCode}',
      );
      return false;
    } catch (e) {
      debugPrint('Token verification error: $e');
      return false;
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
