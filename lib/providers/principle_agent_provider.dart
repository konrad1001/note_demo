import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:note_demo/agents/agent_utils.dart';
import 'package:note_demo/agents/gpt_agent.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/providers/app_notifier.dart';
import 'package:note_demo/providers/note_content_provider.dart';
import 'package:note_demo/providers/study_content_provider.dart';

part 'principle_agent_provider.freezed.dart';

class PrincipleAgentNotifier extends Notifier<PrincipleAgentState> {
  @override
  PrincipleAgentState build() {
    return PrincipleAgentState.initial();
  }

  void runPrinciple() {
    final noteContent = ref.read(noteContentProvider);
    final noteContentNotifier = ref.read(noteContentProvider.notifier);

    if ((noteContent.text.length - noteContent.previousContent.length).abs() >
        20) {
      print("prev: ${noteContent.previousContent}");
      print("next: ${noteContent.text}");

      noteContentNotifier.setPreviousContent(noteContent.text);

      // _runPrinciple(noteContent.text);
    }
  }

  void _runPrinciple(String noteContent) async {
    final model = GPTAgent<PrincipleResponse>(role: AgentRole.principle);

    try {
      final response = await model.fetch(_buildPrompt());
      print("${response.agentNotes}, tools: ${response.tool}");

      state = PrincipleAgentState.idle(
        valid: response.valid,
        tool: response.tool,
        agentNotes: response.agentNotes,
      );
    } catch (e) {
      print("Error $e");
    }
  }

  String _buildPrompt() {
    final noteContent = ref.read(noteContentProvider);
    final studyDesign = ref.read(appNotifierProvider);

    return "<AgentNotes> ${state.agentNotes} <Studyplan> ${studyDesign.design ?? StudyDesign.empty()} <Resources> ${studyDesign.tools} <User> ${noteContent.text}";
  }
}

final principleAgentProvider =
    NotifierProvider<PrincipleAgentNotifier, PrincipleAgentState>(
      () => PrincipleAgentNotifier(),
    );

@freezed
abstract class PrincipleAgentState with _$PrincipleAgentState {
  const factory PrincipleAgentState.initial({@Default("") String agentNotes}) =
      PrincipleAgentStateInitial;
  const factory PrincipleAgentState.idle({
    required bool valid,
    required List<String> tool,
    @Default("") String agentNotes,
  }) = PrincipleAgentStateIdle;
}
