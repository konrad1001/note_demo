import 'package:diff_match_patch/diff_match_patch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:note_demo/agents/agent_utils.dart';
import 'package:note_demo/agents/gpt_agent.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/providers/app_notifier.dart';
import 'package:note_demo/providers/note_content_provider.dart';
import 'package:note_demo/providers/study_content_provider.dart';
import 'package:note_demo/util/diff.dart';

part 'principle_agent_provider.freezed.dart';

class PrincipleAgentNotifier extends Notifier<PrincipleAgentState> {
  @override
  PrincipleAgentState build() {
    return PrincipleAgentState.initial();
  }

  void runPrinciple() {
    final noteContent = ref.read(noteContentProvider);
    final noteContentNotifier = ref.read(noteContentProvider.notifier);

    final prev = noteContent.previousContent;
    final next = noteContent.text;

    final diffTool = DiffTool();
    final diff = diffTool.diff(prev, next);

    if (diff.size > 150) {
      noteContentNotifier.setPreviousContent(next);
      _runPrinciple(diff);
    }
  }

  void _runPrinciple(UserDiff diff) async {
    final model = GPTAgent<PrincipleResponse>(role: AgentRole.principle);

    try {
      final response = await model.fetch(_buildPrompt(diff));
      print("${response.agentNotes}, tools: ${response.tool}");

      state = PrincipleAgentState.idle(
        valid: response.valid,
        tool: response.tool,
        agentNotes: response.agentNotes,
        diff: diff,
      );
    } catch (e) {
      print("Error $e");
    }
  }

  String _buildPrompt(UserDiff diff) {
    final appState = ref.read(appNotifierProvider);

    print(
      "<AgentNotes> ${state.agentNotes} <Studyplan> ${appState.design ?? StudyDesign.empty()} <Resources> ${appState.toolsOverview} <UserAdded> ${diff.additions} <UserDeleted> ${diff.deletions}",
    );

    return "<AgentNotes> ${state.agentNotes} <Studyplan> ${appState.design ?? StudyDesign.empty()} <Resources> ${appState.toolsOverview} <UserAdded> ${diff.additions} <UserDeleted> ${diff.deletions}";
  }
}

final principleAgentProvider =
    NotifierProvider<PrincipleAgentNotifier, PrincipleAgentState>(
      () => PrincipleAgentNotifier(),
    );

@freezed
abstract class PrincipleAgentState with _$PrincipleAgentState {
  const factory PrincipleAgentState.initial({
    @Default("") String agentNotes,
    UserDiff? diff,
  }) = PrincipleAgentStateInitial;
  const factory PrincipleAgentState.idle({
    required bool valid,
    required List<String> tool,
    @Default("") String agentNotes,
    UserDiff? diff,
  }) = PrincipleAgentStateIdle;
}
