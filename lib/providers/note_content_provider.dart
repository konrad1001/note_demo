import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:note_demo/db/note_content_hasher.dart';
import 'package:note_demo/db/util.dart';
import 'package:note_demo/providers/app_notifier.dart';
import 'package:note_demo/providers/file_service_provider.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:note_demo/providers/principle_agent_provider.dart';

class NoteContentNotifier extends Notifier<NoteContentState> {
  @override
  NoteContentState build() {
    return NoteContentState(
      editingController: TextEditingController(),
      previousContent: '',
    );
  }

  void loadFromFile() async {
    final File? file = await ref.watch(fileServiceProvider).pickFile();
    final appStateNotifier = ref.read(appNotifierProvider.notifier);

    if (file != null) {
      file
          .readAsString()
          .then((result) {
            final hash = NoteContentHasher.hash(result);
            final box = Hive.box<NMetaData>(kHashedFilesBoxName);

            final appState = box.get(hash);
            if (appState != null) {
              print("Load file: found existing record of ${file.absolute}");
              appStateNotifier.loadMetaData(appState);
              appStateNotifier.setCurrentFileName(file.path);

              state = state.copyWith(
                editingController: TextEditingController(text: result),
                previousContent: result,
              );
            } else {
              print("Load file: no existing record of ${file.absolute} found");
              appStateNotifier.loadMetaData(NMetaData());
              appStateNotifier.setCurrentFileName(file.path);

              ref.read(principleAgentProvider.notifier).runPrinciple();
              state = state.copyWith(
                editingController: TextEditingController(text: result),
                previousContent: "",
              );
            }
          })
          .onError((e, st) {
            print("$e, $st");
          });
    }
  }

  void saveFile() async {
    final appState = ref.read(appNotifierProvider);
    final hash = NoteContentHasher.hash(state.text);

    final box = Hive.box<NMetaData>(kHashedFilesBoxName);
    box.put(hash, appState.currentFileMetaData).then((onValue) {
      print("successfully saved $hash");
    }, onError: (e) => print("error saving $hash: $e"));

    ref.watch(fileServiceProvider).saveFile(state.text);
  }

  void setText(String newText) {
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
