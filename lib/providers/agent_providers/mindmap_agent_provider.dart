import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/agents/gpt_agent.dart';
import 'package:note_demo/agents/utils/agent_utils.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/providers/agent_providers/principle_agent_provider.dart';
import 'package:note_demo/providers/insight_notifier.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:note_demo/providers/note_content_provider.dart';
import 'package:note_demo/util/future.dart';

const kMindmapNotifierToolName = "mindmap";

class MindmapAgentNotifier extends Notifier<MindmapAgentState> {
  final _model = GPTAgent<MindMapResponse>(role: AgentRole.mapper);

  @override
  MindmapAgentState build() {
    _subscribeToPrinciple();
    return MindmapAgentState();
  }

  void _subscribeToPrinciple() {
    ref.listen<PrincipleAgentState>(principleAgentProvider, (prev, next) {
      final call = next.callsMe(kMindmapNotifierToolName);
      if (next.valid && call != null) {
        _update();
      }
    });
  }

  void _update() async {
    state = state.copyWith(isLoading: true);
    final notes = ref.read(noteContentProvider).text;

    try {
      await retry(() async {
        final response = await _model.fetch("<User> $notes");
        ref
            .read(insightProvider.notifier)
            .append(insight: response.toInsight());
        state = state.copyWith(isLoading: false);
      });
    } catch (e) {
      state = state.copyWith(isLoading: false);
      print("Mindmap agent error $e");
    }

    print("Final state = $state");
  }
}

final mindmapAgentProvider =
    NotifierProvider<MindmapAgentNotifier, MindmapAgentState>(
      () => MindmapAgentNotifier(),
    );
