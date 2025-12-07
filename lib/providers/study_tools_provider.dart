import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/agents/utils/agent_utils.dart';
import 'package:note_demo/agents/gpt_agent.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/providers/app_event_provider.dart';
import 'package:note_demo/providers/app_notifier.dart';
import 'package:note_demo/providers/insight_notifier.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:note_demo/providers/principle_agent_provider.dart';

const kStudyToolsNotifierToolName = "resources";

class StudyResourcesNotifier extends Notifier<StudyToolsState> {
  @override
  StudyToolsState build() {
    _subscribeToPrinciple();
    _subscribeToAppState();

    final tools = ref.read(appNotifierProvider).currentFileMetaData.tools;
    return StudyToolsState(tools: tools);
  }

  void _subscribeToPrinciple() {
    ref.listen<PrincipleAgentState>(principleAgentProvider, (prev, next) {
      switch (next) {
        case PrincipleAgentStateIdle idle:
          {
            final call = idle.callsMe(kStudyToolsNotifierToolName);
            if (idle.valid && call != null) {
              _updateTools();
            }
          }

        default: // continue
      }
    });
  }

  void _subscribeToAppState() {
    ref.listen<AsyncValue<AppEvent>>(appEventStreamProvider, (prev, next) {
      next.whenData((event) {
        event.maybeWhen(
          loadedFromFile: (appState) {
            final tools = appState.currentFileMetaData.tools;
            state = StudyToolsState(tools: tools);
          },
          newFile: () {
            state = StudyToolsState();
          },
          orElse: () {},
        );
      });
    });
  }

  void _updateTools() async {
    state = state.copyWith(isLoading: true);
    final appNotifer = ref.read(appNotifierProvider.notifier);

    final model = GPTAgent<StudyTools>(role: AgentRole.toolBuilder);

    try {
      final response = await model.fetch(_buildPrompt());
      appNotifer.setTools(state.tools + [response]);

      state = state.copyWith(tools: state.tools + [response], isLoading: false);

      ref.read(insightProvider.notifier).append(insight: response.toInsight());
    } catch (e) {
      print(e);
      state = state.copyWith(
        isLoading: false,
        tools:
            state.tools +
            [StudyTools.flashcards(id: "id", title: "$e", items: [])],
      );
    }
  }

  String _buildPrompt() {
    final diff = ref.read(principleAgentProvider).diff?.additions ?? "";
    final studyDesign = ref.read(appNotifierProvider);

    return "<Resources> ${studyDesign.currentFileMetaData.tools} <User> $diff";
  }
}

final studyResourcesProvider =
    NotifierProvider<StudyResourcesNotifier, StudyToolsState>(
      () => StudyResourcesNotifier(),
    );
