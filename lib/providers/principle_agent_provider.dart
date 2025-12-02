import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/agents/utils/agent_utils.dart';
import 'package:note_demo/agents/gpt_agent.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/providers/app_notifier.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:note_demo/providers/note_content_provider.dart';
import 'package:note_demo/util/diff.dart';

class PrincipleAgentNotifier extends Notifier<PrincipleAgentState> {
  @override
  PrincipleAgentState build() {
    return PrincipleAgentState.initial();
  }

  void runPrinciple() async {
    final noteContent = ref.read(noteContentProvider);
    final noteContentNotifier = ref.read(noteContentProvider.notifier);

    final prev = noteContent.previousContent;
    final next = noteContent.text;

    final diffTool = DiffTool();
    final diff = diffTool.diff(prev, next);

    if (diff.size > 150) {
      noteContentNotifier.setPreviousContent(next);
      try {
        await _runPrinciple(diff);
      } catch (e) {
        noteContentNotifier.setPreviousContent(prev);
      }
    }
  }

  Future<void> _runPrinciple(UserDiff diff) async {
    final model = GPTAgent<PrincipleResponse>(role: AgentRole.principle);

    state = state.copyWith(isLoading: true);

    try {
      final response = await model.fetch(_buildPrompt(diff));

      print("Principle called: ${response.calls.map((call) => call.name)}");

      state = PrincipleAgentState.idle(
        valid: true,
        calls: response.calls,
        agentNotes: "",
        diff: diff,
      );
    } catch (e) {
      print("Error $e");
      rethrow;
    }
  }

  String _buildPrompt(UserDiff diff) {
    final appState = ref.read(appNotifierProvider);
    return "<AgentNotes> ${state.agentNotes} <Studyplan> ${appState.currentFileMetaData.design ?? StudyDesign.empty()} <Resources> ${appState.toolsOverview} <UserAdded> ${diff.additions} <UserDeleted> ${diff.deletions}";
  }
}

final principleAgentProvider =
    NotifierProvider<PrincipleAgentNotifier, PrincipleAgentState>(
      () => PrincipleAgentNotifier(),
    );
