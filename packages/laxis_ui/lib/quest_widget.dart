import 'package:flutter/material.dart';

class QuestWidget extends StatelessWidget {
  const QuestWidget({super.key, required this.prompt});

  final String prompt;

  @override
  Widget build(BuildContext context) {
    return Text(
      prompt,
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }
}
