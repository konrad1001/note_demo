import 'package:note_demo/agents/utils/agent_utils.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/util/gemini_service.dart';

class GPTAgent<T extends AgentResponse> {
  final AgentRole role;
  late GeminiService _geminiService;

  GPTAgent({required this.role}) {
    _geminiService = GeminiService(canCallTools: role.canCallTools);
  }

  Future<T> fetch(String message, {bool verbose = false}) async {
    final prompt = '${role.systemInstructions}. $message';

    try {
      final response = await _geminiService.fetch(prompt, verbose: verbose);
      return role.convert(response);
    } catch (e) {
      rethrow;
    }
  }
}
