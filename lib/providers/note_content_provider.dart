import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:note_demo/providers/file_service_provider.dart';

part 'note_content_provider.freezed.dart';

class NoteContentNotifier extends Notifier<NoteContentState> {
  @override
  NoteContentState build() {
    return NoteContentState(
      editingController: TextEditingController(),
      previousContent: '',
    );
  }

  void loadFromFile() async {
    final file = await ref.watch(fileServiceProvider).pickFile();

    if (file != null) {
      file.readAsString().then((result) {
        state = state.copyWith(
          editingController: TextEditingController(text: result),
          previousContent: result,
        );
      });
    }
  }

  void saveFile() async {
    ref.watch(fileServiceProvider).saveFile(state.text);
  }

  void updateText(String newText) {
    state = state.copyWith(
      editingController: TextEditingController(text: newText),
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

@freezed
abstract class NoteContentState with _$NoteContentState {
  const factory NoteContentState({
    required TextEditingController editingController,
    required String previousContent,
  }) = _NoteContentState;
}

extension NoteContentStateX on NoteContentState {
  String get text => editingController.text;
}
