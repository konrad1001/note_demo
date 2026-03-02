import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markdown_editor/markdown_editor.dart';
import 'package:note_demo/agents/utils/agent_utils.dart';
import 'package:note_demo/providers/app_notifier.dart';
import 'package:note_demo/providers/models/models.dart';

class NoteContentNotifier extends Notifier<NoteContentState> {
  @override
  NoteContentState build() {
    final build = ref.read(appNotifierProvider).build;
    final buildText = (build == .test) ? kTesterString : "";

    return NoteContentState(
      editingController: MarkdownTextEditingController(text: buildText),
      previousContent: buildText,
    );
  }

  void setText(String newText, {String? previousText}) {
    state = state.copyWith(
      editingController: MarkdownTextEditingController(text: newText),
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
