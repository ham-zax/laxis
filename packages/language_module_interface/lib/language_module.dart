import 'models.dart';
 
abstract class LanguageModule {
  Future<LanguageModuleData> load();
 
  /// Optional: export curated decks from the language module as a List of
  /// JSON-serializable deck maps compatible with the core Deck.fromJson shape.
  /// Default implementation returns an empty list; modules that ship curated
  /// starter decks should override this.
  Future<List<Map<String, dynamic>>> exportDecks() async => [];
}
