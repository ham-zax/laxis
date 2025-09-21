import 'package:flutter/material.dart';
import 'package:laxis_ui/laxis_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const LevelSelectionScreen(),
    );
  }
}
