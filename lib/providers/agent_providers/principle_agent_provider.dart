import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/agents/utils/agent_utils.dart';
import 'package:note_demo/agents/gpt_agent.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/models/gemini_response.dart';
import 'package:note_demo/providers/agent_providers/observer_agent_provider.dart';
import 'package:note_demo/providers/app_notifier.dart';
import 'package:note_demo/providers/insight_notifier.dart';
import 'package:note_demo/providers/mock_service_provider.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:note_demo/providers/note_content_provider.dart';
import 'package:note_demo/util/diff.dart';
import 'package:note_demo/util/future.dart';

class PrincipleAgentNotifier extends Notifier<PrincipleAgentState> {
  DateTime? _lastCallTime;

  static const _kMinDiff = 10;
  static const _kMinTime = 8;

  final _model = GPTAgent<PrincipleResponse>(role: AgentRole.principle);

  @override
  PrincipleAgentState build() {
    return PrincipleAgentState(valid: true);
  }

  void runPrinciple(Object? param) async {
    final now = DateTime.now();
    final timeSinceLastCall = _lastCallTime != null
        ? now.difference(_lastCallTime!).inSeconds
        : 31;

    print("$timeSinceLastCall");

    final noteContent = ref.read(noteContentProvider);
    final noteContentNotifier = ref.read(noteContentProvider.notifier);

    final prev = noteContent.previousContent;
    final next = noteContent.text;

    final diffTool = DiffTool();
    final diff = diffTool.diff(prev, next);

    if (diff.size > _kMinDiff && timeSinceLastCall > _kMinTime) {
      noteContentNotifier.setPreviousContent(next);
      try {
        await _runPrinciple(diff);
        _lastCallTime = now;
      } catch (e) {
        noteContentNotifier.setPreviousContent(prev);
      }
    }
  }

  Future<void> _runPrinciple(UserDiff diff) async {
    final isMock = ref.read(mockServiceProvider);
    if (isMock) return;

    state = state.copyWith(isLoading: true, calls: []);

    try {
      await retry(() async {
        print("Calling with ${diff.all}");
        final response = await _model.fetch(_buildPrompt(diff), verbose: false);

        print("Principle called: ${response.calls.map((call) => call.name)}");

        state = PrincipleAgentState(
          valid: true,
          calls: [GeminiFunctionResponse(name: "mindmap")],
          agentNotes: "",
          diff: diff,
        );
      }, onRetry: (e, i) => print("_runPrinciple failed $i : $e"));
    } catch (e) {
      print("_runPrinciple: Error $e");
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  String _buildPrompt(UserDiff diff) {
    final appHistory = ref
        .read(appNotifierProvider)
        .currentFileMetaData
        .appHistory;
    // print(
    //   "Prompting principle with: <AgentHistory> $appHistory  <UserAdded> ...",
    // );
    return "<AgentHistory> $appHistory  <UserAdded> ${diff.additions} <UserDeleted> ${diff.deletions}";
  }
}

final principleAgentProvider =
    NotifierProvider<PrincipleAgentNotifier, PrincipleAgentState>(
      () => PrincipleAgentNotifier(),
    );
