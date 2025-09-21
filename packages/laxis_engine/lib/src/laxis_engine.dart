import 'dart:math';
import 'package:language_module_interface/language_module_interface.dart';
import 'package:core/core.dart';

class LaxisEngine {
  final LanguageModule languageModule;
  final ProgressService progressService;
  LanguageModuleData? languageModuleData;
  Progress? _progress;

  LaxisEngine({required this.languageModule, required this.progressService});

  Future<void> loadModule() async {
    languageModuleData = await languageModule.load();
  }

  Future<void> loadProgress(String userId) async {
    _progress = await progressService.getProgress(userId);
    _progress ??= Progress(userId: userId, levelProgress: {});
  }

  void completeQuest(String questId, String level) {
    if (_progress?.levelProgress[level] == null) {
      _progress?.levelProgress[level] = LevelProgress(completedQuestIds: [], unlockedConceptIds: {});
    }
    _progress!.levelProgress[level]!.completedQuestIds.add(questId);
    final quest = languageModuleData?.quests.firstWhere((q) => q.id == questId);
    if (quest != null) {
      for (var conceptId in quest.conceptIds) {
        _progress!.levelProgress[level]!.unlockedConceptIds.add(conceptId);
      }
    }
    if (_progress != null) {
      progressService.saveProgress(_progress!);
    }
  }

  Quest? getNextQuest(String level) {
    final data = languageModuleData;
    if (data == null) return null;
    final completedQuests =
        _progress?.levelProgress[level]?.completedQuestIds ?? const <String>[];
    for (final q in data.quests) {
      if (!completedQuests.contains(q.id)) {
        return q;
      }
    }
    return null;
  }

  List<Card> getCardsForQuest(Quest quest) {
    final cards = languageModuleData?.cards
        .where((c) => quest.solution.contains(c.id))
        .toList();

    final unlockedConcepts = _progress?.levelProgress.values
            .expand((lp) => lp.unlockedConceptIds)
            .toSet() ??
        {};

    if (unlockedConcepts.isNotEmpty && Random().nextDouble() < 0.2) {
      final randomConceptId = unlockedConcepts.elementAt(
        Random().nextInt(unlockedConcepts.length),
      );
      final randomCard = languageModuleData?.cards
          .firstWhere((c) => c.conceptId == randomConceptId);
      if (randomCard != null && cards != null && !cards.contains(randomCard)) {
        cards.add(randomCard);
      }
    }

    return cards ?? [];
  }

  List<Concept> getUnlockedConcepts() {
    final unlockedConceptIds = _progress?.levelProgress.values
            .expand((lp) => lp.unlockedConceptIds)
            .toSet() ??
        {};
    return languageModuleData?.concepts
            .where((c) => unlockedConceptIds.contains(c.id))
            .toList() ??
        [];
  }
}
