import 'package:flutter/material.dart';
import 'package:core/core.dart';
import '../widgets/flashcard_widget.dart';

/// FlashcardReviewScreen — simple reviewer that pulls due cards from SRS and
/// allows marking them 'Good' or 'Again'.
class FlashcardReviewScreen extends StatefulWidget {
  final String deckId;
  const FlashcardReviewScreen({super.key, required this.deckId});

  @override
  State<FlashcardReviewScreen> createState() => _FlashcardReviewScreenState();
}

class _FlashcardReviewScreenState extends State<FlashcardReviewScreen> {
  final DeckService _deckService = DeckService();
  final SrsService _srs = SrsService();

  Deck? _deck;
  List<DeckCard> _dueCards = [];
  bool _loading = true;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _deck = await _deckService.loadDeck(widget.deckId);
    final dueIds = await _srs.getDueCardIds(limit: 100);
    _dueCards = _deck?.cards.where((c) => dueIds.contains(c.id)).toList() ?? [];
    setState(() => _loading = false);
  }

  void _onMarked(bool correct) async {
    if (_dueCards.isEmpty) return;
    final card = _dueCards[_index];
    await _srs.recordReview(cardId: card.id, correct: correct, quality: correct ? 5 : 2);
    setState(() {
      _index++;
      if (_index >= _dueCards.length) {
        _index = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review — ${_deck?.name ?? ''}'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _dueCards.isEmpty
              ? const Center(child: Text('No cards due'))
              : Center(
                  child: FlashcardWidget(
                    front: _dueCards[_index].text,
                    back: _dueCards[_index].translation,
                    onMarked: _onMarked,
                  ),
                ),
    );
  }
}