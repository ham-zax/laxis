import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:language_module_interface/language_module_interface.dart';

class GermanLanguageModule implements LanguageModule {
  final String level;

  GermanLanguageModule(this.level);

  @override
  Future<LanguageModuleData> load() async {
    try {
      final jsonString = await rootBundle.loadString(
        'packages/german_language_module/assets/german_$level.json',
      );
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return LanguageModuleData.fromJson(jsonMap);
    } catch (e) {
      throw Exception('Failed to load german_$level module: $e');
    }
  }
}
