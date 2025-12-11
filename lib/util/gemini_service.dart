import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:note_demo/agents/utils/tool_utils.dart';
import 'package:note_demo/models/gemini_response.dart';

const kGeminiFlashId = "gemini-2.5-flash";
const kGeminiFlashLiteId = "gemini-2.5-flash-lite";

const kUrl =
    'https://generativelanguage.googleapis.com/v1beta/models/$kGeminiFlashId:generateContent';

class GeminiService {
  final bool canCallTools;

  GeminiService({this.canCallTools = false});

  Future<GeminiResponse> fetch(String prompt, {bool verbose = false}) async {
    final response = await http.post(
      Uri.parse(kUrl),
      headers: _headers,
      body: _body(prompt),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (verbose) print(response.body);

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
        "role": "user",
        'parts': [
          {'text': prompt},
        ],
      },
    ],
    "generationConfig": {
      "maxOutputTokens": 600,
      "thinkingConfig": {"thinkingBudget": 0},
    },
    "tools": [
      canCallTools ? _tools : {"urlContext": {}},
    ],
  });

  Map get _tools => {
    "functionDeclarations": [
      overviewToolAsMap,
      resourcesToolAsMap,
      researchToolAsMap,
    ],
  };
}
