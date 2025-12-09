import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/agents/agent_pipeline.dart';
import 'package:note_demo/agents/utils/agent_utils.dart';
import 'package:note_demo/providers/app_notifier.dart';
import 'package:note_demo/providers/insight_notifier.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:note_demo/providers/agent_providers/principle_agent_provider.dart';

const kExternalResearchNotifierToolName = "research";

final on = false;

class ResearchAgentNotifier extends Notifier<ResearchAgentState> {
  @override
  ResearchAgentState build() {
    _subscribeToPrinciple();
    return ResearchAgentState();
  }

  void _subscribeToPrinciple() {
    ref.listen<PrincipleAgentState>(principleAgentProvider, (prev, next) {
      switch (next) {
        case PrincipleAgentStateIdle idle:
          if (idle.valid &&
              idle.callsMe(kExternalResearchNotifierToolName) != null &&
              on) {
            _updateResearch();
          }
        default: // continue
      }
    });
  }

  void _updateResearch() async {
    state = state.copyWith(isLoading: true, pipeLevel: 0);

    final appNotifer = ref.read(appNotifierProvider.notifier);
    final diff = ref.read(principleAgentProvider).diff?.additions;

    if (diff == null) return;

    final pipeline = AgentPipeline(3, promptPipe: kExternalResearchPromptPipe);

    await for (final result in pipeline.fetch(diff)) {
      state = state.copyWith(pipeLevel: result.index);
      if (result.finished) {
        print("fetched research: ${result.object}");
        state = state.copyWith(isLoading: false, content: result.object);
        appNotifer.setExternalResearchString(result.object);

        ref
            .read(insightProvider.notifier)
            .append(insight: Insight.research(research: result.object));
      }
    }
  }
}

final researchAgentProvider =
    NotifierProvider<ResearchAgentNotifier, ResearchAgentState>(
      () => ResearchAgentNotifier(),
    );
