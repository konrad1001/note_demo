import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/agents/utils/agent_utils.dart';
import 'package:note_demo/agents/gpt_agent.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/models/gemini_response.dart';
import 'package:note_demo/providers/app_event_provider.dart';
import 'package:note_demo/providers/app_notifier.dart';
import 'package:note_demo/providers/insight_notifier.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:note_demo/providers/agent_providers/principle_agent_provider.dart';
import 'package:note_demo/util/future.dart';

const kStudyToolsNotifierToolName = "resources";

class ResourceAgentNotifier extends Notifier<ResourceAgentState> {
  final retryLimit = 1;

  @override
  ResourceAgentState build() {
    _subscribeToPrinciple();
    _subscribeToAppState();

    final tools = ref.read(appNotifierProvider).currentFileMetaData.tools;
    return ResourceAgentState(tools: tools);
  }

  void _subscribeToPrinciple() {
    ref.listen<PrincipleAgentState>(principleAgentProvider, (prev, next) {
      switch (next) {
        case PrincipleAgentState idle:
          {
            final call = idle.callsMe(kStudyToolsNotifierToolName);
            if (idle.valid && call != null) {
              _updateTools(call);
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
            state = ResourceAgentState(tools: tools);
          },
          newFile: () {
            state = ResourceAgentState();
          },
          orElse: () {},
        );
      });
    });
  }

  void _updateTools(GeminiFunctionResponse call) async {
    state = state.copyWith(isLoading: true);
    final appNotifer = ref.read(appNotifierProvider.notifier);

    final model = GPTAgent<StudyTools>(role: AgentRole.resourcer);

    print("fetching resources for $call");

    try {
      await retry(
        () async {
          final response = await model.fetch(
            _buildPrompt(call),
            verbose: false,
          );
          appNotifer.setTools(state.tools + [response]);

          state = state.copyWith(
            tools: state.tools + [response],
            isLoading: false,
          );

          ref
              .read(insightProvider.notifier)
              .append(insight: response.toInsight());
        },
        retries: 3,
        onRetry: (e, i) => print("_updateTools failed $i : $e"),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      print("Resource agent _updateTools error: $e");
    }
  }

  String _buildPrompt(GeminiFunctionResponse call) {
    final diff = ref.read(principleAgentProvider).diff?.additions ?? "";

    return "<Additional instructions> ${call.args} <User> $diff";
  }
}

final resourceAgentProvider =
    NotifierProvider<ResourceAgentNotifier, ResourceAgentState>(
      () => ResourceAgentNotifier(),
    );
