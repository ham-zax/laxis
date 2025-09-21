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
  final String? title;
  final String? difficulty;
  final int? points;

  Quest({
    required this.id,
    required this.prompt,
    required this.solution,
    required this.conceptIds,
    this.title,
    this.difficulty,
    this.points,
  });

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'],
      prompt: json['prompt'],
      solution: List<String>.from(json['solution']),
      conceptIds: List<String>.from(json['conceptIds']),
      title: json['title'],
      difficulty: json['difficulty'],
      points: json['points'],
    );
  }
}

class Concept {
  final String id;
  final String name;
  final String explanation;
  final String? category;
  final String? difficulty;
  final List<String>? examples;

  Concept({
    required this.id,
    required this.name,
    required this.explanation,
    this.category,
    this.difficulty,
    this.examples,
  });

  factory Concept.fromJson(Map<String, dynamic> json) {
    return Concept(
      id: json['id'],
      name: json['name'],
      explanation: json['explanation'],
      category: json['category'],
      difficulty: json['difficulty'],
      examples: json['examples'] != null
          ? List<String>.from(json['examples'])
          : null,
    );
  }
}

class Card {
  final String id;
  final String text;
  final String conceptId;
  final String? translation;
  final String? type;
  final bool hasConjugation;

  Card({
    required this.id,
    required this.text,
    required this.conceptId,
    this.translation,
    this.type,
    this.hasConjugation = false,
  });

  factory Card.fromJson(Map<String, dynamic> json) {
    return Card(
      id: json['id'],
      text: json['text'],
      conceptId: json['conceptId'],
      translation: json['translation'],
      type: json['type'],
      hasConjugation: json['type'] == 'verb' &&
                     (json['text']?.contains('bin') == true ||
                      json['text']?.contains('bist') == true ||
                      json['text']?.contains('ist') == true ||
                      json['text']?.contains('sind') == true ||
                      json['text']?.contains('seid') == true),
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
