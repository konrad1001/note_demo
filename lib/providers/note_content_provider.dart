import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/providers/models/models.dart';

class NoteContentNotifier extends Notifier<NoteContentState> {
  @override
  NoteContentState build() {
    return NoteContentState(
      editingController: TextEditingController(),
      previousContent: '',
    );
  }

  void setText(String newText, {String? previousText}) {
    state = state.copyWith(
      editingController: TextEditingController(text: newText),
      previousContent: previousText ?? state.previousContent,
    );
  }

  void setPreviousContent(String text) {
    state = state.copyWith(previousContent: text);
  }
}

final noteContentProvider =
    NotifierProvider<NoteContentNotifier, NoteContentState>(
      () => NoteContentNotifier(),
    );
