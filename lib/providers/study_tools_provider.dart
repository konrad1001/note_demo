import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:note_demo/agents/agent_utils.dart';
import 'package:note_demo/agents/gpt_agent.dart';
import 'package:note_demo/models/gemini_response.dart';
import 'package:note_demo/models/study_design.dart';
import 'package:note_demo/models/study_tools.dart';
import 'package:note_demo/providers/note_content_provider.dart';
import 'package:note_demo/providers/study_content_provider.dart';

part 'study_tools_provider.freezed.dart';

class StudyToolsNotifier extends Notifier<StudyToolsState> {
  @override
  StudyToolsState build() {
    _subscribeToStudyContent();
    return StudyToolsState();
  }

  void _subscribeToStudyContent() {
    ref.listen<StudyContentState>(studyContentProvider, (prev, next) {
      if (next is StudyContentStateIdle &&
          next.design != (prev as StudyContentStateIdle?)?.design) {
        _updateTools();
      }
    });
  }

  void _updateTools() async {
    state = state.copyWith(isLoading: true);

    final noteContent = ref.read(noteContentProvider);

    final model = GPTAgent<StudyTools>(role: AgentRole.toolBuilder);
    final response = await model.fetch(noteContent.text);

    print(response);

    state = StudyToolsState(tools: [response]);
  }
}

final studyToolsProvider =
    NotifierProvider<StudyToolsNotifier, StudyToolsState>(
      () => StudyToolsNotifier(),
    );

@freezed
abstract class StudyToolsState with _$StudyToolsState {
  const factory StudyToolsState({
    @Default([]) List<StudyTools> tools,
    @Default(false) bool isLoading,
  }) = _StudyToolsState;
}
