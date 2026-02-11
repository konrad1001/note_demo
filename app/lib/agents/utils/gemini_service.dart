import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:note_demo/agents/models.dart';
import 'package:note_demo/agents/utils/tool_utils.dart';
import 'package:note_demo/models/gemini_response.dart';

const kGeminiFlashId = "gemini-2.5-flash";
const kGeminiFlashLiteId = "gemini-2.5-flash-lite";

const kUrl =
    'https://generativelanguage.googleapis.com/v1beta/models/$kGeminiFlashId:generateContent';

class GeminiService {
  final List<Map<dynamic, dynamic>> availableTools;
  final Map? responseSchema;
  final int thinkingBudget;

  GeminiService({
    this.availableTools = const [],
    this.responseSchema,
    this.thinkingBudget = 0,
  });

  Future<GeminiResponse> fetch(
    String prompt, {
    List<ChatTurn> history = const [],
    bool verbose = false,
  }) async {
    final response = await http.post(
      Uri.parse(kUrl),
      headers: _headers,
      body: _body(prompt, history),
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

  String _body(String prompt, List<ChatTurn> history) {
    var contents = history.map((m) => m.toJson()).toList();
    contents.add({
      "role": "user",
      'parts': [
        {'text': prompt},
      ],
    });

    final body = {'contents': contents, "generationConfig": _generationConfig};

    if (responseSchema == null) {
      body["tools"] = _tools;
    }

    return jsonEncode(body);
  }

  List get _tools {
    final tools = [
      availableTools.isNotEmpty
          ? {"functionDeclarations": availableTools}
          : {"urlContext": {}},
    ];

    return tools;
  }

  Map get _generationConfig {
    final Map generationConfig = {
      "thinkingConfig": {"thinkingBudget": thinkingBudget},
    };

    if (responseSchema != null) {
      generationConfig["responseMimeType"] = "application/json";
      generationConfig["responseSchema"] = responseSchema!;
    }

    return generationConfig;
  }
}
