import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'views/title_screen.dart';
import 'views/home_screen.dart';
import 'palette.dart';

const backendURL = "http://10.0.2.2:5000";
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

final List<Color> appColorOptions = [
  primaryColour, // 0: The original Pink
  Colors.indigo, // 1: Indigo
  Colors.teal, // 2: Teal
  Colors.deepPurple, // 3: Deep Purple
  Colors.amber, // 4: Amber
  Colors.deepOrange, // 5: Deep Orange
];
final ValueNotifier<Color> colorNotifier = ValueNotifier(appColorOptions[1]);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('jwt_token');

  final isDarkMode = prefs.getBool('is_dark_mode') ?? false;
  themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;

  final colorIndex = prefs.getInt('theme_color_index') ?? 1;
  if (colorIndex >= 0 && colorIndex < appColorOptions.length) {
    colorNotifier.value = appColorOptions[colorIndex];
  }

  runApp(MyApp(initialToken: token));
}

class MyApp extends StatelessWidget {
  final String? initialToken;
  const MyApp({super.key, this.initialToken});

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
              home: initialToken != null
                  ? const HomeScreen()
                  : const TitleScreen(),
            );
          },
        );
      },
    );
  }
}
