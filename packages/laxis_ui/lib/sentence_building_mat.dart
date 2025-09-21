import 'package:flutter/material.dart';
import 'card_widget.dart';

class SentenceBuildingMat extends StatefulWidget {
  const SentenceBuildingMat({
    super.key,
    this.onCorrect,
    required this.solution,
    this.onCardUsed,
    this.onCardRemoved,
  });

  final VoidCallback? onCorrect;
  final List<String> solution; // List of card IDs in correct order
  final Function(String cardId)? onCardUsed;
  final Function(String cardId)? onCardRemoved;

  @override
  State<SentenceBuildingMat> createState() => _SentenceBuildingMatState();
}

class _SentenceBuildingMatState extends State<SentenceBuildingMat>
    with TickerProviderStateMixin {
  final List<Map<String, String>> _placedCards = []; // {id, text}
  bool? _isCorrect;
  bool _isDragOver = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    if (_placedCards.length != widget.solution.length) {
      _setIncorrect();
      return;
    }

    // Check if placed cards match solution order by ID
    for (int i = 0; i < _placedCards.length; i++) {
      if (_placedCards[i]['id'] != widget.solution[i]) {
        _setIncorrect();
        return;
      }
    }

    // All cards are correct
    setState(() {
      _isCorrect = true;
    });

    // Clear the mat and return cards to available state
    Future.delayed(const Duration(milliseconds: 1000), () {
      _clearMatAndNotify();
      widget.onCorrect?.call();
    });
  }

  void _clearMatAndNotify() {
    final cardsToReturn = List<Map<String, String>>.from(_placedCards);
    setState(() {
      _placedCards.clear();
      _isCorrect = null;
    });
    // Notify parent to return all cards to available state
    for (final card in cardsToReturn) {
      widget.onCardRemoved?.call(card['id']!);
    }
  }

  void _setIncorrect() {
    setState(() {
      _isCorrect = false;
    });
    _shakeController.forward().then((_) => _shakeController.reverse());
  }

  void _removeCard(int index) {
    if (index >= 0 && index < _placedCards.length) {
      final removedCard = _placedCards[index];
      setState(() {
        _placedCards.removeAt(index);
        _isCorrect = null;
      });
      widget.onCardRemoved?.call(removedCard['id']!);
    }
  }

  void _clearAll() {
    final removedCards = List<Map<String, String>>.from(_placedCards);
    setState(() {
      _placedCards.clear();
      _isCorrect = null;
    });
    for (final card in removedCards) {
      widget.onCardRemoved?.call(card['id']!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Drop target area - Duolingo style sentence building
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: DragTarget<Map<String, String>>(
                onWillAcceptWithDetails: (details) {
                  setState(() => _isDragOver = true);
                  final data = details.data;
                  // Only accept if card is not already placed
                  return data['id'] != null &&
                      data['text'] != null &&
                      !_placedCards.any((card) => card['id'] == data['id']);
                },
                onLeave: (_) => setState(() => _isDragOver = false),
                onAcceptWithDetails: (details) {
                  final data = details.data;
                  // Double-check the card isn't already placed to prevent duplication
                  if (!_placedCards.any((card) => card['id'] == data['id'])) {
                    setState(() {
                      _placedCards.add(data);
                      _isCorrect = null;
                      _isDragOver = false;
                    });
                    widget.onCardUsed?.call(data['id']!);
                  } else {
                    setState(() => _isDragOver = false);
                  }
                },
                builder: (context, candidateData, rejectedData) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 80,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _isDragOver
                          ? Colors.blue[50]
                          : (_isCorrect == false
                              ? Colors.red[50]
                              : Colors.grey[100]),
                      border: Border.all(
                        color: _isDragOver
                            ? Colors.blue
                            : (_isCorrect == false
                                ? Colors.red
                                : Colors.grey[300]!),
                        width: _isDragOver ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _placedCards.isEmpty
                        ? Center(
                            child: Text(
                              _isDragOver
                                  ? 'Drop card here'
                                  : 'Drag cards here to build your sentence',
                              style: TextStyle(
                                color: _isDragOver
                                    ? Colors.blue
                                    : Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Center(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:
                                      _placedCards.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final card = entry.value;
                                    final text = card['text']!;

                                    return Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () => _removeCard(index),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.blue[50],
                                              border: Border.all(
                                                  color: Colors.blue[300]!,
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              text,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.blue[800],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        // Action buttons and feedback
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (_placedCards.isNotEmpty)
              TextButton(
                onPressed: _clearAll,
                child: const Text('Clear All'),
              ),
            ElevatedButton(
              onPressed: _placedCards.isNotEmpty ? _checkAnswer : null,
              child: const Text('Submit'),
            ),
            if (_isCorrect != null)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isCorrect! ? Colors.green[100] : Colors.red[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isCorrect! ? Icons.check_circle : Icons.error,
                      color: _isCorrect! ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isCorrect! ? 'Correct!' : 'Try again',
                      style: TextStyle(
                        color:
                            _isCorrect! ? Colors.green[800] : Colors.red[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
