import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:note_demo/agents/agent_utils.dart';
import 'package:note_demo/agents/gpt_agent.dart';
import 'package:note_demo/widgets/models.dart';

class DemoWidgetCubit extends Cubit<AppState> {
  DemoWidgetCubit()
    : super(
        AppState(controller: TextEditingController(), modelAnswer: "Empty"),
      ) {
    agent = GPTAgent(role: AgentRole.principle);
    researcher = GPTAgent(role: AgentRole.researcher);
  }

  late GPTAgent agent;
  late GPTAgent researcher;

  fetch() async {
    if (state.controller.text.length < 20) return;

    emit(state.copyWith(isLoading: true));

    try {
      final response = await agent.fetch(state.controller.text);
      final principalAnswer = response.firstCandidateText;
      final researchResponse = await researcher.fetch(
        '<PrincipalAnswer>$principalAnswer <Notes>${state.controller.text}',
      );
      final researchAnswer = researchResponse.firstCandidateText;

      final combinedAnswer =
          '$principalAnswer\n\nAdditional Study Material:\n$researchAnswer';

      emit(state.copyWith(modelAnswer: combinedAnswer, isLoading: false));
    } catch (e) {
      emit(state.copyWith(modelAnswer: "Error: $e", isLoading: false));
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
