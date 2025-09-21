import 'package:flutter/material.dart';
import 'package:laxis_engine/laxis_engine.dart';
import 'package:german_language_module/german_language_module.dart';
import 'package:language_module_interface/language_module_interface.dart'
    as lmi;
import 'package:core/core.dart';
import '../theme/app_theme.dart';
import '../widgets/feedback_widgets.dart';
import '../widgets/layout.dart';
import '../widgets/game_header.dart' show LessonProgressHeader;
import '../quest_widget.dart';
import '../sentence_building_mat.dart';
import '../card_widget.dart';
import '../dictionary_screen.dart';

class GameScreenOverhauled extends StatefulWidget {
  const GameScreenOverhauled({super.key, required this.level});

  final String level;

  @override
  State<GameScreenOverhauled> createState() => _GameScreenOverhauledState();
}

class _GameScreenOverhauledState extends State<GameScreenOverhauled>
    with TickerProviderStateMixin {
  late final LaxisEngine _engine;
  lmi.Quest? _currentQuest;
  List<lmi.Card> _availableCards = [];
  final Set<String> _usedCardIds = {};

  // Gamification state
  int _level = 5;
  String _levelTitle = 'Intermediate';
  int _currentQuestion = 1;
  int _totalQuestions = 8;

  // UI state
  // (no XP-related UI)
  bool _showFeedback = false;
  bool _lastAnswerCorrect = false;
  bool _pendingLevelComplete = false;

  // Animations
  late AnimationController _cardEntranceController;
  late Animation<double> _cardEntranceAnimation;

  @override
  void initState() {
    super.initState();
    _cardEntranceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _cardEntranceAnimation = CurvedAnimation(
      parent: _cardEntranceController,
      curve: Curves.easeOutBack,
    );

    _engine = LaxisEngine(
      languageModule: GermanLanguageModule(widget.level),
      progressService: ProgressService(),
    );
    _engine.loadModule().then((_) {
      _engine.loadProgress('user1').then((_) {
        _loadNextQuest();
      });
    });
  }

  @override
  void dispose() {
    _cardEntranceController.dispose();
    super.dispose();
  }

  void _loadNextQuest() {
    setState(() {
      _currentQuest = _engine.getNextQuest(widget.level);
      _usedCardIds.clear();
      if (_currentQuest != null) {
        _availableCards = _engine.getCardsForQuest(_currentQuest!);
        _shuffleCardsRandomly();
      }
    });

    // Animate cards entrance
    _cardEntranceController.reset();
    _cardEntranceController.forward();
  }

  void _shuffleCardsRandomly() {
    if (DateTime.now().millisecond % 10 < 3) {
      _availableCards.shuffle();
    }
  }

  void _onQuestCompleted() {
    if (_currentQuest != null) {
      _engine.completeQuest(_currentQuest!.id, widget.level);
      // Show correct overlay and decide next step on Continue
      setState(() {
        _lastAnswerCorrect = true;
        _showFeedback = true;
        _pendingLevelComplete = _currentQuestion >= _totalQuestions;
      });
    }
  }

  void _onIncorrect() {
    setState(() {
      _lastAnswerCorrect = false;
      _showFeedback = true;
    });
  }

  // XP awarding removed

  void _showLevelCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LevelCompleteDialog(
        level: _level,
        levelTitle: _levelTitle,
        onContinue: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop(); // Return to level selection
        },
      ),
    );
  }

  void _onCardUsed(String cardId) {
    setState(() {
      _usedCardIds.add(cardId);
    });
  }

  void _onCardRemoved(String cardId) {
    setState(() {
      _usedCardIds.remove(cardId);
    });
  }

  List<String> _getSolutionTexts() {
    if (_currentQuest == null || _engine.languageModuleData == null) {
      return [];
    }

    return _currentQuest!.solution.map((cardId) {
      try {
        final card =
            _engine.languageModuleData!.cards.firstWhere((c) => c.id == cardId);
        return card.text;
      } catch (e) {
        return 'Unknown';
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Stack(
        children: [
          Column(
            children: [
              // Minimal lesson top bar (solid background)
              LessonProgressHeader(
                lessonTitle: 'German Basics',
                currentQuestion: _currentQuestion,
                totalQuestions: _totalQuestions,
                onBack: () => Navigator.of(context).pop(),
                onPause: () {
                  // TODO: Show pause dialog
                },
              ),

              // Main Content
              Expanded(
                child: _currentQuest == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.emoji_events,
                              size: 80,
                              color: AppTheme.primaryGreen,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Congratulations!',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'You have completed all quests!',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Continue Learning'),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: CenteredContent(
                          maxWidth: 1100,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Quest Widget with enhanced styling
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Translate this sentence:',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            color: AppTheme.textSecondary,
                                          ),
                                    ),
                                    const SizedBox(height: 12),
                                    QuestWidget(prompt: _currentQuest!.prompt),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Sentence Building Mat
                              SentenceBuildingMat(
                                onCorrect: _onQuestCompleted,
                                solution: _currentQuest!.solution,
                                onCardUsed: _onCardUsed,
                                onCardRemoved: _onCardRemoved,
                                onIncorrect: _onIncorrect,
                              ),

                              const SizedBox(height: 24),

                              // Available Cards Section
                              SectionCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.style,
                                          color: AppTheme.primaryBlue,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Available Cards',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: AppTheme.textPrimary,
                                              ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 16),

                                    // Cards with staggered animation
                                    AnimatedBuilder(
                                      animation: _cardEntranceAnimation,
                                      builder: (context, child) {
                                        return Wrap(
                                          spacing: 10.0,
                                          runSpacing: 10.0,
                                          children: _availableCards
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            final index = entry.key;
                                            final card = entry.value;
                                            final isUsed =
                                                _usedCardIds.contains(card.id);

                                            // Staggered animation delay
                                            final delay = index * 0.1;
                                            final animationValue =
                                                (_cardEntranceAnimation.value -
                                                        delay)
                                                    .clamp(0.0, 1.0);

                                            return Transform.translate(
                                              offset: Offset(
                                                  0, (1 - animationValue) * 30),
                                              child: Opacity(
                                                opacity: animationValue,
                                                child: DraggableCardWidget(
                                                  cardId: card.id,
                                                  text: card.text,
                                                  isUsed: isUsed,
                                                  hasConjugation:
                                                      card.hasConjugation,
                                                  onDragStarted: () {
                                                    // Optional: Add haptic feedback
                                                  },
                                                  onDragEnd: () {
                                                    // Optional: Add completion feedback
                                                  },
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        );
                                      },
                                    ),

                                    // Debug info (can be removed in production)
                                    if (true) ...[
                                      const SizedBox(height: 16),
                                      const Divider(),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Solution: ${_getSolutionTexts().join(" ")}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppTheme.textHint,
                                              fontStyle: FontStyle.italic,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),

          // Non-blocking toast feedback
          if (_showFeedback)
            AnswerFeedback(
              isCorrect: _lastAnswerCorrect,
              correctAnswer: _lastAnswerCorrect ? null : _currentQuest?.solution.map((id) {
                try {
                  return _engine.languageModuleData!.cards
                      .firstWhere((c) => c.id == id)
                      .text;
                } catch (_) {
                  return 'Unknown';
                }
              }).join(' '),
              isVisible: true,
              onContinue: () {
                setState(() {
                  _showFeedback = false;
                });
                // Advance flow after feedback
                if (_lastAnswerCorrect) {
                  if (_pendingLevelComplete) {
                    _pendingLevelComplete = false;
                    _showLevelCompleteDialog();
                  } else {
                    setState(() {
                      _currentQuestion =
                          (_currentQuestion % _totalQuestions) + 1;
                    });
                    _loadNextQuest();
                  }
                }
              },
            ),
        ],
      ),

      // Floating Action Button for Dictionary
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => DictionaryScreen(
              unlockedConcepts: _engine.getUnlockedConcepts(),
            ),
          ));
        },
        backgroundColor: AppTheme.accentOrange,
        child: const Icon(Icons.book, color: Colors.white),
      ),
    );
  }
}