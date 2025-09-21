import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:language_module_interface/language_module_interface.dart' as lmi;
import 'package:core/src/deck.dart';
import 'package:core/src/srs_service.dart';

/// Simple DeckService using SharedPreferences for MVP offline-first storage.
/// Responsibilities:
/// - Create / Read / Update / Delete Decks
/// - Maintain an index of deck IDs for quick listing
/// - Provide a simple CSV / Quizlet-style paste importer
class DeckService {
  static const _deckIndexKey = 'deck_index';
  static const _deckKeyPrefix = 'deck-';

  SharedPreferences? _cachedPrefs;

  Future<SharedPreferences> get _prefs async {
    return _cachedPrefs ??= await SharedPreferences.getInstance();
  }

  String _generateId() {
    final rnd = Random();
    return DateTime.now().millisecondsSinceEpoch.toRadixString(36) +
        '-' +
        (rnd.nextInt(1 << 32)).toRadixString(36);
  }

  Future<List<Deck>> loadAllDecks() async {
    final prefs = await _prefs;
    final index = prefs.getStringList(_deckIndexKey) ?? [];
    final decks = <Deck>[];
    for (final id in index) {
      final jsonString = prefs.getString('$_deckKeyPrefix$id');
      if (jsonString == null) continue;
      try {
        final data = json.decode(jsonString) as Map<String, dynamic>;
        decks.add(Deck.fromJson(data));
      } catch (_) {
        // Skip invalid deck data
      }
    }
    return decks;
  }

  Future<Deck?> loadDeck(String id) async {
    final prefs = await _prefs;
    final jsonString = prefs.getString('$_deckKeyPrefix$id');
    if (jsonString == null) return null;
    try {
      final data = json.decode(jsonString) as Map<String, dynamic>;
      return Deck.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<bool> saveDeck(Deck deck) async {
    final prefs = await _prefs;
    final id = deck.id;
    final data = deck.toJson();
    final jsonString = json.encode(data);
    final ok = await prefs.setString('$_deckKeyPrefix$id', jsonString);
    if (!ok) return false;

    // Ensure index contains id
    final index = prefs.getStringList(_deckIndexKey) ?? [];
    if (!index.contains(id)) {
      index.add(id);
      await prefs.setStringList(_deckIndexKey, index);
    }

    // Ensure SRS knows about each card (useful after import/create)
    try {
      final srs = SrsService();
      final cards = deck.cards ?? <DeckCard>[];
      for (final c in cards) {
        await srs.ensureCardExists(c.id);
      }
    } catch (_) {
      // If SRS is unavailable for any reason, continue without failing save.
    }

    return true;
  }

  Future<Deck> createDeck({
    required String name,
    String? description,
    List<DeckCard>? cards,
  }) async {
    final id = _generateId();
    final deck = Deck(
      id: id,
      name: name,
      description: description,
      cards: cards,
    );
    await saveDeck(deck);
    return deck;
  }

  Future<bool> deleteDeck(String id) async {
    final prefs = await _prefs;
    final removed = await prefs.remove('$_deckKeyPrefix$id');
    final index = prefs.getStringList(_deckIndexKey) ?? [];
    index.remove(id);
    await prefs.setStringList(_deckIndexKey, index);
    return removed;
  }

  /// Basic importer that handles:
  /// - Tab-separated pairs: front<TAB>back
  /// - CSV lines: front,back
  /// - Quizlet paste (one pair per line using tab or comma)
  /// Returns a Deck populated with parsed cards (IDs are generated).
  Future<Deck> importFromPaste(String name, String pasteText) async {
    final lines = pasteText
        .split(RegExp(r'[\r\n]+'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final cards = <DeckCard>[];
    for (final line in lines) {
      // Try tab first
      if (line.contains('\t')) {
        final parts = line.split('\t');
        final front = parts[0].trim();
        final back = parts.length > 1 ? parts[1].trim() : null;
        cards.add(DeckCard(
          id: _generateId(),
          text: front,
          translation: back,
        ));
        continue;
      }

      // Try comma-separated but ignore commas inside quotes (simple)
      if (line.contains(',')) {
        final parts = _splitCsvLine(line);
        final front = parts.isNotEmpty ? parts[0].trim() : '';
        final back = parts.length > 1 ? parts[1].trim() : null;
        if (front.isNotEmpty) {
          cards.add(DeckCard(
            id: _generateId(),
            text: front,
            translation: back,
          ));
        }
        continue;
      }

      // Single column: treat as front only
      cards.add(DeckCard(
        id: _generateId(),
        text: line,
        translation: null,
      ));
    }

    final deck = await createDeck(name: name, cards: cards);
    return deck;
  }

  // Minimal CSV splitter that respects quoted fields (not fully RFC-compliant,
  // but sufficient for basic Quizlet-style paste).
  List<String> _splitCsvLine(String line) {
    final parts = <String>[];
    var buffer = StringBuffer();
    var inQuotes = false;
    for (var i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"' || ch == "'") {
        inQuotes = !inQuotes;
        continue;
      }
      if (ch == ',' && !inQuotes) {
        parts.add(buffer.toString());
        buffer.clear();
        continue;
      }
      buffer.write(ch);
    }
    parts.add(buffer.toString());
    return parts;
  }

  /// Convert a DeckCard to language_module_interface.Card for engine usage.
  /// The mapping is minimal: generate an id if none; conceptId passed through.
  lmi.Card toLanguageCard(DeckCard dc) {
    return lmi.Card(
      id: dc.id,
      text: dc.text,
      conceptId: dc.conceptId ?? 'user:${dc.id}',
      translation: dc.translation,
      type: null,
    );
  }
}