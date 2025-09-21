import 'package:flutter/material.dart';
import 'package:language_module_interface/language_module_interface.dart';

class DictionaryScreen extends StatelessWidget {
  const DictionaryScreen({super.key, required this.unlockedConcepts});

  final List<Concept> unlockedConcepts;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dictionary'),
      ),
      body: ListView.builder(
        itemCount: unlockedConcepts.length,
        itemBuilder: (context, index) {
          final concept = unlockedConcepts[index];
          return ListTile(
            title: Text(concept.name),
            subtitle: Text(concept.explanation),
          );
        },
      ),
    );
  }
}
