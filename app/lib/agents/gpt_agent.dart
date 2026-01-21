import 'package:note_demo/agents/utils/agent_utils.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/util/gemini_service.dart';

class GPTAgent<T extends AgentResponse> {
  final AgentRole role;
  late GeminiService _geminiService;

  bool _busy = false;

  GPTAgent({required this.role}) {
    _geminiService = GeminiService(
      canCallTools: role.canCallTools,
      responseSchema: role.responseSchema,
      thinkingBudget: role.thinkingBudget,
    );
  }

  Future<T> fetch(String message, {bool verbose = false}) async {
    if (_busy) {
      print("Agent ${role.name} busy");
      throw Exception("Agent ${role.name} is busy");
    }

    _busy = true;

    final prompt = '${role.systemInstructions}. $message';

    try {
      final response = await _geminiService.fetch(prompt, verbose: verbose);
      _busy = false;
      return role.convert(response);
    } catch (e) {
      _busy = false;
      rethrow;
    }
  }
}
