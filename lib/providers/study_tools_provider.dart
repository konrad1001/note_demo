import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:note_demo/agents/agent_utils.dart';
import 'package:note_demo/agents/gpt_agent.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/models/gemini_response.dart';
import 'package:note_demo/providers/app_notifier.dart';
import 'package:note_demo/providers/models.dart';
import 'package:note_demo/providers/note_content_provider.dart';
import 'package:note_demo/providers/principle_agent_provider.dart';
import 'package:note_demo/providers/study_content_provider.dart';

class StudyResourcesNotifier extends Notifier<StudyToolsState> {
  @override
  StudyToolsState build() {
    _subscribeToPrinciple();
    return StudyToolsState();
  }

  void _subscribeToPrinciple() {
    ref.listen<PrincipleAgentState>(principleAgentProvider, (prev, next) {
      switch (next) {
        case PrincipleAgentStateIdle idle:
          if (idle.valid && idle.tool.contains('resource')) {
            _updateTools();
          }
        default: // continue
      }
    });
  }

  void _updateTools() async {
    state = state.copyWith(isLoading: true);

    await Future.delayed(Duration(seconds: 1));

    final appNotifer = ref.read(appNotifierProvider.notifier);

    final model = GPTAgent<StudyTools>(role: AgentRole.toolBuilder);

    try {
      final response = await model.fetch(_buildPrompt());
      appNotifer.setTools(state.tools + [response]);

      state = state.copyWith(tools: state.tools + [response], isLoading: false);
    } catch (e) {
      print(e);
      state = state.copyWith(
        isLoading: false,
        tools:
            state.tools +
            [StudyTools.flashcards(id: "id", title: "$e", items: [])],
      );
    }
  }

  String _buildPrompt() {
    final noteContent = ref.read(noteContentProvider);
    final diff = ref.read(principleAgentProvider).diff?.additions ?? "";
    final studyDesign = ref.read(appNotifierProvider);

    return "<Resources> ${studyDesign.tools} <User> $diff";
  }
}

final studyResourcesProvider =
    NotifierProvider<StudyResourcesNotifier, StudyToolsState>(
      () => StudyResourcesNotifier(),
    );
