import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/agents/agent_utils.dart';
import 'package:note_demo/agents/gpt_agent.dart';
import 'package:note_demo/app/app_notifier.dart';
import 'package:note_demo/widgets/models.dart';

final agentProvider = FutureProvider<GeminiResponse>((ref) async {
  final model = GPTAgent(role: AgentRole.principle);
  final notes = ref.watch(appNotifierProvider);
  final response = await model.fetch(notes);

  return response;
});
