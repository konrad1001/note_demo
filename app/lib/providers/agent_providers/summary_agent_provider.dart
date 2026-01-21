import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/agents/utils/agent_utils.dart';
import 'package:note_demo/agents/gpt_agent.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/models/gemini_response.dart';
import 'package:note_demo/providers/app_notifier.dart';
import 'package:note_demo/providers/insight_notifier.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:note_demo/providers/note_content_provider.dart';
import 'package:note_demo/providers/agent_providers/principle_agent_provider.dart';
import 'package:note_demo/util/future.dart';

const kStudyContentNotifierToolName = "overview";

class SummaryAgentNotifier extends Notifier<SummaryAgentState> {
  final _model = GPTAgent<StudyDesign>(role: AgentRole.designer);

  @override
  SummaryAgentState build() {
    _subscribeToPrinciple();

    return SummaryAgentState();
  }

  void _subscribeToPrinciple() {
    ref.listen<PrincipleAgentState>(principleAgentProvider, (prev, next) {
      final call = next.callsMe(kStudyContentNotifierToolName);

      if (next.valid && !next.isLoading && call != null) {
        _updateDesign(call);
      }
    });
  }

  _updateDesign(GeminiFunctionResponse call) async {
    state = state.copyWith(isLoading: true);

    try {
      await retry(() async {
        final design = await _model.fetch(_buildPrompt(call), verbose: false);

        state = state.copyWith(isLoading: false);

        ref.read(appNotifierProvider.notifier).setAutoTitle(design.title);
        ref.read(insightProvider.notifier).append(insight: design.toInsight());
      }, onRetry: (e, i) => print("_updateDesign failed $i : $e"));
    } catch (e) {
      print("Error $e");
    }
  }

  String _buildPrompt(GeminiFunctionResponse call) {
    final noteContent = ref.read(noteContentProvider);

    return "<Additional instructions> ${call.args} <User> ${noteContent.text}";
  }
}

final summaryAgentProvider =
    NotifierProvider<SummaryAgentNotifier, SummaryAgentState>(
      () => SummaryAgentNotifier(),
    );
