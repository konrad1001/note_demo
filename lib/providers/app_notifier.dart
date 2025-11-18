import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/providers/app_event_provider.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:note_demo/providers/note_content_provider.dart';

class AppNotifier extends Notifier<AppState> {
  @override
  AppState build() {
    return AppState(currentFileMetaData: NMetaData());
  }

  void newFile() async {
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
}

final appNotifierProvider = NotifierProvider<AppNotifier, AppState>(
  AppNotifier.new,
);
