import 'package:flutter/material.dart';
import 'package:laxis_ui/laxis_ui.dart';

void main() {
  runApp(const LaxisApp());
}

class LaxisApp extends StatelessWidget {
  const LaxisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laxis - Language Learning Game',
      theme: AppTheme.lightTheme,
      home: const LevelSelectionScreenOverhauled(),
      debugShowCheckedModeBanner: false,
    );
  }
}
