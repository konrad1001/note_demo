import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:note_demo/models/gemini_response.dart';

const kModelId = "gemini-2.5-flash";

const kUrl =
    'https://generativelanguage.googleapis.com/v1beta/models/$kModelId:generateContent';

class GeminiService {
  final bool canCallTools;

  GeminiService({this.canCallTools = false});

  Future<GeminiResponse> fetch(String prompt) async {
    final response = await http.post(
      Uri.parse(kUrl),
      headers: _headers,
      body: _body(prompt),
    );

    if (response.statusCode == 200) {
      print(response.body);
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
      {
        "name": "save",
        "description":
            """(internal) This function saves to your agent memory that you will use in future iterations. Use this
            function to save information you deem important, such as what tools you have already called, to prevent overuse.
            """,
        "parameters": {
          "type": "object",
          "properties": {
            "agent_notes": {"type": "string"},
          },
          "propertyOrdering": ["agent_notes"],
          "required": ["agent_notes"],
        },
      },
      {
        "name": "overview",
        "description":
            "This function updates the title and short summary of the full notes document. ",
        "parameters": {
          "type": "object",
          "properties": {
            "additional_instructions": {"type": "string"},
          },
          "propertyOrdering": ["additional_instructions"],
        },
      },
      {
        "name": "resources",
        "description":
            "This function generates resources to supplement the users study. They can be one of flashcards, q&as or keywords. Use the additional instructions parameter to specify further instructions as to which of these should be generated.",
        "parameters": {
          "type": "object",
          "properties": {
            "additional_instructions": {"type": "string"},
          },
          "propertyOrdering": ["additional_instructions"],
        },
      },
      {
        "name": "research",
        "description":
            "This function triggers a search for additional material online to supplement the users notes.",
        "parameters": {
          "type": "object",
          "properties": {
            "additional_instructions": {"type": "string"},
          },
          "propertyOrdering": ["additional_instructions"],
        },
      },
    ],
  };
}
