import 'package:note_demo/agents/models.dart';
import 'package:note_demo/agents/utils/agent_utils.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/agents/utils/gemini_service.dart';
import 'package:note_demo/providers/models/models.dart';

class GPTAgent<T extends AgentResponse> {
  final AgentRole role;
  late GeminiService _geminiService;

  bool _busy = false;

  GPTAgent({required this.role}) {
    _geminiService = GeminiService(
      availableTools: role.availableTools,
      responseSchema: role.responseSchema,
      thinkingBudget: role.thinkingBudget,
      systemInstructions: role.systemInstructions,
    );
  }

  Future<T> fetch(
    String message, {
    bool verbose = false,
    List<ChatTurn> history = const [],
  }) async {
    if (_busy) {
      print("Agent ${role.name} busy");
      throw Exception("Agent ${role.name} is busy");
    }

    _busy = true;

    try {
      final response = await _geminiService.fetch(
        message,
        verbose: verbose,
        history: history,
      );
      _busy = false;
      return role.convert(response);
    } catch (e) {
      _busy = false;
      rethrow;
    }
  }
}
