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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LevelSelectionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
