import 'package:flutter/material.dart';
import 'conjugation_widget.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({
    super.key,
    required this.text,
    this.isUsed = false,
    this.elevation,
    this.onTap,
    this.hasConjugation = false,
  });

  final String text;
  final bool isUsed;
  final double? elevation;
  final VoidCallback? onTap;
  final bool hasConjugation; // Language module determines this

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor:
          hasConjugation ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onTap ??
            () {
              // Only show conjugation if explicitly marked by language module
              if (hasConjugation) {
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: isUsed ? Colors.grey[600] : null,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (hasConjugation && !isUsed) ...[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.blue[600],
                  ),
                ],
              ],
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
    this.hasConjugation = false,
    this.onDragStarted,
    this.onDragEnd,
  });

  final String cardId;
  final String text;
  final bool isUsed;
  final bool hasConjugation;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnd;

  @override
  State<DraggableCardWidget> createState() => _DraggableCardWidgetState();
}

class _DraggableCardWidgetState extends State<DraggableCardWidget> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isUsed) {
      return CardWidget(
        text: widget.text,
        isUsed: true,
        hasConjugation: widget.hasConjugation,
      );
    }

    return MouseRegion(
      cursor:
          _isDragging ? SystemMouseCursors.grabbing : SystemMouseCursors.grab,
      child: Draggable<Map<String, String>>(
        data: {'id': widget.cardId, 'text': widget.text},
        onDragStarted: () {
          setState(() => _isDragging = true);
          widget.onDragStarted?.call();
        },
        onDragEnd: (_) {
          setState(() => _isDragging = false);
          widget.onDragEnd?.call();
        },
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
          hasConjugation: widget.hasConjugation,
          onTap: () {}, // Disable tap when dragging
        ),
        child: CardWidget(
          text: widget.text,
          hasConjugation: widget.hasConjugation,
        ),
      ),
    );
  }
}
