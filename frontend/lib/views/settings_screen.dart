import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
    const SettingsScreen({super.key});

    @override
    State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
    bool _notificationsEnabled = true;

    @override
    Widget build(BuildContext context) {
        return Column(
            children: [
                Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                        'Settings',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                        ),
                    ),
                ),
                Expanded(
                    child: ValueListenableBuilder<ThemeMode>(
                        valueListenable: themeNotifier,
                        builder: (context, currentMode, _) {
                            final isDarkMode = currentMode == ThemeMode.dark;
                            return ValueListenableBuilder<Color>(
                                valueListenable: colorNotifier,
                                builder: (context, currentColor, _) {
                                    return ListView(
                                        children: [
                                            SwitchListTile(
                                                title: const Text('Dark Mode'),
                                                subtitle: const Text('Toggle app appearance'),
                                                value: isDarkMode,
                                                onChanged: (bool value) async {
                                                    themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
                                                    final prefs = await SharedPreferences.getInstance();
                                                    await prefs.setBool('is_dark_mode', value);
                                                },
                                            ),
                                            const Divider(),
                                            Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                                child: Text(
                                                    'Theme Color',
                                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                        fontWeight: FontWeight.bold,
                                                    ),
                                                ),
                                            ),
                                            Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                                child: Wrap(
                                                    spacing: 16.0,
                                                    runSpacing: 16.0,
                                                    children: List.generate(appColorOptions.length, (index) {
                                                        final color = appColorOptions[index];
                                                        final isSelected = currentColor == color;
                                                        return GestureDetector(
                                                            onTap: () async {
                                                                colorNotifier.value = color;
                                                                final prefs = await SharedPreferences.getInstance();
                                                                await prefs.setInt('theme_color_index', index);
                                                            },
                                                            child: Container(
                                                                width: 48,
                                                                height: 48,
                                                                decoration: BoxDecoration(
                                                                    color: color,
                                                                    shape: BoxShape.circle,
                                                                    border: isSelected 
                                                                        ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 3) 
                                                                        : null,
                                                                    boxShadow: [
                                                                        BoxShadow(
                                                                            color: Colors.black.withOpacity(0.1),
                                                                            blurRadius: 4,
                                                                            offset: const Offset(0, 2),
                                                                        )
                                                                    ],
                                                                ),
                                                                child: isSelected 
                                                                    ? Icon(
                                                                        Icons.check, 
                                                                        color: ThemeData.estimateBrightnessForColor(color) == Brightness.dark ? Colors.white : Colors.black
                                                                      ) 
                                                                    : null,
                                                            ),
                                                        );
                                                    }),
                                                ),
                                            ),
                                            const SizedBox(height: 8),
                                            const Divider(),
                                            SwitchListTile(
                                                title: const Text('Notifications'),
                                                subtitle: const Text('Receive push notifications'),
                                                value: _notificationsEnabled,
                                                onChanged: (bool value) {
                                                    setState(() {
                                                        _notificationsEnabled = value;
                                                    });
                                                },
                                            ),
                                            const Divider(),
                                            ListTile(
                                                title: const Text('Account Settings'),
                                                leading: const Icon(Icons.person),
                                                trailing: const Icon(Icons.chevron_right),
                                                onTap: () {},
                                            ),
                                            const Divider(),
                                            ListTile(
                                                title: const Text('Privacy & Security'),
                                                leading: const Icon(Icons.lock),
                                                trailing: const Icon(Icons.chevron_right),
                                                onTap: () {},
                                            ),
                                        ],
                                    );
                                }
                            );
                        },
                    ),
                ),
            ],
        );
    }
}