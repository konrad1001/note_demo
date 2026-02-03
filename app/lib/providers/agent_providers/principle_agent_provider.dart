import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/agents/utils/agent_utils.dart';
import 'package:note_demo/agents/gpt_agent.dart';
import 'package:note_demo/agents/utils/embedding_service.dart';
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
import 'package:note_demo/util/math/dot.dart';

class PrincipleAgentNotifier extends Notifier<PrincipleAgentState> {
  DateTime? _lastCallTime;

  static const _kMinDiff = 100;
  static const _kMinTime = 8;
  static const _similarityThreshold = 0.8;

  final _model = GPTAgent<PrincipleResponse>(role: AgentRole.principle);
  final _embedder = EmbeddingService();

  @override
  PrincipleAgentState build() {
    return PrincipleAgentState();
  }

  void runPrinciple(String value) async {
    final now = DateTime.now();
    final timeSinceLastCall = _lastCallTime != null
        ? now.difference(_lastCallTime!).inSeconds
        : 31;

    final noteContent = ref.read(noteContentProvider);
    final noteContentNotifier = ref.read(noteContentProvider.notifier);

    final prev = noteContent.previousContent;
    final next = noteContent.text;

    final diffTool = DiffTool();
    final diff = diffTool.diff(prev, value);

    if (diff.size > _kMinDiff && timeSinceLastCall > _kMinTime) {
      noteContentNotifier.setPreviousContent(value);
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

    final isFresh = await _checkWithInsights(diff.additions);
    if (!isFresh) {
      state = state.copyWith(isLoading: false);
      return;
    }

    try {
      await retry(() async {
        final response = await _model.fetch(_buildPrompt(diff), verbose: false);

        print(response);

        var history = List<String>.from(state.callHistory);
        var calls = response.calls;

        if (calls.map((call) => call.name).contains("invalid")) {
          print("Content was invalid");
          calls = [];
        } else {
          if (history.length == 4) {
            history = history.sublist(1);
          }
          history.add("${response.calls.map((call) => call.name)}");
        }

        state = PrincipleAgentState(
          // calls: [GeminiFunctionResponse(name: "mindmap")],
          calls: calls,
          callHistory: history,
          diff: diff,
        );
      }, onRetry: (e, i) {});
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  String _buildPrompt(UserDiff diff) {
    final insightPreferences = ref
        .read(insightProvider.notifier)
        .allUserRatings;

    final history = state.callHistory.indexed.map(
      (e) => "T[${e.$1}] called: ${e.$2}",
    );

    return "<AgentHistory> $history <UserPreferences> $insightPreferences  <UserAdded> ${diff.additions}";
  }

  Future<bool> _checkWithInsights(String content) async {
    // print("Embedding: $content");
    final emb = await _embedder.embed(content);

    final insights = ref.read(insightProvider);
    for (final i in insights) {
      final qEmb = i.queryEmbedding;
      if (qEmb != null) {
        final sim = dot(qEmb, emb);
        if (sim > _similarityThreshold) {
          print("Content is too stale, not generating");
          return false;
        }
      }
    }

    return true;
  }
}

final principleAgentProvider =
    NotifierProvider<PrincipleAgentNotifier, PrincipleAgentState>(
      () => PrincipleAgentNotifier(),
    );
