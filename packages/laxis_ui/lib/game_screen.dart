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
  List<lmi.Card> _cards = [];

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
      if (_currentQuest != null) {
        _cards = _engine.getCardsForQuest(_currentQuest!);
      }
    });
  }

  void _onQuestCompleted() {
    if (_currentQuest != null) {
      _engine.completeQuest(_currentQuest!.id, widget.level);
      _loadNextQuest();
    }
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
                  SentenceBuildingMat(onCorrect: _onQuestCompleted, solution: _currentQuest!.solution.map((id) => _engine.languageModuleData!.cards.firstWhere((c) => c.id == id).text).toList()),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: _cards.map((card) {
                      return Draggable<String>(
                        data: card.text,
                        feedback: CardWidget(text: card.text),
                        childWhenDragging: const SizedBox(),
                        child: CardWidget(text: card.text),
                      );
                    }).toList(),
                  ),
                ],
              ),
      ),
    );
  }
}
