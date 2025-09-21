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
  final List<String> solution;
  final Function(String)? onCardUsed;
  final Function(String)? onCardRemoved;

  @override
  State<SentenceBuildingMat> createState() => _SentenceBuildingMatState();
}

class _SentenceBuildingMatState extends State<SentenceBuildingMat>
    with TickerProviderStateMixin {
  final List<String> _cards = [];
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
    } else {
      _shakeController.forward().then((_) => _shakeController.reverse());
    }
  }

  void _removeCard(int index) {
    final removedCard = _cards[index];
    setState(() {
      _cards.removeAt(index);
      _isCorrect = null;
    });
    widget.onCardRemoved?.call(removedCard);
  }

  void _clearAll() {
    final removedCards = List<String>.from(_cards);
    setState(() {
      _cards.clear();
      _isCorrect = null;
    });
    for (final card in removedCards) {
      widget.onCardRemoved?.call(card);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Drop target area
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: DragTarget<String>(
                onWillAccept: (data) {
                  setState(() => _isDragOver = true);
                  return data != null && !_cards.contains(data);
                },
                onLeave: (_) => setState(() => _isDragOver = false),
                onAccept: (data) {
                  setState(() {
                    _cards.add(data);
                    _isCorrect = null;
                    _isDragOver = false;
                  });
                  widget.onCardUsed?.call(data);
                },
                builder: (context, candidateData, rejectedData) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _isDragOver
                          ? Colors.blue[50]
                          : (_isCorrect == false ? Colors.red[50] : Colors.grey[200]),
                      border: Border.all(
                        color: _isDragOver
                            ? Colors.blue
                            : (_isCorrect == false ? Colors.red : Colors.grey),
                        width: _isDragOver ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _cards.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isDragOver
                                      ? Icons.add_circle_outline
                                      : Icons.drag_indicator,
                                  size: 48,
                                  color: _isDragOver
                                      ? Colors.blue
                                      : Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
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
                              ],
                            ),
                          )
                        : ReorderableListView.builder(
                            scrollDirection: Axis.horizontal,
                            buildDefaultDragHandles: false,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                            onReorder: (oldIndex, newIndex) {
                              setState(() {
                                if (newIndex > oldIndex) newIndex -= 1;
                                final item = _cards.removeAt(oldIndex);
                                _cards.insert(newIndex, item);
                                _isCorrect = null;
                              });
                            },
                            itemCount: _cards.length,
                            itemBuilder: (context, index) {
                              final text = _cards[index];
                              return Container(
                                key: ValueKey('mat_${text}_$index'),
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      text,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () => _removeCard(index),
                                      child: Icon(
                                        Icons.close,
                                        size: 18,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    ReorderableDragStartListener(
                                      index: index,
                                      child: Icon(
                                        Icons.drag_handle,
                                        size: 18,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
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
            if (_cards.isNotEmpty)
              TextButton(
                onPressed: _clearAll,
                child: const Text('Clear All'),
              ),
            ElevatedButton(
              onPressed: _cards.isNotEmpty ? _checkAnswer : null,
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
                        color: _isCorrect! ? Colors.green[800] : Colors.red[800],
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
