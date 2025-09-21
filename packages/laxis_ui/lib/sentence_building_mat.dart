import 'package:flutter/material.dart';
import 'card_widget.dart';

class SentenceBuildingMat extends StatefulWidget {
  const SentenceBuildingMat({super.key, this.onCorrect, required this.solution});

  final VoidCallback? onCorrect;
  final List<String> solution;

  @override
  State<SentenceBuildingMat> createState() => _SentenceBuildingMatState();
}

class _SentenceBuildingMatState extends State<SentenceBuildingMat> {
  final List<String> _cards = [];
  bool? _isCorrect;

  void _checkAnswer() {
    bool isCorrect = true;
    if (_cards.length != widget.solution.length) {
      isCorrect = false;
    } else {
      for (int i = 0; i < _cards.length; i++) {
        if (_cards[i] != widget.solution[i]) {
          isCorrect = false;
          break;
        }
      }
    }
    setState(() {
      _isCorrect = isCorrect;
    });
    if (isCorrect) {
      widget.onCorrect?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DragTarget<String>(
          onAccept: (data) {
            setState(() {
              _cards.add(data);
              _isCorrect = null;
            });
          },
          builder: (context, candidateData, rejectedData) {
            return Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: List.generate(_cards.length, (index) {
                    final text = _cards[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(text),
                          const SizedBox(width: 6),
                          IconButton(
                            icon: const Icon(Icons.arrow_left, size: 18),
                            tooltip: 'Move left',
                            onPressed: index > 0
                                ? () {
                                    setState(() {
                                      final item = _cards.removeAt(index);
                                      _cards.insert(index - 1, item);
                                      _isCorrect = null;
                                    });
                                  }
                                : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_right, size: 18),
                            tooltip: 'Move right',
                            onPressed: index < _cards.length - 1
                                ? () {
                                    setState(() {
                                      final item = _cards.removeAt(index);
                                      _cards.insert(index + 1, item);
                                      _isCorrect = null;
                                    });
                                  }
                                : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            tooltip: 'Remove',
                            onPressed: () {
                              setState(() {
                                _cards.removeAt(index);
                                _isCorrect = null;
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: _checkAnswer,
              child: const Text('Submit'),
            ),
            if (_isCorrect != null)
              Icon(
                _isCorrect! ? Icons.check : Icons.close,
                color: _isCorrect! ? Colors.green : Colors.red,
              ),
          ],
        ),
      ],
    );
  }
}
