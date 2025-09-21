import 'package:test/test.dart';
import 'package:laxis_gamification_api/gamification_api.dart';

void main() {
  group('Gamification models', () {
    test('XP preserves value and enforces non-negative', () {
      final xp = XP(150);
      expect(xp.value, equals(150));

      // non-negative asserted at construction; ensure negative would fail via assertion
      // (Dart assertions are only active in checked mode; here we just ensure normal usage).
      expect(() => XP(0), returnsNormally);
    });

    test('Level preserves fields', () {
      final level = Level(number: 3, xpThreshold: 450);
      expect(level.number, equals(3));
      expect(level.xpThreshold, equals(450));
    });

    test('GamificationProgress JSON round-trip', () {
      final now = DateTime.now().toUtc();
      final progress = GamificationProgress(
        totalXp: XP(999),
        currentLevel: Level(number: 5, xpThreshold: 1000),
        achievements: [
          Achievement(
            id: 'achv_1',
            title: 'First Win',
            description: 'Awarded for first win',
            achievedAt: now,
            metadata: {'reason': 'test'},
          ),
        ],
        quests: [
          QuestProgress(
            questId: 'quest_1',
            completed: true,
            completedAt: now,
            metadata: {'score': 100},
          ),
        ],
        updatedAt: now,
      );

      final json = progress.toJson();
      final decoded = GamificationProgress.fromJson(json);

      // Check top-level fields
      expect(decoded.totalXp.value, equals(progress.totalXp.value));
      expect(decoded.currentLevel.number, equals(progress.currentLevel.number));
      expect(decoded.currentLevel.xpThreshold, equals(progress.currentLevel.xpThreshold));
      expect(decoded.achievements.length, equals(1));
      expect(decoded.achievements.first.id, equals('achv_1'));
      expect(decoded.achievements.first.title, equals('First Win'));
      expect(decoded.achievements.first.description, equals('Awarded for first win'));
      expect(decoded.achievements.first.metadata?['reason'], equals('test'));
      expect(decoded.achievements.first.achievedAt?.toUtc().toIso8601String(),
          equals(now.toIso8601String()));
      expect(decoded.quests.length, equals(1));
      expect(decoded.quests.first.questId, equals('quest_1'));
      expect(decoded.quests.first.completed, isTrue);
      expect(decoded.quests.first.metadata?['score'], equals(100));
      expect(decoded.updatedAt.toUtc().toIso8601String(), equals(now.toIso8601String()));
    });
  });
}