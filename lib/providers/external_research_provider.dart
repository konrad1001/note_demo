import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/agents/agent_pipeline.dart';
import 'package:note_demo/agents/agent_utils.dart';
import 'package:note_demo/agents/gpt_agent.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:note_demo/providers/principle_agent_provider.dart';

const kExternalResearchNotifierToolName = "research";

final on = false;

class ExternalResearchNotifier extends Notifier<ExternalResearchState> {
  @override
  ExternalResearchState build() {
    _subscribeToPrinciple();
    return ExternalResearchState();
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

    final diff = ref.read(principleAgentProvider).diff?.additions ?? "";

    final pipeline = AgentPipeline(3, promptPipe: kExternalResearchPromptPipe);

    await for (final result in pipeline.fetch(diff)) {
      state = state.copyWith(pipeLevel: result.index);
      if (result.finished) {
        state = state.copyWith(isLoading: false, content: result.object);
      }
    }
  }
}

final externalResearchProvider =
    NotifierProvider<ExternalResearchNotifier, ExternalResearchState>(
      () => ExternalResearchNotifier(),
    );

const kExternalResearchPromptPipe = [
  """<System Instructions>
        You are the first step in a resource fetching and synthesising pipeline. 
        Your job is to return up to 4 links for online content related to the provided content.
        It can be blog posts, articles or youtube videos. 

        Respond in a comma seperated list.
        </System Instructions> """,
  """
      <System Instructions> You are the second step in a resource fetching and synthesising pipeline. 
      Based on this list of resources, visit each one, then rank them in order of usefulness. make sure the links are valid.
      </System Instructions>""",
  """
      <System Instructions> You are the final step in a resource fetching and synthesising pipeline.
      The final step is to synthesise the list of evaluated resources.
      Your output will be displayed to a student using an ai study companion app, under a helpful "Next Steps" section, 
      so it must follow the following criteria:

      - Under 20 words
      - Must include the link
      - .md format
     </System Instructions>
    """,
];
