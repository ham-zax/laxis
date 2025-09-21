import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
// Feedback overlay is now handled at the screen level

class _PlacedCard extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _PlacedCard({
    required this.text,
    required this.onTap,
  });

  @override
  State<_PlacedCard> createState() => _PlacedCardState();
}

class _PlacedCardState extends State<_PlacedCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: AppTheme.errorRed.withOpacity(0.1),
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _hoverController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _colorAnimation.value,
                  border: Border.all(
                    color: _isHovered ? AppTheme.errorRed : AppTheme.borderLight,
                    width: _isHovered ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: _isHovered
                          ? AppTheme.errorRed.withOpacity(0.15)
                          : Colors.black.withOpacity(0.06),
                      blurRadius: _isHovered ? 8 : 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _isHovered ? AppTheme.errorRed : AppTheme.textPrimary,
                      ),
                    ),
                    if (_isHovered) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.close,
                        size: 16,
                        color: AppTheme.errorRed,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class SentenceBuildingMat extends StatefulWidget {
  const SentenceBuildingMat({
    super.key,
    this.onCorrect,
    required this.solution,
    this.onCardUsed,
    this.onCardRemoved,
    this.onIncorrect,
  });

  final VoidCallback? onCorrect;
  final List<String> solution; // List of card IDs in correct order
  final Function(String cardId)? onCardUsed;
  final Function(String cardId)? onCardRemoved;
  final VoidCallback? onIncorrect;

  @override
  State<SentenceBuildingMat> createState() => _SentenceBuildingMatState();
}

class _SentenceBuildingMatState extends State<SentenceBuildingMat>
    with TickerProviderStateMixin {
  final List<Map<String, String>> _placedCards = []; // {id, text}
  bool? _isCorrect;
  bool _isDragOver = false;
  late AnimationController _shakeController;
  late AnimationController _successController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _successAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _successController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
    _successAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _successController.dispose();
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
      _successController.forward();
  
      // Clear the mat and return cards to available state
      Future.delayed(const Duration(milliseconds: 2000), () {
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
      _successController.reset();
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
      // Notify parent to show feedback overlay
      widget.onIncorrect?.call();
  
      Future.delayed(const Duration(milliseconds: 2000), () {
        setState(() {
          _isCorrect = null;
        });
      });
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
    return Stack(
      children: [
        Column(
          children: [
            // Drop target area - Duolingo style sentence building
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_shakeAnimation.value, 0),
                  child: AnimatedBuilder(
                    animation: _successAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _successAnimation.value,
                        child: DragTarget<Map<String, String>>(
                          onWillAcceptWithDetails: (details) {
                            setState(() => _isDragOver = true);
                            final data = details.data;
                            // Only accept if card is not already placed
                            return data['id'] != null &&
                                data['text'] != null &&
                                !_placedCards
                                    .any((card) => card['id'] == data['id']);
                          },
                          onLeave: (_) => setState(() => _isDragOver = false),
                          onAcceptWithDetails: (details) {
                            final data = details.data;
                            if (!_placedCards
                                .any((card) => card['id'] == data['id'])) {
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
                            Color backgroundColor = AppTheme.backgroundLight;
                            Color borderColor = AppTheme.borderLight;

                            if (_isDragOver) {
                              backgroundColor =
                                  AppTheme.primaryBlue.withOpacity(0.05);
                              borderColor = AppTheme.primaryBlue;
                            } else if (_isCorrect == false) {
                              backgroundColor =
                                  AppTheme.errorRed.withOpacity(0.05);
                              borderColor = AppTheme.errorRed;
                            } else if (_isCorrect == true) {
                              backgroundColor =
                                  AppTheme.successGreen.withOpacity(0.05);
                              borderColor = AppTheme.successGreen;
                            }

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 72,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                border:
                                    Border.all(color: borderColor, width: 1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: _placedCards.isEmpty
                                  ? Center(
                                      child: Text(
                                        _isDragOver
                                            ? 'Drop card here'
                                            : 'Drag cards here to build your sentence',
                                        style: TextStyle(
                                          color: _isDragOver
                                              ? AppTheme.primaryBlue
                                              : AppTheme.textSecondary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: _placedCards
                                                .asMap()
                                                .entries
                                                .map((entry) {
                                              final index = entry.key;
                                              final card = entry.value;
                                              final text = card['text']!;

                                              return Container(
                                                margin: const EdgeInsets.only(right: 8),
                                                child: _PlacedCard(
                                                  text: text,
                                                  onTap: () => _removeCard(index),
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
                );
              },
            ),
            const SizedBox(height: 20),
            // Action buttons and feedback
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (_placedCards.isNotEmpty)
                  TextButton.icon(
                    onPressed: _clearAll,
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('Clear All'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      onPressed: _placedCards.isNotEmpty ? _checkAnswer : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        disabledBackgroundColor: AppTheme.borderLight,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Check Answer'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        // Feedback overlay removed; handled by parent screen
      ],
    );
  }
}
