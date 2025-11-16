import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/providers/models.dart';

class AppNotifier extends Notifier<AppState> {
  @override
  AppState build() {
    return AppState(design: null, tools: []);
  }

  void loadAppState(AppState nextState) {
    state = nextState;
  }

  void setStudyDesign(StudyDesign? next) {
    state = state.copyWith(design: next);
  }

  void setTools(List<StudyTools> next) {
    state = state.copyWith(tools: next);
  }
}

final appNotifierProvider = NotifierProvider<AppNotifier, AppState>(
  AppNotifier.new,
);
