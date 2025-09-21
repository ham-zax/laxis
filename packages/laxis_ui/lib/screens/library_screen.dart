import 'package:flutter/material.dart';
import 'package:core/core.dart';

/// Library screen: lists decks, create new deck, open deck editor.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final DeckService _deckService = DeckService();
  List<Deck> _decks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDecks();
  }

  Future<void> _loadDecks() async {
    setState(() => _loading = true);
    final decks = await _deckService.loadAllDecks();
    setState(() {
      _decks = decks;
      _loading = false;
    });
  }

  Future<void> _createDeckDialog() async {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Deck'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Deck name'),
              ),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                Navigator.of(context).pop(true);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final deck = await _deckService.createDeck(
        name: nameCtrl.text.trim(),
        description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
      );
      await _deckService.saveDeck(deck);
      await _loadDecks();
      // Open editor immediately
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DeckEditorScreen(deckId: deck.id),
        ),
      );
    }
  }

  void _openEditor(Deck deck) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DeckEditorScreen(deckId: deck.id)),
    ).then((_) => _loadDecks());
  }

  Future<void> _deleteDeck(Deck deck) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Deck'),
        content: Text('Delete deck "${deck.name}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      await _deckService.deleteDeck(deck.id);
      await _loadDecks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDecks,
            tooltip: 'Reload',
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _decks.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('No decks yet', style: TextStyle(fontSize: 18)),
                        const SizedBox(height: 8),
                        const Text('Create a deck or import via paste (CSV / Quizlet) to get started.'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _createDeckDialog,
                          child: const Text('Create first deck'),
                        )
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, index) {
                    final deck = _decks[index];
                    return ListTile(
                      title: Text(deck.name),
                      subtitle: deck.description != null ? Text(deck.description!) : null,
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) {
                          if (v == 'edit') _openEditor(deck);
                          if (v == 'delete') _deleteDeck(deck);
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                      onTap: () => _openEditor(deck),
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(),
                  itemCount: _decks.length,
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createDeckDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Minimal DeckEditorScreen stub (will be fully implemented in next step).
class DeckEditorScreen extends StatefulWidget {
  const DeckEditorScreen({super.key, this.deckId});

  final String? deckId;

  @override
  State<DeckEditorScreen> createState() => _DeckEditorScreenState();
}

class _DeckEditorScreenState extends State<DeckEditorScreen> {
  final DeckService _deckService = DeckService();
  Deck? _deck;
  bool _loading = true;
  final TextEditingController _pasteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDeck();
  }

  Future<void> _loadDeck() async {
    setState(() => _loading = true);
    if (widget.deckId != null) {
      _deck = await _deckService.loadDeck(widget.deckId!);
    }
    setState(() => _loading = false);
  }

  Future<void> _importFromPaste() async {
    final paste = _pasteController.text.trim();
    if (paste.isEmpty) return;
    final importedDeck = await _deckService.importFromPaste(_deck?.name ?? 'Imported Deck', paste);
    // If this editor was for an existing deck, replace contents; otherwise open imported deck
    if (_deck != null) {
      _deck!.cards.clear();
      _deck!.cards.addAll(importedDeck.cards);
      await _deckService.saveDeck(_deck!);
      await _loadDeck();
    } else {
      await _deckService.saveDeck(importedDeck);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => DeckEditorScreen(deckId: importedDeck.id)));
    }
  }

  Future<void> _addCardManually() async {
    final idCtrl = TextEditingController();
    final textCtrl = TextEditingController();
    final transCtrl = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Card'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: idCtrl, decoration: const InputDecoration(labelText: 'Card id (optional)')),
            TextField(controller: textCtrl, decoration: const InputDecoration(labelText: 'Text')),
            TextField(controller: transCtrl, decoration: const InputDecoration(labelText: 'Translation (optional)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () {
            if (textCtrl.text.trim().isEmpty) return;
            Navigator.of(context).pop(true);
          }, child: const Text('Add')),
        ],
      ),
    );

    if (created == true) {
      final newCard = DeckCard(
        id: idCtrl.text.trim().isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : idCtrl.text.trim(),
        text: textCtrl.text.trim(),
        translation: transCtrl.text.trim().isEmpty ? null : transCtrl.text.trim(),
      );
      if (_deck != null) {
        _deck!.addCard(newCard);
        await _deckService.saveDeck(_deck!);
        await _loadDeck();
      } else {
        final deck = await _deckService.createDeck(name: 'New Deck', cards: [newCard]);
        await _deckService.saveDeck(deck);
        if (!mounted) return;
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => DeckEditorScreen(deckId: deck.id)));
      }
    }
  }

  Future<void> _saveDeck() async {
    if (_deck == null) return;
    await _deckService.saveDeck(_deck!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deck saved')));
  }

  Future<void> _deleteCard(String cardId) async {
    if (_deck == null) return;
    _deck!.removeCardById(cardId);
    await _deckService.saveDeck(_deck!);
    await _loadDeck();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_deck?.name ?? 'Deck Editor'),
        actions: [
          IconButton(onPressed: _saveDeck, icon: const Icon(Icons.save)),
          IconButton(onPressed: _addCardManually, icon: const Icon(Icons.add_chart)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: _pasteController,
                    minLines: 3,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'Paste CSV / Quizlet text here',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(onPressed: _importFromPaste, child: const Text('Import')),
                      const SizedBox(width: 8),
                      ElevatedButton(onPressed: _addCardManually, child: const Text('Add card')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _deck == null
                        ? const Center(child: Text('No deck loaded'))
                        : ListView.separated(
                            itemBuilder: (context, index) {
                              final c = _deck!.cards[index];
                              return ListTile(
                                title: Text(c.text),
                                subtitle: c.translation != null ? Text(c.translation!) : null,
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteCard(c.id),
                                ),
                              );
                            },
                            separatorBuilder: (_, __) => const Divider(),
                            itemCount: _deck!.cards.length,
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}