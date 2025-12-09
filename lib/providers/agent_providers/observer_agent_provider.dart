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
      print("Observer notes: $next is principle state.");
      _runObserver(next);
    });
  }

  void _runObserver(PrincipleAgentState principleState) async {
    if (principleState.isLoading == true || principleState.calls == []) return;
    final content = _buildPrompt(principleState);

    final isMock = ref.read(mockServiceProvider);
    if (isMock) return;

    final appNotifier = ref.read(appNotifierProvider.notifier);

    try {
      final response = await model.fetch(content);

      state = state.copyWith(
        history:
            state.history + ["T[${state.history.length}] ${response.content}"],
      );
      appNotifier.setAppHistory(state.history);
    } catch (e) {
      print("_runObserver: Error $e");
    }
  }

  String _buildPrompt(PrincipleAgentState state) {
    print(
      "building prompt for observer: ${state.calls.map((e) => "Tool: ${e.name} Args:${e.args}")}",
    );

    return "${state.calls.map((e) => "Tool: ${e.name} Args:${e.args}")}";
  }
}

final observerAgentProvider =
    NotifierProvider<ObserverAgentNotifier, ObserverAgentState>(
      () => ObserverAgentNotifier(),
    );
