import 'dart:convert';
import 'package:language_module_interface/language_module_interface.dart';

/// Lightweight Deck model used by the app core.
/// Keeps storage-friendly JSON serialization and minimal fields
/// required by the PRD (Deck management, import/export).
class Deck {
  final String id;
  final String name;
  final String? description;
  final List<DeckCard> cards;
  final DateTime createdAt;
  DateTime updatedAt;

  Deck({
    required this.id,
    required this.name,
    this.description,
    List<DeckCard>? cards,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : cards = cards ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Deck.fromJson(Map<String, dynamic> json) {
    return Deck(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      cards: (json['cards'] as List? ?? [])
          .map((c) => DeckCard.fromJson(Map<String, dynamic>.from(c)))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cards': cards.map((c) => c.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  void addCard(DeckCard card) {
    cards.add(card);
    updatedAt = DateTime.now();
  }

  bool removeCardById(String cardId) {
    final before = cards.length;
    cards.removeWhere((c) => c.id == cardId);
    final after = cards.length;
    final removed = after < before;
    if (removed) updatedAt = DateTime.now();
    return removed;
  }

  DeckCard? getCardById(String cardId) {
    try {
      return cards.firstWhere((c) => c.id == cardId);
    } catch (_) {
      return null;
    }
  }
}

/// DeckCard represents a user-visible card stored inside a Deck.
/// It is storage-focused and intentionally minimal; conversion to/from
/// language_module_interface.Card is performed at higher layers when needed.
class DeckCard {
  final String id;
  final String text;
  final String? translation;
  final String? conceptId;
  final String? notes;
  final String? imagePath;
  final String? audioPath;

  DeckCard({
    required this.id,
    required this.text,
    this.translation,
    this.conceptId,
    this.notes,
    this.imagePath,
    this.audioPath,
  });

  factory DeckCard.fromJson(Map<String, dynamic> json) {
    return DeckCard(
      id: json['id'],
      text: json['text'],
      translation: json['translation'],
      conceptId: json['conceptId'],
      notes: json['notes'],
      imagePath: json['imagePath'],
      audioPath: json['audioPath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'translation': translation,
      'conceptId': conceptId,
      'notes': notes,
      'imagePath': imagePath,
      'audioPath': audioPath,
    };
  }
}