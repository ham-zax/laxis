import 'package:flutter/material.dart';

class ConjugationWidget extends StatelessWidget {
  const ConjugationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Conjugate "to be"'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(onPressed: () {}, child: const Text('I am')),
          ElevatedButton(onPressed: () {}, child: const Text('You are')),
          ElevatedButton(onPressed: () {}, child: const Text('He/She/It is')),
        ],
      ),
    );
  }
}
