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
      final data = LanguageModuleData.fromJson(jsonMap);
      
      // Validate essential data is present
      if (data.quests.isEmpty) {
        throw Exception('No quests found in german_$level module');
      }
      if (data.cards.isEmpty) {
        throw Exception('No cards found in german_$level module');
      }
      
      return data;
    } on Exception {
      rethrow;
    } catch (e) {
      // Provide fallback minimal module for graceful degradation
      return _createFallbackModule();
    }
  }

  LanguageModuleData _createFallbackModule() {
    return LanguageModuleData(
      id: 'german_$level',
      name: 'German $level (Limited Mode)',
      quests: [
        Quest(
          id: 'fallback_q1',
          prompt: 'Basic German sentence building',
          solution: ['fallback_c1', 'fallback_c2'],
          conceptIds: ['fallback_con1'],
          title: 'Emergency Quest',
          difficulty: 'beginner',
          points: 10,
        ),
      ],
      concepts: [
        Concept(
          id: 'fallback_con1',
          name: 'Basic German',
          explanation: 'Basic German concepts for emergency mode',
          category: 'Grammar',
          difficulty: 'beginner',
        ),
      ],
      cards: [
        Card(
          id: 'fallback_c1',
          text: 'Ich',
          conceptId: 'fallback_con1',
          translation: 'I',
          type: 'pronoun',
        ),
        Card(
          id: 'fallback_c2',
          text: 'bin',
          conceptId: 'fallback_con1',
          translation: 'am',
          type: 'verb',
        ),
      ],
    );
  }
}
