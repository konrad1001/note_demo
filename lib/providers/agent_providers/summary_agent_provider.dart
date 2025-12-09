import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/agents/utils/agent_utils.dart';
import 'package:note_demo/agents/gpt_agent.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/providers/app_event_provider.dart';
import 'package:note_demo/providers/app_notifier.dart';
import 'package:note_demo/providers/insight_notifier.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:note_demo/providers/note_content_provider.dart';
import 'package:note_demo/providers/agent_providers/principle_agent_provider.dart';

const kStudyContentNotifierToolName = "overview";

class SummaryAgentNotifier extends Notifier<SummaryAgentState> {
  @override
  SummaryAgentState build() {
    _subscribeToPrinciple();
    _subscribeToAppState();

    final design = ref.read(appNotifierProvider).currentFileMetaData.design;
    if (design != null) {
      state = SummaryAgentState.idle(design: design);
    } else {
      state = SummaryAgentState.empty();
    }

    return state;
  }

  SummaryAgentState _prevState = SummaryAgentState.empty();

  void _subscribeToAppState() {
    ref.listen<AsyncValue<AppEvent>>(appEventStreamProvider, (prev, next) {
      next.whenData((event) {
        event.maybeWhen(
          loadedFromFile: (appState) {
            final design = appState.currentFileMetaData.design;
            if (design != null) {
              state = SummaryAgentState.idle(design: design);
            } else {
              state = SummaryAgentState.empty();
            }
          },
          newFile: () {
            state = SummaryAgentState.empty();
          },
          orElse: () {},
        );
      });
    });
  }

  void _subscribeToPrinciple() {
    ref.listen<PrincipleAgentState>(principleAgentProvider, (prev, next) {
      switch (next) {
        case PrincipleAgentStateIdle idle:
          if (idle.valid &&
              idle.callsMe(kStudyContentNotifierToolName) != null) {
            _updateDesign();
          }
        default: // continue
      }
    });
  }

  _updateDesign() async {
    state = _loading;

    final model = GPTAgent<StudyDesign>(role: AgentRole.designer);

    try {
      final design = await model.fetch(_buildPrompt());
      final appNotifer = ref.read(appNotifierProvider.notifier);
      appNotifer.setStudyDesign(design);

      state = SummaryAgentState.idle(design: design);

      ref.read(insightProvider.notifier).append(insight: design.toInsight());
    } catch (e) {
      // print("Error $e");
      state = _prevState;
    }
  }

  String _buildPrompt() {
    final noteContent = ref.read(noteContentProvider);
    final studyDesign = ref.read(appNotifierProvider);

    return "<Studyplan> ${studyDesign.currentFileMetaData.design ?? StudyDesign.empty()} <User> ${noteContent.text}";
  }

  SummaryAgentState get _loading {
    _prevState = state;
    switch (state) {
      case SummaryAgentStateIdle idle:
        return idle.copyWith(isLoading: true);
      default:
        return SummaryAgentState.loading();
    }
  }
}

final summaryAgentProvider =
    NotifierProvider<SummaryAgentNotifier, SummaryAgentState>(
      () => SummaryAgentNotifier(),
    );
