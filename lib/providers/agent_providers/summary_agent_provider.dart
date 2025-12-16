import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/agents/utils/agent_utils.dart';
import 'package:note_demo/agents/gpt_agent.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/models/gemini_response.dart';
import 'package:note_demo/providers/app_event_provider.dart';
import 'package:note_demo/providers/app_notifier.dart';
import 'package:note_demo/providers/insight_notifier.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:note_demo/providers/note_content_provider.dart';
import 'package:note_demo/providers/agent_providers/principle_agent_provider.dart';
import 'package:note_demo/util/future.dart';

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
        case PrincipleAgentState idle:
          final call = idle.callsMe(kStudyContentNotifierToolName);

          if (idle.valid && !idle.isLoading && call != null) {
            _updateDesign(call);
          }
        default: // continue
      }
    });
  }

  _updateDesign(GeminiFunctionResponse call) async {
    state = _loading;

    final model = GPTAgent<StudyDesign>(role: AgentRole.designer);

    try {
      await retry(() async {
        final design = await model.fetch(_buildPrompt(call), verbose: false);
        final appNotifer = ref.read(appNotifierProvider.notifier);
        appNotifer.setStudyDesign(design);

        state = SummaryAgentState.idle(design: design);

        ref.read(insightProvider.notifier).append(insight: design.toInsight());
      }, onRetry: (e, i) => print("_updateDesign failed $i : $e"));
    } catch (e) {
      print("Error $e");
      state = _prevState;
    }
  }

  String _buildPrompt(GeminiFunctionResponse call) {
    final noteContent = ref.read(noteContentProvider);

    return "<Additional instructions> ${call.args} <User> ${noteContent.text}";
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
