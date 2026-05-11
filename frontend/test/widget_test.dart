import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';
import 'package:frontend/views/home_screen.dart';
import 'package:frontend/views/settings_screen.dart';
import 'package:frontend/views/title_screen.dart';
import 'package:frontend/widgets/navigation_bars.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> pumpTestApp(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(MaterialApp(home: child));
  }

  setUp(() {
    // SharedPreferences is used by the app to remember settings and login data.
    // In tests we use fake values so the tests do not need a real phone/browser.
    SharedPreferences.setMockInitialValues({});
    themeNotifier.value = ThemeMode.light;
    colorNotifier.value = appColorOptions[1];
  });

  group('Title screen', () {
    testWidgets('shows the app name and the two auth buttons', (tester) async {
      await pumpTestApp(tester, const TitleScreen());

      expect(find.text('VOYAGE'), findsOneWidget);
      expect(find.text('Log in'), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);
    });

    testWidgets('opens the login form when Log in is tapped', (tester) async {
      await pumpTestApp(tester, const TitleScreen());

      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
    });

    testWidgets('opens the sign up form when Sign up is tapped', (
      tester,
    ) async {
      await pumpTestApp(tester, const TitleScreen());

      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();

      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
    });

    testWidgets('allows the user to type username and password', (
      tester,
    ) async {
      await pumpTestApp(tester, const AuthDialogForm(isLogin: true));

      await tester.enterText(find.byType(TextField).at(0), 'alice');
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tester.pump();

      final usernameInput = tester.widget<EditableText>(
        find.byType(EditableText).at(0),
      );
      final passwordInput = tester.widget<EditableText>(
        find.byType(EditableText).at(1),
      );

      expect(usernameInput.controller.text, 'alice');
      expect(passwordInput.controller.text, 'password123');
    });
  });

  group('Navigation bars', () {
    testWidgets('bottom navigation shows all main app sections', (
      tester,
    ) async {
      await pumpTestApp(
        tester,
        Scaffold(
          bottomNavigationBar: BottomNavigationBarWidget(
            selectedIndex: 0,
            onDestinationSelected: (_) {},
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Messages'), findsOneWidget);
      expect(find.text('Map'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('bottom navigation calls the callback with selected index', (
      tester,
    ) async {
      var selectedIndex = 0;

      await pumpTestApp(
        tester,
        Scaffold(
          bottomNavigationBar: BottomNavigationBarWidget(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              selectedIndex = index;
            },
          ),
        ),
      );

      await tester.tap(find.text('Messages'));
      await tester.pump();

      expect(selectedIndex, 1);
    });

    testWidgets('top navigation shows the app name and profile icon', (
      tester,
    ) async {
      await pumpTestApp(tester, const Scaffold(body: TopNavigationBar()));

      expect(find.text('Voyage'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });
  });

  group('Home screen', () {
    testWidgets('shows location summary and nearby chatroom cards', (
      tester,
    ) async {
      await pumpTestApp(tester, const HomeScreen());
      await tester.pumpAndSettle();

      expect(find.text('Your Location'), findsOneWidget);
      expect(find.text('Portsmouth, UK'), findsOneWidget);
      expect(find.text('My Chatrooms'), findsOneWidget);
      expect(
        find.text('No chatrooms joined yet. Visit the map to join one!'),
        findsOneWidget,
      );
      expect(find.text('View Map'), findsOneWidget);
    });
  });

  group('Settings screen', () {
    testWidgets('shows the settings menu items', (tester) async {
      await pumpTestApp(tester, const Scaffold(body: SettingsScreen()));

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Account Settings'), findsOneWidget);
      expect(find.text('Privacy & Security'), findsOneWidget);
    });

    testWidgets('dark mode switch updates the app theme setting', (
      tester,
    ) async {
      await pumpTestApp(tester, const Scaffold(body: SettingsScreen()));

      expect(themeNotifier.value, ThemeMode.light);

      await tester.tap(find.text('Dark Mode'));
      await tester.pump();

      expect(themeNotifier.value, ThemeMode.dark);
    });

    testWidgets('dark mode choice is saved in SharedPreferences', (
      tester,
    ) async {
      await pumpTestApp(tester, const Scaffold(body: SettingsScreen()));

      await tester.tap(find.text('Dark Mode'));
      await tester.pump();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('is_dark_mode'), isTrue);
    });

    testWidgets('notifications switch can be turned off', (tester) async {
      await pumpTestApp(tester, const Scaffold(body: SettingsScreen()));

      Switch notificationSwitch() {
        return tester.widgetList<Switch>(find.byType(Switch)).elementAt(1);
      }

      expect(notificationSwitch().value, isTrue);

      await tester.tap(find.text('Notifications'));
      await tester.pump();

      expect(notificationSwitch().value, isFalse);
    });

    testWidgets('notifications choice is saved in SharedPreferences', (
      tester,
    ) async {
      await pumpTestApp(tester, const Scaffold(body: SettingsScreen()));

      await tester.tap(find.text('Notifications'));
      await tester.pump();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('notifications_enabled'), isFalse);
    });
  });
}
