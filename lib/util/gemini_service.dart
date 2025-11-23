import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:note_demo/models/gemini_response.dart';

const kUrl =
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

class GeminiService {
  Future<GeminiResponse> fetch(String prompt) async {
    final response = await http.post(
      Uri.parse(kUrl),
      headers: _headers,
      body: _body(prompt),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

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
      "maxOutputTokens": 600,
      "thinkingConfig": {"thinkingBudget": 0},
    },
    "tools": [
      {"urlContext": {}},
    ],
  });
}
