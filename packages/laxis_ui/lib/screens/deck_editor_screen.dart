import 'package:flutter/material.dart';
import 'library_screen.dart';

/// Thin wrapper to expose DeckEditorScreen from a dedicated file so it can be
/// exported by the package. Internally the implementation lives in
/// `library_screen.dart` to avoid code duplication during the YOLO pass.
class DeckEditorScreenWrapper extends StatelessWidget {
  final String? deckId;
  const DeckEditorScreenWrapper({super.key, this.deckId});

  @override
  Widget build(BuildContext context) {
    // Delegate to the real implementation in library_screen.dart
    return DeckEditorScreen(deckId: deckId);
  }
}