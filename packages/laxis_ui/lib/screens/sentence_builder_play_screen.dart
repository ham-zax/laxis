import 'package:flutter/material.dart';
import 'package:core/core.dart';
import '../sentence_building_mat.dart';
import '../card_widget.dart';
import 'flashcard_review_screen.dart';

/// SentenceBuilderPlayScreen — play sentence-builder puzzles using a Deck as source.
/// Unlock logic: require minimal proficiency on deck cards (via SRS metadata)
/// before the Sentence Builder becomes available. If locked, prompt user to
/// practice in Flashcard Review.
class SentenceBuilderPlayScreen extends StatefulWidget {
  final String deckId;
  const SentenceBuilderPlayScreen({super.key, required this.deckId});

  @override
  State<SentenceBuilderPlayScreen> createState() => _SentenceBuilderPlayScreenState();
}

class _SentenceBuilderPlayScreenState extends State<SentenceBuilderPlayScreen> {
  final DeckService _deckService = DeckService();
  final SrsService _srs = SrsService();

  Deck? _deck;
  bool _loading = true;
  bool _isUnlocked = false;
  final Set<String> _usedCardIds = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _deck = await _deckService.loadDeck(widget.deckId);

    // Ensure SRS has entries for deck cards
    for (final c in _deck?.cards ?? []) {
      await _srs.ensureCardExists(c.id);
    }

    // Compute simple proficiency: count cards with repetitions >= 2 OR eFactor > 1.4
    var profCount = 0;
    final cards = _deck?.cards ?? [];
    for (final c in cards) {
      final meta = await _srs.getMetadata(c.id);
      if (meta != null) {
        final reps = (meta['repetitions'] as num?)?.toInt() ?? 0;
        final ef = (meta['eFactor'] as num?)?.toDouble() ?? 0.0;
        if (reps >= 2 || ef > 1.4) profCount++;
      }
    }

    // Required proficiency: at least min(3, cards.length) or 50% of deck (whichever is smaller but at least 1)
    final required = cards.isEmpty ? 1 : (cards.length < 3 ? cards.length : 3);
    _isUnlocked = profCount >= required && cards.isNotEmpty;

    setState(() => _loading = false);
  }

  void _onCardUsed(String cardId) {
    setState(() => _usedCardIds.add(cardId));
  }

  void _onCardRemoved(String cardId) {
    setState(() => _usedCardIds.remove(cardId));
  }

  Future<void> _onCorrect() async {
    final solutionIds = _deck?.cards.map((c) => c.id).toList() ?? [];
    for (final id in solutionIds) {
      await _srs.recordReview(cardId: id, correct: true, quality: 5);
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Correct! Progress saved.')));
    // Reset used cards
    setState(() {
      _usedCardIds.clear();
    });

    // Re-evaluate unlock status
    await _load();
  }

  void _onIncorrect() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incorrect — try again')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Build sentence — ${_deck?.name ?? ''}'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: _isUnlocked
                  ? Column(
                      children: [
                        SentenceBuildingMat(
                          solution: _deck?.cards.map((c) => c.id).toList() ?? [],
                          onCorrect: _onCorrect,
                          onCardUsed: _onCardUsed,
                          onCardRemoved: _onCardRemoved,
                          onIncorrect: _onIncorrect,
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: _deck?.cards.where((c) => !_usedCardIds.contains(c.id)).map((c) {
                                return DraggableCardWidget(
                                  cardId: c.id,
                                  text: c.text,
                                  isUsed: false,
                                  hasConjugation: false,
                                  onDragStarted: () {},
                                  onDragEnd: () {},
                                );
                              }).toList() ?? [],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock, size: 56, color: Colors.grey),
                          const SizedBox(height: 12),
                          Text(
                            'Sentence Builder locked',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Practice the deck cards in Flashcards until you reach basic proficiency.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => FlashcardReviewScreen(deckId: widget.deckId),
                              ));
                            },
                            child: const Text('Practice Flashcards'),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200]),
                            child: const Text('Back'),
                          ),
                        ],
                      ),
                    ),
            ),
    );
  }
}