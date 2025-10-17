import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:note_demo/widgets/models.dart';

class DemoWidgetCubit extends Cubit<AppState> {
  DemoWidgetCubit()
    : super(
        AppState(controller: TextEditingController(), modelAnswer: "Empty"),
      ) {
    print("init");
  }

  fetch() async {
    if (state.controller.text.length < 20) return;

    emit(state.copyWith(isLoading: true));

    final prompt =
        """
          The following is a set of notes created by a student about a topic. Write a short summary of the note 
          topic, with a quick study plan. If possible, infer the topic title. Notes: ${state.controller.text}
          """;

    print("fetching");
    const apiKey = 'AIzaSyDMxMvo_uSz-tZoUDnhtZreHVd1u4K9t3w';
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

      final model = GeminiResponse.fromJson(data);
      final textAnswer = model.candidates.first.content.parts.first.text;
      print(textAnswer);

      emit(state.copyWith(modelAnswer: textAnswer, isLoading: false));
    } else {
      print('Request failed with status: ${response.statusCode}');
      print('Body: ${response.body}');
    }
  }
}

class AppState {
  final TextEditingController controller;
  final String modelAnswer;
  final bool isLoading;

  AppState({
    required this.controller,
    required this.modelAnswer,
    this.isLoading = false,
  });

  AppState copyWith({
    TextEditingController? controller,
    String? modelAnswer,
    bool? isLoading,
  }) {
    return AppState(
      controller: controller ?? this.controller,
      modelAnswer: modelAnswer ?? this.modelAnswer,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
