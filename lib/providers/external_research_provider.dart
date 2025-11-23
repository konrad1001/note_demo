import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/agents/agent_pipeline.dart';
import 'package:note_demo/agents/agent_utils.dart';
import 'package:note_demo/agents/gpt_agent.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:note_demo/providers/principle_agent_provider.dart';

class ExternalResearchNotifier extends Notifier<String?> {
  @override
  String? build() {
    _subscribeToPrinciple();
    return null;
  }

  void _subscribeToPrinciple() {
    ref.listen<PrincipleAgentState>(principleAgentProvider, (prev, next) {
      switch (next) {
        case PrincipleAgentStateIdle idle:
          if (idle.valid && idle.tool.contains('research')) {
            _updateResearch();
          }
        default: // continue
      }
    });
  }

  void _updateResearch() async {
    print("updating research");

    final diff = ref.read(principleAgentProvider).diff?.additions ?? "";

    final model = GPTAgent<ExternalResearchResponse>(
      role: AgentRole.researcher,
    );

    final pipeline = AgentPipeline();

    final response = await pipeline.fetch(diff);

    state = response;
  }
}

final externalResearchProvider =
    NotifierProvider<ExternalResearchNotifier, String?>(
      () => ExternalResearchNotifier(),
    );
