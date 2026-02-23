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
  final String? systemInstructions;
  final Map? responseSchema;
  final int thinkingBudget;
  final bool streamContent;

  GeminiService({
    this.availableTools = const [],
    this.responseSchema,
    this.thinkingBudget = 0,
    this.systemInstructions,
    this.streamContent = false,
  });

  Future<GeminiResponse> fetch(
    String prompt, {
    List<ChatTurn> history = const [],
    bool verbose = false,
    String? injectedSystemInstructions,
  }) async {
    final response = await http.post(
      _url(modelId: kGeminiFlashId, withStreaming: false),
      headers: _headers,
      body: _body(prompt, history, injectedSystemInstructions),
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

  Stream<GeminiResponse> stream(
    String prompt, {
    List<ChatTurn> history = const [],
    bool verbose = false,
    String? injectedSystemInstructions,
  }) async* {
    var client = http.Client();
    try {
      const geminiKey = String.fromEnvironment("GEMINI_KEY");
      final request = http.Request(
        'POST',
        _url(modelId: kGeminiFlashId, withStreaming: true),
      );
      request.headers['Content-Type'] = 'application/json';
      request.headers['x-goog-api-key'] = geminiKey;

      request.body = _body(prompt, history, injectedSystemInstructions);

      final streamedResponse = await request.send();

      final buffer = StringBuffer();
      var inString = false;
      var depth = 0;
      if (streamedResponse.statusCode == 200) {
        await for (final chunk in streamedResponse.stream.transform(
          utf8.decoder,
        )) {
          for (final char in chunk.split('')) {
            buffer.write(char);

            if (char == '"') {
              inString = !inString;
              continue;
            }

            if (!inString) {
              if (char == '{') depth++;
              if (char == '}') depth--;
            }

            if (depth == 0 && buffer.isNotEmpty) {
              final segment = buffer.toString().trim();
              if (segment.startsWith("{") || segment.endsWith("}")) {
                final data = jsonDecode(segment);
                yield GeminiResponse.fromJson(data);
              }

              buffer.clear();
            }
          }
        }
      }
    } finally {
      client.close();
    }
  }

  Uri _url({required String modelId, bool withStreaming = false}) => Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/$modelId:${withStreaming ? "streamGenerateContent" : "generateContent"}',
  );

  Map<String, String> get _headers {
    const apiKey = String.fromEnvironment("GEMINI_KEY");

    return {'Content-Type': 'application/json', 'x-goog-api-key': apiKey};
  }

  String _body(
    String prompt,
    List<ChatTurn> history,
    String? injectedSystemInstructions,
  ) {
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
    if (systemInstructions != null) {
      body["system_instruction"] = {
        "parts": [
          {"text": "$systemInstructions ${injectedSystemInstructions ?? ""}"},
        ],
      };
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
