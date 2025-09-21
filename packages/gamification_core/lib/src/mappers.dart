/// Helpers to map legacy normalized JSON into `GamificationProgress`.
///
/// The input is expected to be the normalized shape produced by
/// [ProgressServiceAdapter.readAndNormalize]:
/// {
///   'userId': string,
///   'xp': int,
///   'level': { 'number': int, 'xpThreshold': int },
///   'completedQuestIds': List<String>,
///   'updatedAt': ISO8601 string
/// }
import 'package:laxis_gamification_api/gamification_api.dart';

/// Map normalized legacy progress JSON to [GamificationProgress].
GamificationProgress mapLegacyToGamificationProgress(Map<String, dynamic> json) {
  final xpValue = (json['xp'] is num) ? (json['xp'] as num).toInt() : 0;
  final levelMap =
      (json['level'] is Map) ? (json['level'] as Map).cast<String, dynamic>() : {};
  final levelNumber =
      levelMap['number'] is num ? (levelMap['number'] as num).toInt() : 1;
  final xpThreshold = levelMap['xpThreshold'] is num
      ? (levelMap['xpThreshold'] as num).toInt()
      : 100;

  final completedQuestIds = (json['completedQuestIds'] is List)
      ? List<String>.from(json['completedQuestIds'])
      : <String>[];

  final updatedAtString = json['updatedAt'] as String?;
  final updatedAt = updatedAtString != null
      ? DateTime.tryParse(updatedAtString) ?? DateTime.now()
      : DateTime.now();

  final quests = completedQuestIds
      .map((id) => QuestProgress(questId: id, completed: true, completedAt: null))
      .toList();

  final gamification = GamificationProgress(
    totalXp: XP(xpValue),
    currentLevel: Level(number: levelNumber, xpThreshold: xpThreshold),
    achievements: <Achievement>[],
    quests: quests,
    updatedAt: updatedAt,
  );

  return gamification;
}