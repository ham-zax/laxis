import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// Minimal SRS (Spaced Repetition System) service for MVP.
/// - Offline-first using SharedPreferences for storage (migrate to Isar later per architecture).
/// - Stores per-card review metadata and exposes due card selection.
///
/// Stored record (per-card) JSON shape:
/// {
///   "cardId": "<id>",
///   "eFactor": 2.5,
///   "intervalDays": 0,
///   "repetitions": 0,
///   "lastReviewed": "2025-01-01T00:00:00.000Z",
///   "nextDue": "2025-01-01T00:00:00.000Z"
/// }
class SrsService {
  static const _prefix = 'srs-';
  static const _indexKey = 'srs_index';

  SharedPreferences? _cachedPrefs;
  Future<SharedPreferences> get _prefs async =>
      _cachedPrefs ??= await SharedPreferences.getInstance();

  String _keyFor(String cardId) => '$_prefix$cardId';

  /// Retrieve SRS record for a card, or null if none exists yet.
  Future<Map<String, dynamic>?> _getRecord(String cardId) async {
    final prefs = await _prefs;
    final s = prefs.getString(_keyFor(cardId));
    if (s == null) return null;
    try {
      final m = json.decode(s) as Map<String, dynamic>;
      return m;
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveRecord(String cardId, Map<String, dynamic> record) async {
    final prefs = await _prefs;
    await prefs.setString(_keyFor(cardId), json.encode(record));
    // Ensure index contains cardId
    final index = prefs.getStringList(_indexKey) ?? [];
    if (!index.contains(cardId)) {
      index.add(cardId);
      await prefs.setStringList(_indexKey, index);
    }
  }

  /// Record a review outcome for a card.
  /// quality: 0..5 scale (5 = perfect, 0 = null)
  /// correct: convenience bool for common cases.
  Future<void> recordReview({
    required String cardId,
    required bool correct,
    int quality = 5,
  }) async {
    final now = DateTime.now().toUtc();
    final record = (await _getRecord(cardId)) ??
        {
          'cardId': cardId,
          'eFactor': 2.5,
          'intervalDays': 0,
          'repetitions': 0,
          'lastReviewed': now.toIso8601String(),
          'nextDue': now.toIso8601String(),
        };

    var eFactor = (record['eFactor'] as num).toDouble();
    var intervalDays = (record['intervalDays'] as num).toDouble();
    var repetitions = (record['repetitions'] as num).toInt();

    // Use SM-2 algorithm as a lightweight baseline
    if (quality < 3) {
      repetitions = 0;
      intervalDays = 1;
    } else {
      repetitions += 1;
      if (repetitions == 1) {
        intervalDays = 1;
      } else if (repetitions == 2) {
        intervalDays = 6;
      } else {
        intervalDays = intervalDays * eFactor;
      }
      // Update ease factor
      final newEF = eFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
      eFactor = max(1.3, newEF);
    }

    final nextDue =
        now.add(Duration(days: intervalDays.round())).toIso8601String();

    final newRecord = {
      'cardId': cardId,
      'eFactor': eFactor,
      'intervalDays': intervalDays,
      'repetitions': repetitions,
      'lastReviewed': now.toIso8601String(),
      'nextDue': nextDue,
    };

    await _saveRecord(cardId, newRecord);
  }

  /// Get list of cardIds that are due now or earlier.
  /// limit: max number of cards to return.
  Future<List<String>> getDueCardIds({int limit = 20}) async {
    final prefs = await _prefs;
    final index = prefs.getStringList(_indexKey) ?? [];
    final now = DateTime.now().toUtc();

    final due = <Map<String, dynamic>>[];
    for (final id in index) {
      final rec = await _getRecord(id);
      if (rec == null) continue;
      try {
        final nextDue = DateTime.parse(rec['nextDue'] as String);
        if (!nextDue.isAfter(now)) {
          due.add(rec);
        }
      } catch (_) {
        // parse error - surface as due
        due.add(rec);
      }
    }

    // Sort by oldest nextDue first (priority to overdue)
    due.sort((a, b) {
      try {
        final aDt = DateTime.parse(a['nextDue'] as String);
        final bDt = DateTime.parse(b['nextDue'] as String);
        return aDt.compareTo(bDt);
      } catch (_) {
        return 0;
      }
    });

    return due.take(limit).map((r) => r['cardId'] as String).toList();
  }

  /// Ensure a card exists in SRS index (useful when importing new decks)
  Future<void> ensureCardExists(String cardId) async {
    final prefs = await _prefs;
    final index = prefs.getStringList(_indexKey) ?? [];
    if (!index.contains(cardId)) {
      index.add(cardId);
      await prefs.setStringList(_indexKey, index);
    }
    // create a minimal record if none exists
    final rec = await _getRecord(cardId);
    if (rec == null) {
      final now = DateTime.now().toUtc();
      await _saveRecord(cardId, {
        'cardId': cardId,
        'eFactor': 2.5,
        'intervalDays': 0,
        'repetitions': 0,
        'lastReviewed': now.toIso8601String(),
        'nextDue': now.toIso8601String(),
      });
    }
  }

  /// Get SRS metadata for a card (read-only)
  Future<Map<String, dynamic>?> getMetadata(String cardId) async {
    return _getRecord(cardId);
  }

  /// For debugging and migration: export all SRS records as JSON map
  Future<Map<String, Map<String, dynamic>>> exportAll() async {
    final prefs = await _prefs;
    final index = prefs.getStringList(_indexKey) ?? [];
    final out = <String, Map<String, dynamic>>{};
    for (final id in index) {
      final rec = await _getRecord(id);
      if (rec != null) out[id] = rec;
    }
    return out;
  }

  /// Delete metadata for a card (used when removing cards)
  Future<void> deleteCard(String cardId) async {
    final prefs = await _prefs;
    await prefs.remove(_keyFor(cardId));
    final index = prefs.getStringList(_indexKey) ?? [];
    index.remove(cardId);
    await prefs.setStringList(_indexKey, index);
  }
}