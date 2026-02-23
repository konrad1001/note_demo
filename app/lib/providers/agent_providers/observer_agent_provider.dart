import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/agents/gpt_agent.dart';
import 'package:note_demo/agents/utils/agent_utils.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/providers/agent_providers/principle_agent_provider.dart';
import 'package:note_demo/providers/app_notifier.dart';
import 'package:note_demo/providers/mock_service_provider.dart';
import 'package:note_demo/providers/models/models.dart';

class ObserverAgentNotifier extends Notifier<ObserverAgentState> {
  @override
  ObserverAgentState build() {
    _subscribeToPrinciple();
    return ObserverAgentState();
  }

  final model = GPTAgent<TextResponse>(role: AgentRole.observer);

  void _subscribeToPrinciple() {
    ref.listen<PrincipleAgentState>(principleAgentProvider, (prev, next) {
      _runObserver(next);
    });
  }

  void _runObserver(PrincipleAgentState principleState) async {
    final isMock = ref.read(mockServiceProvider);
    final appNotifier = ref.read(appNotifierProvider.notifier);

    if (principleState.isLoading == true || isMock) {
      return;
    }

    print("runnning observer");
  }

  String _buildPrompt(PrincipleAgentState state) {
    return "${state.calls.map((e) => "Tool: ${e.name} Args:${e.args}")}";
  }
}

final observerAgentProvider =
    NotifierProvider<ObserverAgentNotifier, ObserverAgentState>(
      () => ObserverAgentNotifier(),
    );
