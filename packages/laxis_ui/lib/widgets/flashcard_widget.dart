import 'package:flutter/material.dart';

/// Simple flip-style flashcard widget for quick reviews.
/// - `front` shown initially, tap flips to `back`.
/// - `onMarked` called with true/false when user marks correct/incorrect.
class FlashcardWidget extends StatefulWidget {
  final String front;
  final String? back;
  final void Function(bool correct)? onMarked;

  const FlashcardWidget({
    super.key,
    required this.front,
    this.back,
    this.onMarked,
  });

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  bool _flipped = false;
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _anim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    setState(() {
      _flipped = !_flipped;
      if (_flipped) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final frontCard = _buildCard(widget.front);
    final backCard = _buildCard(widget.back ?? '');

    return Column(
      children: [
        GestureDetector(
          onTap: _toggleFlip,
          child: AnimatedBuilder(
            animation: _anim,
            builder: (context, child) {
              final v = _anim.value;
              final angle = v * 3.1416;
              final transform = Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle);
              return Transform(
                transform: transform,
                alignment: Alignment.center,
                child: v <= 0.5 ? frontCard : Transform(
                  transform: Matrix4.identity()..rotateY(3.1416),
                  alignment: Alignment.center,
                  child: backCard,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => widget.onMarked?.call(false),
              icon: const Icon(Icons.close),
              label: const Text('Again'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => widget.onMarked?.call(true),
              icon: const Icon(Icons.check),
              label: const Text('Good'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(String text) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12)],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}