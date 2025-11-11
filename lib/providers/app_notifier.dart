import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:note_demo/models/agent_responses/models.dart';

part 'app_notifier.freezed.dart';

class AppNotifier extends Notifier<AppState> {
  @override
  AppState build() {
    return AppState(design: null, tools: []);
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

@freezed
abstract class AppState with _$AppState {
  const factory AppState({
    StudyDesign? design,
    @Default([]) List<StudyTools> tools,
  }) = _AppState;
}
