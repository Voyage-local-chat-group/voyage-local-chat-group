import 'package:flutter/material.dart';

import 'views/title_screen.dart';

const backendURL = "http://127.0.0.1:5000";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TitleScreen(),
    );
  }
}
