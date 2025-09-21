/// Adapter to read legacy progress from the app-wide [ProgressService]
/// and present it as a plain JSON map.
///
/// This adapter is defensive: if the underlying ProgressService returns
/// `null` or an unexpected shape, [readAndNormalize] returns a non-null
/// default map.
import 'dart:async';

import 'package:core/core.dart';

/// Adapter around [ProgressService] that exposes legacy progress as JSON.
class ProgressServiceAdapter {
  final ProgressService _progressService;

  /// Creates an adapter that reads from [progressService].
  ProgressServiceAdapter(this._progressService);

  /// Loads the raw legacy progress JSON for [userId], or `null` if none.
  Future<Map<String, dynamic>?> loadRawProgress(String userId) async {
    final progress = await _progressService.getProgress(userId);
    if (progress == null) return null;
    final json = progress.toJson();
    // Ensure userId present (Progress.toJson includes it, but be defensive).
    json['userId'] = progress.userId;
    return json;
  }

  /// Reads legacy progress and returns a normalized, non-null JSON map.
  ///
  /// Normalized shape (best-effort):
  /// {
  ///   'userId': string,
  ///   'xp': int,
  ///   'level': { 'number': int, 'xpThreshold': int },
  ///   'completedQuestIds': List<String>,
  ///   'updatedAt': ISO8601 string
  /// }
  Future<Map<String, dynamic>> readAndNormalize(String userId) async {
    final raw = await loadRawProgress(userId);
    if (raw == null) {
      return {
        'userId': userId,
        'xp': 0,
        'level': {'number': 1, 'xpThreshold': 100},
        'completedQuestIds': <String>[],
        'updatedAt': DateTime.now().toIso8601String(),
      };
    }

    final normalized = <String, dynamic>{'userId': userId};

    // XP
    if (raw.containsKey('xp') && raw['xp'] is num) {
      normalized['xp'] = (raw['xp'] as num).toInt();
    } else {
      normalized['xp'] = 0;
    }

    // Level
    if (raw.containsKey('level') && raw['level'] is Map) {
      final lvl = (raw['level'] as Map).cast<String, dynamic>();
      normalized['level'] = {
        'number': lvl['number'] is num ? (lvl['number'] as num).toInt() : 1,
        'xpThreshold':
            lvl['xpThreshold'] is num ? (lvl['xpThreshold'] as num).toInt() : 100,
      };
    } else {
      normalized['level'] = {'number': 1, 'xpThreshold': 100};
    }

    // completedQuestIds: support explicit list or inferred from levelProgress
    if (raw.containsKey('completedQuestIds') && raw['completedQuestIds'] is List) {
      normalized['completedQuestIds'] =
          List<String>.from(raw['completedQuestIds']);
    } else if (raw.containsKey('levelProgress') && raw['levelProgress'] is Map) {
      final lp = (raw['levelProgress'] as Map).cast<String, dynamic>();
      final ids = <String>[];
      for (final v in lp.values) {
        if (v is Map && v['completedQuestIds'] is List) {
          ids.addAll(List<String>.from(v['completedQuestIds']));
        }
      }
      normalized['completedQuestIds'] = ids;
    } else {
      normalized['completedQuestIds'] = <String>[];
    }

    normalized['updatedAt'] = raw['updatedAt'] ?? DateTime.now().toIso8601String();

    return normalized;
  }
}