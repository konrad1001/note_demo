import 'package:note_demo/agents/agent_utils.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/models/gemini_response.dart';
import 'package:note_demo/util/gemini_service.dart';

class GPTAgent<T extends AgentResponse> {
  final AgentRole role;
  final GeminiService _geminiService = GeminiService();

  GPTAgent({required this.role});

  Future<T> fetch(String message) async {
    final prompt = '${role.systemInstructions}. $message';

    try {
      final response = await _geminiService.fetch(prompt);

      return role.fromJson(response.firstCandidateJSON);
    } catch (e) {
      rethrow;
    }
  }
}
