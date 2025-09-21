import 'package:flutter/material.dart';
import 'conjugation_widget.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({
    super.key,
    required this.text,
    this.isUsed = false,
    this.elevation,
    this.onTap,
  });

  final String text;
  final bool isUsed;
  final double? elevation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {
        const toBeForms = {'bin', 'bist', 'ist', 'sind', 'seid'};
        if (toBeForms.contains(text)) {
          showDialog(
            context: context,
            builder: (context) => const ConjugationWidget(),
          );
        }
      },
      child: Card(
        elevation: elevation ?? (isUsed ? 1.0 : 4.0),
        color: isUsed ? Colors.grey[300] : null,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            text,
            style: TextStyle(
              color: isUsed ? Colors.grey[600] : null,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class DraggableCardWidget extends StatefulWidget {
  const DraggableCardWidget({
    super.key,
    required this.cardId,
    required this.text,
    this.isUsed = false,
    this.onDragStarted,
    this.onDragEnd,
  });

  final String cardId;
  final String text;
  final bool isUsed;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnd;

  @override
  State<DraggableCardWidget> createState() => _DraggableCardWidgetState();
}

class _DraggableCardWidgetState extends State<DraggableCardWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.isUsed) {
      return CardWidget(
        text: widget.text,
        isUsed: true,
      );
    }

    return Draggable<Map<String, String>>(
      data: {'id': widget.cardId, 'text': widget.text},
      onDragStarted: widget.onDragStarted,
      onDragEnd: (_) => widget.onDragEnd?.call(),
      feedback: Material(
        elevation: 8.0,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue, width: 2),
          ),
          child: Text(
            widget.text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              fontSize: 16,
            ),
          ),
        ),
      ),
      childWhenDragging: CardWidget(
        text: widget.text,
        elevation: 1.0,
        onTap: () {}, // Disable tap when dragging
      ),
      child: CardWidget(text: widget.text),
    );
  }
}
