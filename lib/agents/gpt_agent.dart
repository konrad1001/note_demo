import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:note_demo/widgets/models.dart';

abstract class GPTAgent {
  static Future<GeminiResponse> fetch(String message) async {
    final prompt =
        """
          The following is a set of notes created by a student about a topic. Write a short summary (20 words) of the note 
          topic, and then write a quick study plan. If possible, infer the topic title. Dont use any titles, or any of your own prefacing
           Notes: $message
          """;

    const apiKey = String.fromEnvironment("GEMINI_KEY");
    print(apiKey);
    const url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

    final headers = {
      'Content-Type': 'application/json',
      'x-goog-api-key': apiKey,
    };

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      "generationConfig": {
        "maxOutputTokens": 100,
        "thinkingConfig": {"thinkingBudget": 0},
      },
    });

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
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
}
