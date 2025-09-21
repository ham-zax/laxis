import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:language_module_interface/language_module_interface.dart';

class ProgressService {
  static const _progressKey = 'progress';

  Future<Progress?> getProgress(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final progressString = prefs.getString('$_progressKey-$userId');
    if (progressString != null) {
      return Progress.fromJson(json.decode(progressString));
    }
    return null;
  }

  Future<void> saveProgress(Progress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_progressKey-${progress.userId}', json.encode(progress.toJson()));
  }
}
