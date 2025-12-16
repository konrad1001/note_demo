import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/agents/agent_pipeline.dart';
import 'package:note_demo/agents/utils/agent_utils.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/models/gemini_response.dart';
import 'package:note_demo/providers/app_notifier.dart';
import 'package:note_demo/providers/insight_notifier.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:note_demo/providers/agent_providers/principle_agent_provider.dart';

const kExternalResearchNotifierToolName = "research";

final on = true;

class ResearchAgentNotifier extends Notifier<ResearchAgentState> {
  @override
  ResearchAgentState build() {
    _subscribeToPrinciple();
    return ResearchAgentState();
  }

  void _subscribeToPrinciple() {
    ref.listen<PrincipleAgentState>(principleAgentProvider, (prev, next) {
      switch (next) {
        case PrincipleAgentState idle:
          final call = idle.callsMe(kExternalResearchNotifierToolName);

          if (idle.valid && call != null && on) {
            _updateResearch(call);
          }
        default: // continue
      }
    });
  }

  void _updateResearch(GeminiFunctionResponse call) async {
    state = state.copyWith(isLoading: true, pipeLevel: 0);

    final appNotifer = ref.read(appNotifierProvider.notifier);
    final diff = ref.read(principleAgentProvider).diff?.additions;

    if (diff == null) return;

    final pipeline = AgentPipeline(
      3,
      promptPipe: kExternalResearchPromptPipe,
      additionalPromptInput: call
          .args
          .first, // Cheeky but I know this type of call will only have one argument.
    );

    await for (final result in pipeline.fetch(diff)) {
      state = state.copyWith(pipeLevel: result.index);
      result.maybeMap(
        finished: (finished) {
          print("fetched research: ${finished.object}");
          state = state.copyWith(isLoading: false, content: finished.object);
          appNotifer.setExternalResearchString(finished.object);

          ref
              .read(insightProvider.notifier)
              .append(insight: Insight.research(research: finished.object));
        },
        error: (error) {
          print("failed to fetch research: ${error.toString()}");
          state = state.copyWith(isLoading: false);
        },
        orElse: () {},
      );
      // if (result is Pipe) {
      // print("fetched research: ${result.object}");
      // state = state.copyWith(isLoading: false, content: result.object);
      // appNotifer.setExternalResearchString(result.object);

      // ref
      //     .read(insightProvider.notifier)
      //     .append(insight: Insight.research(research: result.object));
      // }
    }
  }
}

final researchAgentProvider =
    NotifierProvider<ResearchAgentNotifier, ResearchAgentState>(
      () => ResearchAgentNotifier(),
    );
