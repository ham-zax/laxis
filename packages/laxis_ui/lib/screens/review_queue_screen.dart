import 'package:flutter/material.dart';
import 'package:core/core.dart';
import '../widgets/flashcard_widget.dart';

/// ReviewQueueScreen — aggregates due cards across all decks and provides
/// a simple sequential reviewer using the existing FlashcardWidget.
class ReviewQueueScreen extends StatefulWidget {
  const ReviewQueueScreen({super.key});

  @override
  State<ReviewQueueScreen> createState() => _ReviewQueueScreenState();
}

class _ReviewQueueScreenState extends State<ReviewQueueScreen> {
  final DeckService _deckService = DeckService();
  final SrsService _srs = SrsService();

  List<DeckCard> _dueCards = [];
  bool _loading = true;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _loadQueue();
  }

  Future<void> _loadQueue() async {
    setState(() => _loading = true);
    final decks = await _deckService.loadAllDecks();
    final dueIds = await _srs.getDueCardIds(limit: 200);

    final Map<String, DeckCard> map = {};
    for (final d in decks) {
      for (final c in d.cards ?? []) {
        map[c.id] = c;
      }
    }

    _dueCards = dueIds.map((id) => map[id]).whereType<DeckCard>().toList();

    setState(() {
      _loading = false;
      _index = 0;
    });
  }

  Future<void> _onMarked(bool correct) async {
    if (_dueCards.isEmpty) return;
    final card = _dueCards[_index];
    await _srs.recordReview(cardId: card.id, correct: correct, quality: correct ? 5 : 2);

    setState(() {
      _dueCards.removeAt(_index);
      if (_index >= _dueCards.length) {
        _index = 0;
      }
    });

    // If queue emptied, reload to pick up newly due items
    if (_dueCards.isEmpty) {
      await _loadQueue();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Queue'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQueue,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _dueCards.isEmpty
              ? const Center(child: Text('No cards due'))
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_dueCards.length} card(s) in queue',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 12),
                      FlashcardWidget(
                        front: _dueCards[_index].text,
                        back: _dueCards[_index].translation,
                        onMarked: _onMarked,
                      ),
                      const SizedBox(height: 12),
                      Text('${_index + 1} / ${_dueCards.length}'),
                    ],
                  ),
                ),
    );
  }
}