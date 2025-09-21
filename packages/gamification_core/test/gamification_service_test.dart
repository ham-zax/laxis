import 'dart:async';

import 'package:test/test.dart';
import 'package:laxis_gamification_core/gamification_core.dart';
import 'package:core/core.dart';
import 'package:language_module_interface/language_module.dart';
import 'package:laxis_gamification_api/gamification_api.dart';

/// A fake ProgressService that returns predefined responses in sequence.
class FakeProgressService extends ProgressService {
  final List<Progress?> _responses;
  int _callCount = 0;

  FakeProgressService(this._responses);

  @override
  Future<Progress?> getProgress(String userId) async {
    if (_callCount < _responses.length) {
      return _responses[_callCount++];
    }
    return _responses.isNotEmpty ? _responses.last : null;
  }
}

void main() {
  test('getProgress maps defaults when legacy progress missing', () async {
    final fake = FakeProgressService([null]);
    final adapter = ProgressServiceAdapter(fake);
    final svc = ReadOnlyGamificationService(adapter);

    final progress = await svc.getProgress(userId: 'user1');

    expect(progress.totalXp.value, equals(0));
    expect(progress.currentLevel.number, equals(1));
    expect(progress.quests, isEmpty);
  });

  test('watchProgress emits updated value after adapter returns changed progress', () async {
    // First response: one completed quest.
    final firstProgress = Progress(
      userId: 'user1',
      levelProgress: {
        '1': LevelProgress(completedQuestIds: ['q1'], unlockedConceptIds: {'c1'}),
      },
    );

    // Second response: two completed quests.
    final secondProgress = Progress(
      userId: 'user1',
      levelProgress: {
        '1': LevelProgress(completedQuestIds: ['q1', 'q2'], unlockedConceptIds: {'c1'}),
      },
    );

    final fake = FakeProgressService([firstProgress, secondProgress]);
    final adapter = ProgressServiceAdapter(fake);

    // Use a very short poll interval for the test.
    final svc = ReadOnlyGamificationService(adapter, pollInterval: Duration(milliseconds: 50));

    final events = <GamificationProgress>[];
    final sub = svc.watchProgress(userId: 'user1').listen(events.add);

    // Wait long enough for initial emit + one poll cycle.
    await Future.delayed(Duration(milliseconds: 300));
    await sub.cancel();

    // At least one emission (initial) and one after change expected.
    expect(events.length, greaterThanOrEqualTo(2));

    final first = events.first;
    final last = events.last;

    expect(first.quests.map((q) => q.questId), contains('q1'));
    expect(last.quests.map((q) => q.questId), containsAll(['q1', 'q2']));
  });
}