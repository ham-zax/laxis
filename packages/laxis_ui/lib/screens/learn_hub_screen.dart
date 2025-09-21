import 'package:flutter/material.dart';
import 'package:core/core.dart';
import '../theme/app_theme.dart';
import 'quick_match_screen.dart';
import 'review_queue_screen.dart';
import 'sentence_builder_play_screen.dart';
import 'flashcard_review_screen.dart';
 
/// Learn Hub screen stub: shows Flashcards (SRS review) and Quick Match launcher.
class LearnHubScreen extends StatefulWidget {
  final String deckId;
  const LearnHubScreen({super.key, required this.deckId});

  @override
  State<LearnHubScreen> createState() => _LearnHubScreenState();
}

class _LearnHubScreenState extends State<LearnHubScreen> {
  final DeckService _deckService = DeckService();
  final SrsService _srs = SrsService();

  Deck? _deck;
  List<DeckCard> _dueCards = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDeckAndDue();
  }

  Future<void> _loadDeckAndDue() async {
    setState(() => _loading = true);
    _deck = await _deckService.loadDeck(widget.deckId);
    final dueIds = await _srs.getDueCardIds(limit: 50);
    _dueCards = _deck?.cards.where((c) => dueIds.contains(c.id)).toList() ?? [];
    setState(() => _loading = false);
  }

  Future<void> _reviewCard(DeckCard card, bool correct) async {
    await _srs.recordReview(cardId: card.id, correct: correct, quality: correct ? 5 : 2);
    await _loadDeckAndDue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Learn — ${_deck?.name ?? ''}'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => FlashcardReviewScreen(deckId: widget.deckId),
                          ));
                        },
                        child: const Text('Flashcards'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => QuickMatchScreen(deckId: widget.deckId),
                          ));
                        },
                        child: const Text('Play Quick Match'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const ReviewQueueScreen(),
                          ));
                        },
                        child: const Text('Open Review Queue'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SentenceBuilderPlayScreen(deckId: widget.deckId),
                          ));
                        },
                        child: const Text('Sentence Builder'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _dueCards.isEmpty
                        ? const Center(child: Text('No cards due for review'))
                        : ListView.separated(
                            itemBuilder: (context, index) {
                              final c = _dueCards[index];
                              return ListTile(
                                title: Text(c.text),
                                subtitle: c.translation != null ? Text(c.translation!) : null,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(icon: const Icon(Icons.close), onPressed: () => _reviewCard(c, false)),
                                    IconButton(icon: const Icon(Icons.check), onPressed: () => _reviewCard(c, true)),
                                  ],
                                ),
                              );
                            },
                            separatorBuilder: (_, __) => const Divider(),
                            itemCount: _dueCards.length,
                          ),
                  )
                ],
              ),
            ),
    );
  }
}