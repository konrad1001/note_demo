import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:note_demo/db/note_content_hasher.dart';
import 'package:note_demo/db/util.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/providers/app_event_provider.dart';
import 'package:note_demo/providers/file_service_provider.dart';
import 'package:note_demo/providers/insight_notifier.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:note_demo/providers/note_content_provider.dart';
import 'package:note_demo/providers/agent_providers/principle_agent_provider.dart';

class AppNotifier extends Notifier<AppState> {
  @override
  AppState build() {
    return AppState(currentFileMetaData: NMetaData());
  }

  void enhanceNotes(String Function(String currentNotes) enhancement) {
    state = state.copyWith(enhancedNotes: enhancement(state.enhancedNotes));
  }

  void loadFromFile() async {
    final File? file = await ref.watch(fileServiceProvider).pickFile();
    final noteContentNotifer = ref.read(noteContentProvider.notifier);
    final insightsNotifier = ref.read(insightProvider.notifier);

    if (file != null) {
      file
          .readAsString()
          .then((result) {
            final hash = NoteContentHasher.hash(result);
            final box = Hive.box<NMetaData>(kHashedFilesBoxName);

            final metadata = box.get(hash);
            state = state.copyWith(
              currentFileName: _getFileNameFromPath(file.path),
              enhancedNotes: result,
            );

            if (metadata != null) {
              print("Load file: found existing record of ${file.absolute}");

              loadMetaData(metadata);
              insightsNotifier.set(metadata.insights);

              // Assign loaded text to edit controller.
              noteContentNotifer.setText(result, previousText: result);
            } else {
              print("Load file: no existing record of ${file.absolute} found");

              loadMetaData(NMetaData());
              insightsNotifier.set([]);

              // Assign loaded text to edit controller.
              noteContentNotifer.setText(result, previousText: "");

              // Run principle on new content
              ref.read(principleAgentProvider.notifier).runPrinciple();
            }
          })
          .onError((e, st) {
            print("$e, $st");
          });
    }
  }

  void saveFile() async {
    final noteContent = ref.read(noteContentProvider);
    final insights = ref.read(insightProvider);

    if (state.hasMetaData) {
      final hash = NoteContentHasher.hash(noteContent.text);
      final box = Hive.box<NMetaData>(kHashedFilesBoxName);
      final metadata = state.currentFileMetaData.copyWith(insights: insights);

      box.put(hash, metadata).then((onValue) {
        print("successfully saved $hash");
      }, onError: (e) => print("error saving $hash: $e"));
    }

    ref
        .watch(fileServiceProvider)
        .saveFile(noteContent.text, state.currentFileName);
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

  void setInsights(Insights insights) {
    state = state.copyWith(
      currentFileMetaData: state.currentFileMetaData.copyWith(
        insights: insights,
      ),
    );
  }

  void setAppHistory(List<String> history) {
    state = state.copyWith(
      currentFileMetaData: state.currentFileMetaData.copyWith(
        appHistory: history,
      ),
    );
  }

  String _getFileNameFromPath(String path) => path.split("\\").last;
}

final appNotifierProvider = NotifierProvider<AppNotifier, AppState>(
  AppNotifier.new,
);
