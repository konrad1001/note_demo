import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/agents/agent_utils.dart';
import 'package:note_demo/agents/gpt_agent.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/providers/note_content_provider.dart';

class PrincipleAgentNotifier extends Notifier<PrincipleResponse?> {
  @override
  PrincipleResponse? build() {
    return null;
  }

  void runPrinciple() {
    final noteContent = ref.read(noteContentProvider);
    final noteContentNotifier = ref.read(noteContentProvider.notifier);

    if ((noteContent.text.length - noteContent.previousContent.length).abs() >
        20) {
      _runPrinciple(noteContent.text);
      noteContentNotifier.setPreviousContent(noteContent.text);
    }
  }

  void _runPrinciple(String noteContent) async {
    final model = GPTAgent<PrincipleResponse>(role: AgentRole.principle);

    try {
      final response = await model.fetch(noteContent);
      print(response);

      state = response;
    } catch (e) {
      print("Error $e");
    }
  }
}

final principleAgentProvider =
    NotifierProvider<PrincipleAgentNotifier, PrincipleResponse?>(
      () => PrincipleAgentNotifier(),
    );
