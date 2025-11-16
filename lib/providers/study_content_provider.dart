import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/agents/agent_utils.dart';
import 'package:note_demo/agents/gpt_agent.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/providers/app_notifier.dart';
import 'package:note_demo/providers/models.dart';
import 'package:note_demo/providers/note_content_provider.dart';
import 'package:note_demo/mock/mocks.dart';
import 'package:note_demo/models/gemini_response.dart';
import 'package:note_demo/providers/mock_service_provider.dart';
import 'package:note_demo/providers/principle_agent_provider.dart';

class StudyContentNotifier extends Notifier<StudyContentState> {
  @override
  StudyContentState build() {
    _subscribeToPrinciple();
    _subscribeToAppState();
    return StudyContentState.empty();
  }

  StudyContentState _prevState = StudyContentState.empty();

  void _subscribeToAppState() {
    ref.listen<AppState>(appNotifierProvider, (prev, next) {
      print(next);
    });
  }

  void _subscribeToPrinciple() {
    ref.listen<PrincipleAgentState>(principleAgentProvider, (prev, next) {
      switch (next) {
        case PrincipleAgentStateIdle idle:
          if (idle.valid && idle.tool.contains('plan')) {
            _updateDesign();
          }
        default: // continue
      }
    });
  }

  _updateDesign() async {
    state = _loading;

    final useMock = ref.watch(mockServiceProvider);

    if (useMock) {
      await Future.delayed(const Duration(seconds: 1));
      state = StudyContentState.idle(
        design: MockBuilder.geminiResponse.getStudyDesign(),
      );
      return;
    }

    final model = GPTAgent<StudyDesign>(role: AgentRole.designer);

    try {
      final design = await model.fetch(_buildPrompt());
      final appNotifer = ref.read(appNotifierProvider.notifier);
      appNotifer.setStudyDesign(design);

      state = StudyContentState.idle(design: design);
    } catch (e) {
      print("Error $e");
      state = _prevState;
    }
  }

  String _buildPrompt() {
    final noteContent = ref.read(noteContentProvider);
    final studyDesign = ref.read(appNotifierProvider);

    return "<Studyplan> ${studyDesign.design ?? StudyDesign.empty()} <User> ${noteContent.text}";
  }

  StudyContentState get _loading {
    _prevState = state;
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
