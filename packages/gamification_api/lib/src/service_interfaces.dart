/// Service and event interfaces for the gamification API.
import 'dart:async';

import 'models.dart';

/// Service responsible for ingesting events and providing gamification progress.
abstract class GamificationService {
  /// Ingests a gamification event and returns an identifier for the ingestion.
  Future<String> ingestEvent(GamificationEvent event);

  /// Returns the current gamification progress for [userId].
  Future<GamificationProgress> getProgress({ required String userId });

  /// Watches progress updates for [userId].
  Stream<GamificationProgress> watchProgress({ required String userId });

  /// Forces a refresh of the progress for [userId].
  Future<GamificationProgress> refreshProgress({ required String userId });

  /// Migrate a user's progress (used when upgrading schemas).
  Future<GamificationProgress> migrateProgress({ required String userId });
}

/// Repository abstraction for storing raw gamification JSON per user.
abstract class GamificationRepository {
  /// Loads the raw stored JSON for [userId], or `null` if not present.
  Future<Map<String,dynamic>?> loadRaw(String userId);

  /// Saves [gamificationJson] for [userId].
  Future<void> save(String userId, Map<String,dynamic> gamificationJson);

  /// Runs [op] inside a transaction scoped to [userId].
  Future<T> runInTransaction<T>(String userId, Future<T> Function() op);

  /// Deletes stored progress for [userId].
  Future<void> delete(String userId);
}

/// A single ingestible event for the gamification system.
abstract class GamificationEvent {
  /// The user id this event applies to.
  String get userId;

  /// When the event occurred.
  DateTime get occurredAt;

  /// Event identifier.
  String get eventId;

  /// Convert to JSON.
  Map<String,dynamic> toJson();
}

/// Event emitted when a quest is completed.
class QuestCompletedEvent implements GamificationEvent {
  /// The user id this event applies to.
  @override
  final String userId;

  /// Unique event id.
  @override
  final String eventId;

  /// Occurrence time.
  @override
  final DateTime occurredAt;

  /// The quest that was completed.
  final String questId;

  /// XP awarded for completing the quest.
  final int xpAwarded;

  /// Creates a [QuestCompletedEvent].
  const QuestCompletedEvent({
    required this.userId,
    required this.eventId,
    required this.occurredAt,
    required this.questId,
    required this.xpAwarded,
  });

  /// Convert to JSON.
  @override
  Map<String,dynamic> toJson() => {
        'type': 'quest_completed',
        'userId': userId,
        'eventId': eventId,
        'occurredAt': occurredAt.toIso8601String(),
        'questId': questId,
        'xpAwarded': xpAwarded,
      };
}

/// Event emitted when a user performs a daily login.
class DailyLoginEvent implements GamificationEvent {
  @override
  final String userId;

  @override
  final String eventId;

  @override
  final DateTime occurredAt;

  /// Consecutive login streak (optional).
  final int? streakDays;

  /// XP awarded for the login (optional).
  final int? xpAwarded;

  /// Creates a [DailyLoginEvent].
  const DailyLoginEvent({
    required this.userId,
    required this.eventId,
    required this.occurredAt,
    this.streakDays,
    this.xpAwarded,
  });

  @override
  Map<String,dynamic> toJson() => {
        'type': 'daily_login',
        'userId': userId,
        'eventId': eventId,
        'occurredAt': occurredAt.toIso8601String(),
        if (streakDays != null) 'streakDays': streakDays,
        if (xpAwarded != null) 'xpAwarded': xpAwarded,
      };
}

/// Event emitted when a purchase occurs.
class PurchaseEvent implements GamificationEvent {
  @override
  final String userId;

  @override
  final String eventId;

  @override
  final DateTime occurredAt;

  /// Identifier for the purchase (e.g., order id).
  final String purchaseId;

  /// Amount in smallest currency unit or simple integer amount.
  final int amount;

  /// Currency code (e.g., "USD").
  final String currency;

  /// XP awarded for the purchase (optional).
  final int? xpAwarded;

  /// Creates a [PurchaseEvent].
  const PurchaseEvent({
    required this.userId,
    required this.eventId,
    required this.occurredAt,
    required this.purchaseId,
    required this.amount,
    required this.currency,
    this.xpAwarded,
  });

  @override
  Map<String,dynamic> toJson() => {
        'type': 'purchase',
        'userId': userId,
        'eventId': eventId,
        'occurredAt': occurredAt.toIso8601String(),
        'purchaseId': purchaseId,
        'amount': amount,
        'currency': currency,
        if (xpAwarded != null) 'xpAwarded': xpAwarded,
      };
}