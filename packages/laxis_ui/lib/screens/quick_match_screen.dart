import 'package:flutter/material.dart';
import 'package:core/core.dart';

/// Quick Match micro-game
/// - Loads a deck
/// - Presents N prompts (front/text) and multiple choice translations (or vice versa)
/// - Records correct/incorrect into SRS
class QuickMatchScreen extends StatefulWidget {
  final String deckId;
  final int rounds;

  const QuickMatchScreen({
    super.key,
    required this.deckId,
    this.rounds = 8,
  });

  @override
  State<QuickMatchScreen> createState() => _QuickMatchScreenState();
}

class _QuickMatchScreenState extends State<QuickMatchScreen> {
  final DeckService _deckService = DeckService();
  final SrsService _srs = SrsService();

  Deck? _deck;
  List<DeckCard> _pool = [];
  int _currentRound = 0;
  int _score = 0;
  bool _loading = true;
  DeckCard? _currentCard;
  List<String> _options = [];
  bool _showAnswer = false;

  @override
  void initState() {
    super.initState();
    _loadDeck();
  }

  Future<void> _loadDeck() async {
    setState(() => _loading = true);
    _deck = await _deckService.loadDeck(widget.deckId);
    _pool = List<DeckCard>.from(_deck?.cards ?? []);
    _pool.shuffle();
    _startNextRound();
    setState(() => _loading = false);
  }

  void _startNextRound() {
    if (_currentRound >= widget.rounds || _pool.isEmpty) {
      // finished
      setState(() {});
      return;
    }

    setState(() {
      _showAnswer = false;
      _currentCard = _pool.removeAt(0);
      // Prepare options: correct translation (if exists) and 3 distractors
      final correct = _currentCard?.translation ?? _currentCard?.text ?? '';
      final distractors = _deck?.cards
              .where((c) => c.id != _currentCard?.id)
              .map((c) => c.translation ?? c.text)
              .toList() ??
          [];
      distractors.shuffle();
      final chosen = <String>{};
      chosen.add(correct);
      for (var d in distractors) {
        if (chosen.length >= 4) break;
        if (d == null) continue;
        chosen.add(d);
      }
      _options = chosen.toList()..shuffle();
      _currentRound++;
    });
  }

  Future<void> _submitAnswer(String selected) async {
    final correct = (_currentCard?.translation ?? _currentCard?.text) == selected;
    setState(() {
      _showAnswer = true;
      if (correct) _score++;
    });
    // Record to SRS: treat correct as quality 5, wrong as 2
    if (_currentCard != null) {
      await _srs.recordReview(
          cardId: _currentCard!.id, correct: correct, quality: correct ? 5 : 2);
    }
    // Show feedback briefly then next round
    await Future.delayed(const Duration(milliseconds: 600));
    if (_currentRound >= widget.rounds || _pool.isEmpty) {
      // end game
      setState(() {});
    } else {
      _startNextRound();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_deck == null || _currentCard == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Quick Match — ${_deck?.name ?? ''}')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Game finished', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text('Score: $_score / $_currentRound'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Quick Match — ${_deck?.name ?? ''}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Round $_currentRound of ${widget.rounds}',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _currentCard?.text ?? '',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ..._options.map((opt) {
              final isCorrect =
                  opt == (_currentCard?.translation ?? _currentCard?.text);
              final color = _showAnswer
                  ? (isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.05))
                  : null;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: _showAnswer ? null : () => _submitAnswer(opt),
                  child: Align(alignment: Alignment.centerLeft, child: Text(opt)),
                ),
              );
            }).toList(),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Score: $_score', style: Theme.of(context).textTheme.bodyLarge),
                TextButton(
                  onPressed: () {
                    // skip round: count as incorrect
                    if (!_showAnswer) _submitAnswer('__skip__');
                  },
                  child: const Text('Skip'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}