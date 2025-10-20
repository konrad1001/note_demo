import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:note_demo/agents/agent_utils.dart';
import 'package:note_demo/widgets/models.dart';

const kUrl =
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

class GPTAgent {
  final AgentRole role;

  GPTAgent({required this.role});

  Future<GeminiResponse> fetch(String message) async {
    final prompt = '${role.systemInstructions}. $message';

    final response = await http.post(
      Uri.parse(kUrl),
      headers: _headers,
      body: _body(prompt),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Response: ${jsonEncode(data)}');

      final modelResponse = GeminiResponse.fromJson(data);

      return modelResponse;
    } else {
      throw Exception('Failed to fetch data: ${response.statusCode}');
    }
  }

  Map<String, String> get _headers {
    const apiKey = String.fromEnvironment("GEMINI_KEY");

    return {'Content-Type': 'application/json', 'x-goog-api-key': apiKey};
  }

  String _body(String prompt) => jsonEncode({
    'contents': [
      {
        'parts': [
          {'text': prompt},
        ],
      },
    ],
    "generationConfig": {
      "maxOutputTokens": 500,
      "thinkingConfig": {"thinkingBudget": 0},
    },
  });
}
