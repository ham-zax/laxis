import 'package:flutter/material.dart';
import 'conjugation_widget.dart';

class CardWidget extends StatefulWidget {
  const CardWidget({
    super.key,
    required this.text,
    this.isDraggable = true,
    this.isUsed = false,
    this.onDragStarted,
    this.onDragEnd,
  });

  final String text;
  final bool isDraggable;
  final bool isUsed;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnd;

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  @override
  Widget build(BuildContext context) {
    final cardWidget = GestureDetector(
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
        elevation: widget.isUsed ? 1.0 : 4.0,
        color: widget.isUsed ? Colors.grey[300] : null,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            widget.text,
            style: TextStyle(
              color: widget.isUsed ? Colors.grey[600] : null,
            ),
          ),
        ),
      ),
    );

    if (!widget.isDraggable || widget.isUsed) {
      return cardWidget;
    }

    return Draggable<String>(
      data: widget.text,
      onDragStarted: widget.onDragStarted,
      onDragEnd: (_) => widget.onDragEnd?.call(),
      feedback: Material(
        elevation: 6.0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue, width: 2),
          ),
          padding: const EdgeInsets.all(8.0),
          child: Text(
            widget.text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
      ),
      childWhenDragging: Card(
        elevation: 1.0,
        color: Colors.grey[200],
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            widget.text,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
      ),
      child: cardWidget,
    );
  }
}
