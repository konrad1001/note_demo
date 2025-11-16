import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive.dart';
import 'package:note_demo/db/note_content_hasher.dart';
import 'package:note_demo/db/util.dart';
import 'package:note_demo/providers/app_notifier.dart';
import 'package:note_demo/providers/file_service_provider.dart';
import 'package:note_demo/providers/models.dart';

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
    final appStateNotifier = ref.read(appNotifierProvider.notifier);

    if (file != null) {
      file.readAsString().then((result) {
        final hash = NoteContentHasher.hash(result);
        final box = Hive.box<AppState>(kHashedFilesBoxName);

        final appState = box.get(hash);
        if (appState != null) {
          appStateNotifier.loadAppState(appState);
        }

        state = state.copyWith(
          editingController: TextEditingController(text: result),
          previousContent: result,
        );
      });
    }
  }

  void saveFile() async {
    final appState = ref.read(appNotifierProvider);
    final hash = NoteContentHasher.hash(state.text);

    final box = Hive.box<AppState>(kHashedFilesBoxName);
    box.put(hash, appState).then((onValue) {
      print("successfully saved $hash");
    }, onError: (e) => print("error saving $hash: $e"));

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
