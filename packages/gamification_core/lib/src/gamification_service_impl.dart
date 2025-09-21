/// Read-only implementation of [GamificationService].
///
/// This service adapts the legacy [ProgressService] (via
/// [ProgressServiceAdapter]) into the new gamification API shapes. It is
/// intentionally read-only: ingestion and migration are unimplemented and
/// will throw [UnimplementedError].
import 'dart:async';
import 'dart:convert';

import 'adapters/progress_service_adapter.dart';
import 'mappers.dart';
import 'package:laxis_gamification_api/gamification_api.dart';

/// Poll interval used by default for [watchProgress].
const Duration _defaultPollInterval = Duration(seconds: 5);

/// Read-only gamification service that maps legacy progress into
/// [GamificationProgress].
class ReadOnlyGamificationService implements GamificationService {
  final ProgressServiceAdapter _adapter;
  final Duration _pollInterval;

  // Simple in-memory tracking of last seen normalized JSON per user.
  final Map<String, String> _lastSerialized = {};

  ReadOnlyGamificationService(
    this._adapter, {
    Duration? pollInterval,
  }) : _pollInterval = pollInterval ?? _defaultPollInterval;

  /// Returns current progress by reading legacy progress and mapping it.
  @override
  Future<GamificationProgress> getProgress({required String userId}) async {
    final normalized = await _adapter.readAndNormalize(userId);
    return mapLegacyToGamificationProgress(normalized);
  }

  /// Force a refresh. For this read-only adapter it simply delegates to
  /// [getProgress] which bypasses any external caches.
  @override
  Future<GamificationProgress> refreshProgress({required String userId}) =>
      getProgress(userId: userId);

  /// Watch progress for [userId].
  ///
  /// - Emits current mapped progress immediately on first listener.
  /// - Polls the legacy progress service every [_pollInterval] and emits only
  ///   when the normalized JSON has changed (by updatedAt or JSON).
  /// - The returned stream is a broadcast stream. When all listeners have
  ///   detached the internal timer is cancelled and the stream is closed.
  @override
  Stream<GamificationProgress> watchProgress({required String userId}) {
    Timer? timer;
    var listeners = 0;

    // Use a controller created first, then assign onListen/onCancel so the
    // callbacks can reference the controller safely.
    final controller = StreamController<GamificationProgress>.broadcast();
    controller.onListen = () async {
      listeners += 1;
      if (listeners == 1) {
        // Emit initial value immediately.
        try {
          final normalized = await _adapter.readAndNormalize(userId);
          _lastSerialized[userId] = jsonEncode(normalized);
          controller.add(mapLegacyToGamificationProgress(normalized));
        } catch (e, st) {
          controller.addError(e, st);
        }

        // Start periodic polling.
        timer = Timer.periodic(_pollInterval, (_) async {
          try {
            final normalized = await _adapter.readAndNormalize(userId);
            final serialized = jsonEncode(normalized);
            final last = _lastSerialized[userId];
            final updatedAtChanged = (normalized['updatedAt'] as String?) !=
                (last != null
                    ? (jsonDecode(last) as Map<String, dynamic>)['updatedAt']
                    : null);

            if (last == null || updatedAtChanged || serialized != last) {
              _lastSerialized[userId] = serialized;
              controller.add(mapLegacyToGamificationProgress(normalized));
            }
          } catch (e, st) {
            controller.addError(e, st);
          }
        });
      }
    };

    controller.onCancel = () {
      listeners = (listeners - 1).clamp(0, 1);
      if (listeners == 0) {
        timer?.cancel();
        // Close the controller to signal no more events will be produced.
        controller.close();
      }
    };

    return controller.stream;
  }

  /// Ingestion is not implemented for the read-only skeleton.
  @override
  Future<String> ingestEvent(GamificationEvent event) {
    throw UnimplementedError('Read-only gamification core: ingestEvent is not implemented.');
  }

  /// Migration is not implemented for the read-only skeleton.
  @override
  Future<GamificationProgress> migrateProgress({required String userId}) {
    throw UnimplementedError('Read-only gamification core: migrateProgress is not implemented.');
  }
}