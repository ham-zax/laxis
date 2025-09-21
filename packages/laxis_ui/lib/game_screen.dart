import 'package:flutter/material.dart';
import 'package:laxis_engine/laxis_engine.dart';
import 'package:german_language_module/german_language_module.dart';
import 'package:language_module_interface/language_module_interface.dart' as lmi;
import 'quest_widget.dart';
import 'sentence_building_mat.dart';
import 'card_widget.dart';
import 'dictionary_screen.dart';
import 'package:core/core.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.level});

  final String level;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final LaxisEngine _engine;
  lmi.Quest? _currentQuest;
  List<lmi.Card> _availableCards = [];
  Set<String> _usedCardIds = {};

  @override
  void initState() {
    super.initState();
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

  void _loadNextQuest() {
    setState(() {
      _currentQuest = _engine.getNextQuest(widget.level);
      _usedCardIds.clear();
      if (_currentQuest != null) {
        _availableCards = _engine.getCardsForQuest(_currentQuest!);
      }
    });
  }

  void _onQuestCompleted() {
    if (_currentQuest != null) {
      _engine.completeQuest(_currentQuest!.id, widget.level);
      _loadNextQuest();
    }
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
        final card = _engine.languageModuleData!.cards
            .firstWhere((c) => c.id == cardId);
        return card.text;
      } catch (e) {
        return 'Unknown';
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laxis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.book),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => DictionaryScreen(
                  unlockedConcepts: _engine.getUnlockedConcepts(),
                ),
              ));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _currentQuest == null
            ? const Center(child: Text('You have completed all quests!'))
            : Column(
                children: [
                  QuestWidget(prompt: _currentQuest!.prompt),
                  const SizedBox(height: 20),
                  SentenceBuildingMat(
                    onCorrect: _onQuestCompleted,
                    solution: _currentQuest!.solution,
                    onCardUsed: _onCardUsed,
                    onCardRemoved: _onCardRemoved,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Cards:',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Solution Preview: ${_getSolutionTexts().join(" ")}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: _availableCards.map((card) {
                                final isUsed = _usedCardIds.contains(card.id);
                                return DraggableCardWidget(
                                  cardId: card.id,
                                  text: card.text,
                                  isUsed: isUsed,
                                  onDragStarted: () {
                                    // Optional: Add haptic feedback
                                  },
                                  onDragEnd: () {
                                    // Optional: Add completion feedback
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
