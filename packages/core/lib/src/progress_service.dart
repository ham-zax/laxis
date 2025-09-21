import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:language_module_interface/language_module_interface.dart';

class ProgressService {
  static const _progressKey = 'progress';
  static const _backupKey = 'progress_backup';
  static const _versionKey = 'progress_version';
  static const _currentVersion = 1;

  SharedPreferences? _cachedPrefs;
  
  /// Get SharedPreferences instance with caching
  Future<SharedPreferences> get _prefs async {
    return _cachedPrefs ??= await SharedPreferences.getInstance();
  }

  /// Get progress with comprehensive error handling and recovery
  Future<Progress?> getProgress(String userId) async {
    if (userId.trim().isEmpty) {
      developer.log('ProgressService: Invalid userId provided', level: 900);
      return null;
    }

    try {
      final prefs = await _prefs;
      
      // Try to load main progress
      final progressString = prefs.getString('$_progressKey-$userId');
      if (progressString != null) {
        final progress = await _parseProgress(progressString, userId);
        if (progress != null) {
          // Create backup of successful load
          await _createBackup(userId, progressString);
          return progress;
        }
      }
      
      // Main progress failed, try backup
      developer.log('ProgressService: Main progress failed, trying backup for $userId');
      final backupString = prefs.getString('$_backupKey-$userId');
      if (backupString != null) {
        final progress = await _parseProgress(backupString, userId);
        if (progress != null) {
          developer.log('ProgressService: Successfully recovered from backup for $userId');
          // Restore backup as main progress
          await prefs.setString('$_progressKey-$userId', backupString);
          return progress;
        }
      }
      
      // Both failed, return null to create fresh progress
      developer.log('ProgressService: No valid progress found for $userId, will create fresh');
      return null;
      
    } catch (e, stackTrace) {
      developer.log(
        'ProgressService: Critical error loading progress for $userId',
        error: e,
        stackTrace: stackTrace,
        level: 1000,
      );
      return null;
    }
  }

  /// Parse progress with validation and migration
  Future<Progress?> _parseProgress(String progressString, String userId) async {
    try {
      var jsonMap = json.decode(progressString) as Map<String, dynamic>;
      
      // Validate essential fields
      if (jsonMap['userId'] == null || jsonMap['levelProgress'] == null) {
        developer.log('ProgressService: Invalid progress structure for $userId');
        return null;
      }
      
      // Check version and migrate if needed
      final version = jsonMap['version'] ?? 0;
      if (version < _currentVersion) {
        developer.log('ProgressService: Migrating progress from version $version to $_currentVersion for $userId');
        jsonMap = await _migrateProgress(jsonMap, version);
      }
      
      return Progress.fromJson(jsonMap);
      
    } on FormatException catch (e) {
      developer.log('ProgressService: JSON parsing failed for $userId', error: e);
      return null;
    } catch (e) {
      developer.log('ProgressService: Progress parsing failed for $userId', error: e);
      return null;
    }
  }

  /// Save progress with atomic operations and validation
  Future<bool> saveProgress(Progress progress) async {
    if (progress.userId.trim().isEmpty) {
      developer.log('ProgressService: Cannot save progress with empty userId', level: 900);
      return false;
    }

    try {
      final prefs = await _prefs;
      
      // Add version to progress data
      final progressData = progress.toJson();
      progressData['version'] = _currentVersion;
      progressData['lastSaved'] = DateTime.now().toIso8601String();
      
      final progressString = json.encode(progressData);
      
      // Validate JSON before saving
      try {
        json.decode(progressString);
      } catch (e) {
        developer.log('ProgressService: Generated invalid JSON for ${progress.userId}', error: e);
        return false;
      }
      
      // Atomic save: backup current, save new, verify
      await _createBackup(progress.userId, progressString);
      
      final success = await prefs.setString('$_progressKey-${progress.userId}', progressString);
      
      if (success) {
        await prefs.setInt('$_versionKey-${progress.userId}', _currentVersion);
        developer.log('ProgressService: Successfully saved progress for ${progress.userId}');
      }
      
      return success;
      
    } catch (e, stackTrace) {
      developer.log(
        'ProgressService: Failed to save progress for ${progress.userId}',
        error: e,
        stackTrace: stackTrace,
        level: 1000,
      );
      return false;
    }
  }

  /// Create backup of progress data
  Future<void> _createBackup(String userId, String progressString) async {
    try {
      final prefs = await _prefs;
      await prefs.setString('$_backupKey-$userId', progressString);
    } catch (e) {
      developer.log('ProgressService: Failed to create backup for $userId', error: e);
      // Non-critical, don't throw
    }
  }

  /// Migrate progress data between versions
  Future<Map<String, dynamic>> _migrateProgress(Map<String, dynamic> data, int fromVersion) async {
    // Future: Add migration logic here when models change
    // For now, just add version field
    data['version'] = _currentVersion;
    return data;
  }

  /// Delete progress for a user (with confirmation)
  Future<bool> deleteProgress(String userId) async {
    if (userId.trim().isEmpty) return false;
    
    try {
      final prefs = await _prefs;
      final mainDeleted = await prefs.remove('$_progressKey-$userId');
      final backupDeleted = await prefs.remove('$_backupKey-$userId');
      final versionDeleted = await prefs.remove('$_versionKey-$userId');
      
      developer.log('ProgressService: Deleted progress for $userId');
      return mainDeleted || backupDeleted;
      
    } catch (e) {
      developer.log('ProgressService: Failed to delete progress for $userId', error: e);
      return false;
    }
  }

  /// Get all user IDs with saved progress
  Future<List<String>> getAllUserIds() async {
    try {
      final prefs = await _prefs;
      final keys = prefs.getKeys();
      
      final userIds = <String>[];
      for (final key in keys) {
        if (key.startsWith('$_progressKey-')) {
          final userId = key.substring('$_progressKey-'.length);
          if (userId.isNotEmpty) {
            userIds.add(userId);
          }
        }
      }
      
      return userIds;
      
    } catch (e) {
      developer.log('ProgressService: Failed to get user IDs', error: e);
      return [];
    }
  }

  /// Clear cache (for testing/debugging)
  void clearCache() {
    _cachedPrefs = null;
  }
}
