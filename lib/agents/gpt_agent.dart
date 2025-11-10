import 'package:note_demo/agents/agent_utils.dart';
import 'package:note_demo/models/gemini_response.dart';
import 'package:note_demo/util/gemini_service.dart';

class GPTAgent {
  final AgentRole role;
  final GeminiService _geminiService = GeminiService();

  GPTAgent({required this.role});

  Future<GeminiResponse> fetch(String message) async {
    final prompt = '${role.systemInstructions}. $message';
    return await _geminiService.fetch(prompt);
  }
}
