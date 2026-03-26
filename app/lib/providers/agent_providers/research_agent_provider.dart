import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/agents/agent_pipeline.dart';
import 'package:note_demo/agents/utils/agent_utils.dart';
import 'package:note_demo/agents/utils/embedding_service.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/models/gemini_response.dart';
import 'package:note_demo/models/insights.dart';
import 'package:note_demo/providers/agent_providers/conversation_agent_provider.dart';
import 'package:note_demo/providers/app_notifier.dart';
import 'package:note_demo/providers/insight_notifier.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:note_demo/providers/agent_providers/principle_agent_provider.dart';

const kExternalResearchNotifierToolName = "research";

final on = true;

class ResearchAgentNotifier extends Notifier<ResearchAgentState> {
  final _embedder = EmbeddingService();

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

          if (call != null && on) {
            _updateResearch(call, null);
          }
      }
    });
    ref.listen<ConversationAgentState>(conversationAgentProvider, (prev, next) {
      final call = next.callsMe(kExternalResearchNotifierToolName);
      if (call != null) {
        _updateResearch(call, next.callback);
      }
    });
  }

  // Uses principle diff only
  void _updateResearch(
    GeminiFunctionResponse call,
    Function(String?)? onFinish,
  ) async {
    state = state.copyWith(isLoading: true, pipeLevel: 0);

    final diff = ref.read(principleAgentProvider).diff?.additions;

    if (diff == null) return;

    final pipeline = AgentPipeline(
      3,
      promptPipe: kExternalResearchPromptPipe,
      key: ref.read(appNotifierProvider.notifier).apiKey,
      additionalPromptInput: call.args['additional_instructions'],
    );

    await for (final result in pipeline.fetch(diff)) {
      state = state.copyWith(pipeLevel: result.index);
      result.maybeMap(
        finished: (finished) async {
          if (finished.object.contains("https://")) {
            final embedding = await _embedder.embed(diff);

            ref
                .read(insightProvider.notifier)
                .append(
                  insight: Insight.research(
                    research: finished.object,
                    created: DateTime.now(),
                    queryEmbedding: embedding,
                  ),
                );

            print(onFinish);
            onFinish?.call(null);
          } else {
            onFinish?.call("Failed to find a resource for this topic!");
          }

          state = state.copyWith(isLoading: false, content: finished.object);
        },
        error: (error) {
          print("failed to fetch research: ${error.toString()}");
          onFinish?.call("Hit an api error!");

          state = state.copyWith(isLoading: false);
        },
        orElse: () {},
      );
    }
  }
}

final researchAgentProvider =
    NotifierProvider<ResearchAgentNotifier, ResearchAgentState>(
      () => ResearchAgentNotifier(),
    );
