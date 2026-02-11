import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/agents/utils/agent_utils.dart';
import 'package:note_demo/agents/gpt_agent.dart';
import 'package:note_demo/agents/utils/embedding_service.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/models/gemini_response.dart';
import 'package:note_demo/providers/agent_providers/conversation_agent_provider.dart';
import 'package:note_demo/providers/insight_notifier.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:note_demo/providers/agent_providers/principle_agent_provider.dart';
import 'package:note_demo/util/future.dart';

const kStudyToolsNotifierToolName = "resources";

class ResourceAgentNotifier extends Notifier<ResourceAgentState> {
  final _retryLimit = 3;
  final _model = GPTAgent<StudyTools>(role: AgentRole.resourcer);
  final _embedder = EmbeddingService();

  @override
  ResourceAgentState build() {
    _subscribeToPrinciple();
    return ResourceAgentState();
  }

  void _subscribeToPrinciple() {
    ref.listen<PrincipleAgentState>(principleAgentProvider, (prev, next) {
      final call = next.callsMe(kStudyToolsNotifierToolName);
      if (call != null) {
        _updateTools(call);
      }
    });

    ref.listen<ConversationAgentState>(conversationAgentProvider, (prev, next) {
      final call = next.callsMe(kStudyToolsNotifierToolName);
      if (call != null) {
        _updateTools(call);
      }
    });
  }

  // Uses principle diff only
  void _updateTools(GeminiFunctionResponse call) async {
    state = state.copyWith(isLoading: true);
    final content = ref.read(principleAgentProvider).diff?.additions ?? "";

    try {
      await retry(() async {
        final response = await _model.fetch(
          _buildPrompt(content, call),
          verbose: false,
        );

        final embedding = await _embedder.embed(content);

        state = state.copyWith(isLoading: false);

        ref
            .read(insightProvider.notifier)
            .append(insight: response.toInsight(embedding));
      }, retries: _retryLimit);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      print("Resource agent _updateTools error: $e");
    }
  }

  String _buildPrompt(String content, GeminiFunctionResponse call) {
    return "<Additional instructions> ${call.args} <User> $content";
  }
}

final resourceAgentProvider =
    NotifierProvider<ResourceAgentNotifier, ResourceAgentState>(
      () => ResourceAgentNotifier(),
    );
