import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:note_demo/agents/agent_utils.dart';
import 'package:note_demo/agents/gpt_agent.dart';
import 'package:note_demo/models/study_design.dart';
import 'package:note_demo/providers/note_content_provider.dart';
import 'package:note_demo/mock/mocks.dart';
import 'package:note_demo/models/gemini_response.dart';
import 'package:note_demo/providers/mock_service_provider.dart';

part 'study_content_provider.freezed.dart';

class StudyContentNotifier extends Notifier<StudyContentState> {
  @override
  StudyContentState build() {
    return StudyContentState.empty();
  }

  void prepareDesign() {
    final noteContent = ref.read(noteContentProvider);
    final noteContentNotifier = ref.read(noteContentProvider.notifier);
    if ((noteContent.text.length - noteContent.previousContent.length).abs() >
        20) {
      state = _loading;
      print("sufficient diff, state: $state");

      _updateDesign(noteContent.text);
      noteContentNotifier.setPreviousContent(noteContent.text);
    } else {
      print("insufficient diff");
    }
  }

  _updateDesign(String noteContent) async {
    final useMock = ref.watch(mockServiceProvider);

    if (useMock) {
      await Future.delayed(const Duration(seconds: 1));
      state = StudyContentState.idle(
        design: MockBuilder.geminiResponse.getStudyDesign(),
      );
      return;
    }

    final model = GPTAgent<StudyDesign>(role: AgentRole.designer);
    final design = await model.fetch(noteContent);

    if (design.valid) {
      state = StudyContentState.idle(design: design);
    } else {
      state = StudyContentState.empty();
    }
  }

  StudyContentState get _loading {
    switch (state) {
      case StudyContentStateIdle idle:
        return idle.copyWith(isLoading: true);
      default:
        return StudyContentState.loading();
    }
  }
}

final studyContentProvider =
    NotifierProvider<StudyContentNotifier, StudyContentState>(
      () => StudyContentNotifier(),
    );

@freezed
abstract class StudyContentState with _$StudyContentState {
  const factory StudyContentState.empty() = StudyContentStateEmpty;
  const factory StudyContentState.loading() = StudyContentStateLoading;
  const factory StudyContentState.idle({
    required StudyDesign design,
    @Default(false) bool isLoading,
  }) = StudyContentStateIdle;
}
