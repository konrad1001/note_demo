import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/agents/agent_utils.dart';
import 'package:note_demo/agents/gpt_agent.dart';
import 'package:note_demo/providers/note_content_provider.dart';
import 'package:note_demo/mock/mocks.dart';
import 'package:note_demo/models/gemini_response.dart';
import 'package:note_demo/providers/file_service_provider.dart';
import 'package:note_demo/providers/mock_service_provider.dart';

final agentProvider = FutureProvider<GeminiResponse>((ref) async {
  final useMock = ref.watch(mockServiceProvider);

  if (useMock) {
    return MockBuilder.geminiResponse;
  }

  final model = GPTAgent(role: AgentRole.designer);
  final notes = ref.watch(noteContentProvider);
  final response = await model.fetch(notes);

  return response;
});
