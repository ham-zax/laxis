import 'package:flutter/material.dart';
import 'conjugation_widget.dart';

class CardWidget extends StatefulWidget {
  const CardWidget({super.key, required this.text});

  final String text;

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        const toBeForms = {'bin', 'bist', 'ist', 'sind', 'seid'};
        if (toBeForms.contains(widget.text)) {
          showDialog(
            context: context,
            builder: (context) => const ConjugationWidget(),
          );
        }
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(widget.text),
        ),
      ),
    );
  }
}
