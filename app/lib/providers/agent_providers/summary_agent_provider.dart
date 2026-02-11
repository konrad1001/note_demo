import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/agents/utils/agent_utils.dart';
import 'package:note_demo/agents/gpt_agent.dart';
import 'package:note_demo/agents/utils/embedding_service.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/models/gemini_response.dart';
import 'package:note_demo/providers/agent_providers/conversation_agent_provider.dart';
import 'package:note_demo/providers/app_notifier.dart';
import 'package:note_demo/providers/insight_notifier.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:note_demo/providers/note_content_provider.dart';
import 'package:note_demo/providers/agent_providers/principle_agent_provider.dart';
import 'package:note_demo/util/future.dart';

const kStudyContentNotifierToolName = "overview";

class SummaryAgentNotifier extends Notifier<SummaryAgentState> {
  final _model = GPTAgent<StudyDesign>(role: AgentRole.designer);
  final _embedder = EmbeddingService();

  @override
  SummaryAgentState build() {
    _subscribeToPrinciple();

    return SummaryAgentState();
  }

  void _subscribeToPrinciple() {
    ref.listen<PrincipleAgentState>(principleAgentProvider, (prev, next) {
      final call = next.callsMe(kStudyContentNotifierToolName);

      if (!next.isLoading && call != null) {
        _updateDesign(call);
      }
    });

    ref.listen<ConversationAgentState>(conversationAgentProvider, (prev, next) {
      final call = next.callsMe(kStudyContentNotifierToolName);
      if (call != null) {
        _updateDesign(call);
      }
    });
  }

  // Uses entire User notes.
  _updateDesign(GeminiFunctionResponse call) async {
    state = state.copyWith(isLoading: true);
    final noteContent = ref.read(noteContentProvider);

    try {
      await retry(() async {
        final design = await _model.fetch(
          _buildPrompt(noteContent.text, call),
          verbose: false,
        );

        final embedding = await _embedder.embed(noteContent.text);

        state = state.copyWith(isLoading: false);

        ref.read(appNotifierProvider.notifier).setAutoTitle(design.title);
        ref
            .read(insightProvider.notifier)
            .append(insight: design.toInsight(embedding));
      }, onRetry: (e, i) => print("_updateDesign failed $i : $e"));
    } catch (e) {
      state = state.copyWith(isLoading: false);
      print("Summary error $e");
    }
  }

  String _buildPrompt(String content, GeminiFunctionResponse call) {
    return "<Additional instructions> ${call.args} <User> $content";
  }
}

final summaryAgentProvider =
    NotifierProvider<SummaryAgentNotifier, SummaryAgentState>(
      () => SummaryAgentNotifier(),
    );
