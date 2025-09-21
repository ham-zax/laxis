class LanguageModuleData {
  final String id;
  final String name;
  final List<Quest> quests;
  final List<Concept> concepts;
  final List<Card> cards;

  LanguageModuleData({
    required this.id,
    required this.name,
    required this.quests,
    required this.concepts,
    required this.cards,
  });

  factory LanguageModuleData.fromJson(Map<String, dynamic> json) {
    return LanguageModuleData(
      id: json['id'],
      name: json['name'],
      quests: (json['quests'] as List).map((q) => Quest.fromJson(q)).toList(),
      concepts: (json['concepts'] as List).map((c) => Concept.fromJson(c)).toList(),
      cards: (json['cards'] as List).map((c) => Card.fromJson(c)).toList(),
    );
  }
}

class Quest {
  final String id;
  final String prompt;
  final List<String> solution;
  final List<String> conceptIds;

  Quest({
    required this.id,
    required this.prompt,
    required this.solution,
    required this.conceptIds,
  });

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'],
      prompt: json['prompt'],
      solution: List<String>.from(json['solution']),
      conceptIds: List<String>.from(json['conceptIds']),
    );
  }
}

class Concept {
  final String id;
  final String name;
  final String explanation;

  Concept({
    required this.id,
    required this.name,
    required this.explanation,
  });

  factory Concept.fromJson(Map<String, dynamic> json) {
    return Concept(
      id: json['id'],
      name: json['name'],
      explanation: json['explanation'],
    );
  }
}

class Card {
  final String id;
  final String text;
  final String conceptId;

  Card({
    required this.id,
    required this.text,
    required this.conceptId,
  });

  factory Card.fromJson(Map<String, dynamic> json) {
    return Card(
      id: json['id'],
      text: json['text'],
      conceptId: json['conceptId'],
    );
  }
}

class Progress {
  final String userId;
  final Map<String, LevelProgress> levelProgress;

  Progress({
    required this.userId,
    required this.levelProgress,
  });

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      userId: json['userId'],
      levelProgress: (json['levelProgress'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, LevelProgress.fromJson(value)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'levelProgress': levelProgress.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    };
  }
}

class LevelProgress {
  final List<String> completedQuestIds;
  final Set<String> unlockedConceptIds;

  LevelProgress({
    required this.completedQuestIds,
    required this.unlockedConceptIds,
  });

  factory LevelProgress.fromJson(Map<String, dynamic> json) {
    return LevelProgress(
      completedQuestIds: List<String>.from(json['completedQuestIds']),
      unlockedConceptIds: Set<String>.from(json['unlockedConceptIds']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completedQuestIds': completedQuestIds,
      'unlockedConceptIds': unlockedConceptIds.toList(),
    };
  }
}
