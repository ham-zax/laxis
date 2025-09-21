import 'dart:math';
import 'package:language_module_interface/language_module_interface.dart';
import 'package:core/core.dart';

extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

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
    final unlockedConcepts =
        _progress?.levelProgress[level]?.unlockedConceptIds ?? <String>{};
    
    // Get next available quest with proper difficulty progression
    final availableQuests = data.quests.where((quest) {
      // Skip completed quests
      if (completedQuests.contains(quest.id)) return false;
      
      // For first quest, allow any beginner quest
      if (completedQuests.isEmpty && quest.difficulty == 'beginner') {
        return true;
      }
      
      // Check if prerequisites are met (previous concepts unlocked)
      final hasPrerequisites = quest.conceptIds.any((conceptId) =>
          unlockedConcepts.contains(conceptId) ||
          _isFoundationalConcept(conceptId));
      
      return hasPrerequisites || completedQuests.isNotEmpty;
    }).toList();
    
    if (availableQuests.isEmpty) return null;
    
    // Sort by difficulty progression: beginner -> intermediate -> advanced
    availableQuests.sort((a, b) {
      final difficultyOrder = {'beginner': 0, 'intermediate': 1, 'advanced': 2};
      return (difficultyOrder[a.difficulty] ?? 0)
          .compareTo(difficultyOrder[b.difficulty] ?? 0);
    });
    
    return availableQuests.first;
  }

  bool _isFoundationalConcept(String conceptId) {
    // Basic concepts that don't require prerequisites
    const foundational = {'con1', 'con2', 'con3', 'con5', 'con6'};
    return foundational.contains(conceptId);
  }

  List<Card> getCardsForQuest(Quest quest) {
    if (languageModuleData == null) return [];
    
    // Get solution cards (correct answer)
    final solutionCards = quest.solution
        .map((id) => languageModuleData!.cards.where((c) => c.id == id).firstOrNull)
        .where((card) => card != null)
        .cast<Card>()
        .toList();

    // Get distractor cards from same concepts
    final questConcepts = quest.conceptIds.toSet();
    final distractorCards = languageModuleData!.cards
        .where((card) =>
            questConcepts.contains(card.conceptId) &&
            !quest.solution.contains(card.id))
        .take(3)  // Add up to 3 distractors
        .toList();

    // Add repetition cards from previously learned concepts
    final repetitionCards = _getRepetitionCards(quest, 2);

    // Combine and shuffle for challenge
    final allCards = [...solutionCards, ...distractorCards, ...repetitionCards];
    allCards.shuffle(Random());
    
    return allCards;
  }

  List<Card> _getRepetitionCards(Quest currentQuest, int maxCount) {
    final unlockedConcepts = _progress?.levelProgress.values
            .expand((lp) => lp.unlockedConceptIds)
            .toSet() ??
        {};

    if (unlockedConcepts.isEmpty) return [];

    // Smart repetition: prioritize concepts that haven't been seen recently
    final repetitionCards = <Card>[];
    final availableCards = languageModuleData!.cards
        .where((card) =>
            unlockedConcepts.contains(card.conceptId) &&
            !currentQuest.solution.contains(card.id) &&
            !currentQuest.conceptIds.contains(card.conceptId))
        .toList();

    availableCards.shuffle(Random());
    repetitionCards.addAll(availableCards.take(maxCount));

    return repetitionCards;
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
