import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:note_demo/db/note_content_hasher.dart';
import 'package:note_demo/db/util.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/providers/app_event_provider.dart';
import 'package:note_demo/providers/file_service_provider.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:note_demo/providers/note_content_provider.dart';
import 'package:note_demo/providers/principle_agent_provider.dart';

class AppNotifier extends Notifier<AppState> {
  @override
  AppState build() {
    return AppState(currentFileMetaData: NMetaData());
  }

  String get enhancedNotes {
    final noteContentNotifer = ref.read(noteContentProvider);
    final metaData = state.currentFileMetaData;
    var enhanced = noteContentNotifer.text;

    if (metaData.design?.summary != null) {
      enhanced = "*${metaData.design!.summary}*\n\n$enhanced";
    }

    // enhance here?

    return noteContentNotifer.text;
  }

  void enhanceNotes(String Function(String currentNotes) enhancement) {
    state = state.copyWith(enhancedNotes: enhancement(state.enhancedNotes));
  }

  void loadFromFile() async {
    final File? file = await ref.watch(fileServiceProvider).pickFile();
    final noteContentNotifer = ref.read(noteContentProvider.notifier);

    if (file != null) {
      file
          .readAsString()
          .then((result) {
            final hash = NoteContentHasher.hash(result);
            final box = Hive.box<NMetaData>(kHashedFilesBoxName);

            final appState = box.get(hash);
            state = state.copyWith(
              currentFileName: _getFileNameFromPath(file.path),
              enhancedNotes: result,
            );

            if (appState != null) {
              print("Load file: found existing record of ${file.absolute}");

              loadMetaData(appState);
              _enhanceNotesFromMetaData(appState, result);

              // Assign loaded text to edit controller.
              noteContentNotifer.setText(result, previousText: result);
            } else {
              print("Load file: no existing record of ${file.absolute} found");

              loadMetaData(NMetaData());

              // Run principle on new content
              ref.read(principleAgentProvider.notifier).runPrinciple();

              // Assign loaded text to edit controller.
              noteContentNotifer.setText(result, previousText: "");
            }
          })
          .onError((e, st) {
            print("$e, $st");
          });
    }
  }

  void saveFile() async {
    final noteContentNotifer = ref.read(noteContentProvider);

    if (state.hasMetaData) {
      final hash = NoteContentHasher.hash(noteContentNotifer.text);

      final box = Hive.box<NMetaData>(kHashedFilesBoxName);
      box.put(hash, state.currentFileMetaData).then((onValue) {
        print("successfully saved $hash");
      }, onError: (e) => print("error saving $hash: $e"));
    }

    ref
        .watch(fileServiceProvider)
        .saveFile(noteContentNotifer.text, state.currentFileName);
  }

  // Call on file load. Raw text needs to be enhanced
  String _enhanceNotesFromMetaData(NMetaData metaData, String raw) {
    var enhanced = raw;
    if (metaData.design?.summary != null) {
      enhanced = "*${metaData.design!.summary}*\n\n$enhanced";
    }

    state = state.copyWith(enhancedNotes: enhanced);
    return enhanced;
  }

  void newFile() async {
    print("New file");
    state = state.copyWith(
      currentFileMetaData: NMetaData(),
      currentFileName: "",
    );
    ref.read(noteContentProvider.notifier).setText("");
    ref.read(noteContentProvider.notifier).setPreviousContent("");

    ref.read(appEventControllerProvider).add(AppEvent.newFile());
  }

  void loadMetaData(NMetaData next) {
    state = state.copyWith(currentFileMetaData: next);

    ref
        .read(appEventControllerProvider)
        .add(AppEvent.loadedFromFile(state: state));
  }

  void setStudyDesign(StudyDesign? next) {
    state = state.copyWith(
      currentFileMetaData: state.currentFileMetaData.copyWith(design: next),
    );
  }

  void setTools(List<StudyTools> next) {
    state = state.copyWith(
      currentFileMetaData: state.currentFileMetaData.copyWith(tools: next),
    );
  }

  void setCurrentFileName(String name) {
    state = state.copyWith(currentFileName: name);
  }

  void setExternalResearchString(String next) {
    state = state.copyWith(
      currentFileMetaData: state.currentFileMetaData.copyWith(
        externalResearch: next,
      ),
    );
  }

  String _getFileNameFromPath(String path) => path.split("\\").last;
}

final appNotifierProvider = NotifierProvider<AppNotifier, AppState>(
  AppNotifier.new,
);
