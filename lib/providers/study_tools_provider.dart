import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:note_demo/agents/agent_utils.dart';
import 'package:note_demo/agents/gpt_agent.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/models/gemini_response.dart';
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
      print("prev: $prev, next: $next");
      if (next is StudyContentStateIdle && next.design.valid && !next.isLoading)
      // &&
      //     next.design != (prev as StudyContentStateIdle?)?.design)
      {
        print("updating");

        _updateTools();
      }
    });
  }

  void _updateTools() async {
    state = state.copyWith(isLoading: true);

    await Future.delayed(Duration(seconds: 1));

    final noteContent = ref.read(noteContentProvider);

    final model = GPTAgent<StudyTools>(role: AgentRole.toolBuilder);

    try {
      final response = await model.fetch(noteContent.text);

      state = state.copyWith(tools: state.tools + [response], isLoading: false);
    } catch (e) {
      // pass
      state = state.copyWith(
        isLoading: false,
        tools:
            state.tools +
            [StudyTools.flashcards(id: "id", title: "$e", items: [])],
      );
    }
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
