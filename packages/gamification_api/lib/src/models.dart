/// Models for the gamification API.
///
/// These are simple, null-safe, JSON-serializable data classes used by
/// the gamification interfaces.
import 'dart:core';

/// A canonical identifier for gamification entities.
class GamificationId {
  /// The identifier string.
  final String id;

  /// Creates a [GamificationId].
  const GamificationId(this.id);

  /// Convert to JSON.
  Map<String, dynamic> toJson() => {'id': id};

  /// Create from JSON.
  factory GamificationId.fromJson(Map<String, dynamic> json) =>
      GamificationId(json['id'] as String);
}

/// Experience points.
class XP {
  /// XP value (must be >= 0).
  final int value;

  /// Creates XP, asserts [value] is non-negative.
  XP(this.value) : assert(value >= 0, 'XP value must be >= 0');

  /// Convert to JSON.
  Map<String, dynamic> toJson() => {'value': value};

  /// Create from JSON.
  factory XP.fromJson(Map<String, dynamic> json) =>
      XP((json['value'] as num).toInt());
}

/// Player level information.
class Level {
  /// Level number (e.g., 1, 2, ...).
  final int number;

  /// XP threshold required to reach this level.
  final int xpThreshold;

  /// Creates a [Level].
  const Level({required this.number, required this.xpThreshold});

  /// Convert to JSON.
  Map<String, dynamic> toJson() =>
      {'number': number, 'xpThreshold': xpThreshold};

  /// Create from JSON.
  factory Level.fromJson(Map<String, dynamic> json) => Level(
        number: (json['number'] as num).toInt(),
        xpThreshold: (json['xpThreshold'] as num).toInt(),
      );
}

/// An achievement earned by a user.
class Achievement {
  /// Achievement identifier.
  final String id;

  /// Human-readable title.
  final String title;

  /// Optional description.
  final String? description;

  /// When the achievement was achieved.
  final DateTime? achievedAt;

  /// Optional arbitrary metadata.
  final Map<String, dynamic>? metadata;

  /// Creates an [Achievement].
  const Achievement({
    required this.id,
    required this.title,
    this.description,
    this.achievedAt,
    this.metadata,
  });

  /// Convert to JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        if (description != null) 'description': description,
        if (achievedAt != null) 'achievedAt': achievedAt!.toIso8601String(),
        if (metadata != null) 'metadata': metadata,
      };

  /// Create from JSON.
  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        achievedAt: json['achievedAt'] != null
            ? DateTime.parse(json['achievedAt'] as String)
            : null,
        metadata: (json['metadata'] as Map?)?.cast<String, dynamic>(),
      );
}

/// Progress for an individual quest.
class QuestProgress {
  /// Quest identifier.
  final String questId;

  /// Whether the quest is completed.
  final bool completed;

  /// When the quest was completed.
  final DateTime? completedAt;

  /// Optional arbitrary metadata.
  final Map<String, dynamic>? metadata;

  /// Creates a [QuestProgress].
  const QuestProgress({
    required this.questId,
    required this.completed,
    this.completedAt,
    this.metadata,
  });

  /// Convert to JSON.
  Map<String, dynamic> toJson() => {
        'questId': questId,
        'completed': completed,
        if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
        if (metadata != null) 'metadata': metadata,
      };

  /// Create from JSON.
  factory QuestProgress.fromJson(Map<String, dynamic> json) => QuestProgress(
        questId: json['questId'] as String,
        completed: json['completed'] as bool,
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
        metadata: (json['metadata'] as Map?)?.cast<String, dynamic>(),
      );
}

/// Overall gamification progress for a user.
class GamificationProgress {
  /// Total XP accumulated.
  final XP totalXp;

  /// Current level.
  final Level currentLevel;

  /// Achievements earned.
  final List<Achievement> achievements;

  /// Quests progress.
  final List<QuestProgress> quests;

  /// When this progress was last updated.
  final DateTime updatedAt;

  /// Creates a [GamificationProgress].
  GamificationProgress({
    required this.totalXp,
    required this.currentLevel,
    required this.achievements,
    required this.quests,
    required this.updatedAt,
  });

  /// Convert to JSON.
  Map<String, dynamic> toJson() => {
        'totalXp': totalXp.toJson(),
        'currentLevel': currentLevel.toJson(),
        'achievements': achievements.map((a) => a.toJson()).toList(),
        'quests': quests.map((q) => q.toJson()).toList(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  /// Create from JSON.
  factory GamificationProgress.fromJson(Map<String, dynamic> json) =>
      GamificationProgress(
        totalXp:
            XP.fromJson((json['totalXp'] as Map).cast<String, dynamic>()),
        currentLevel:
            Level.fromJson((json['currentLevel'] as Map).cast<String, dynamic>()),
        achievements: (json['achievements'] as List?)
                ?.map((e) =>
                    Achievement.fromJson((e as Map).cast<String, dynamic>()))
                .toList() ??
            <Achievement>[],
        quests: (json['quests'] as List?)
                ?.map((e) =>
                    QuestProgress.fromJson((e as Map).cast<String, dynamic>()))
                .toList() ??
            <QuestProgress>[],
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

/// A reward that can be given to a user.
class Reward {
  /// Reward identifier.
  final String id;

  /// Reward type string.
  final String type;

  /// Optional arbitrary payload.
  final Map<String, dynamic>? payload;

  /// Creates a [Reward].
  const Reward({
    required this.id,
    required this.type,
    this.payload,
  });

  /// Convert to JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        if (payload != null) 'payload': payload,
      };

  /// Create from JSON.
  factory Reward.fromJson(Map<String, dynamic> json) => Reward(
        id: json['id'] as String,
        type: json['type'] as String,
        payload: (json['payload'] as Map?)?.cast<String, dynamic>(),
      );
}