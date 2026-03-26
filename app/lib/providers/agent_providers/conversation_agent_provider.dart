import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/agents/gpt_agent.dart';
import 'package:note_demo/agents/chat_turn.dart';
import 'package:note_demo/agents/utils/agent_utils.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/models/insights.dart';
import 'package:note_demo/providers/agent_providers/principle_agent_provider.dart';
import 'package:note_demo/providers/app_notifier.dart';
import 'package:note_demo/providers/insight_notifier.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:note_demo/providers/note_content_provider.dart';
import 'package:note_demo/util/date_time.dart';
import 'package:note_demo/util/error/errors.dart';
import 'package:note_demo/util/future.dart';

class ConversationAgentNotifier extends Notifier<ConversationAgentState> {
  final _model = GPTAgent<TextResponse>(role: AgentRole.conversation);

  @override
  ConversationAgentState build() {
    return ConversationAgentState();
  }

  void chat(String message) async {
    state = state.copyWith(isLoading: true);

    final insightNotifier = ref.read(insightProvider.notifier);
    final insights = ref.read(insightProvider);
    final principle = ref.read(principleAgentProvider);
    final appNotifier = ref.read(appNotifierProvider);

    final newInsight = _insight(ChatRole.user, message);

    insightNotifier.append(insight: newInsight);
    final chatHistory = _generateHistory(insights);

    final buffer = StringBuffer();
    var isFirstChunk = true;
    var isCalling = false;
    var failed = false;

    final key = ref.read(appNotifierProvider.notifier).apiKey;

    try {
      await for (final chunk in _model.stream(
        message,
        verbose: true,
        history: chatHistory,
        injectedSystemInstructions: _injectedSystemPrompt(
          principle.fingerprint,
          appNotifier.currentFileMetaData.keyDate,
        ),
        key: key,
      )) {
        if (chunk.calls.isNotEmpty) {
          print("calling: ${chunk.calls}");
          isCalling = true;

          state = state.copyWith(
            isLoading: false,
            calls: chunk.calls,
            callback: _callback,
          );
          continue;
        } else {
          buffer.write(chunk.content);

          if (isFirstChunk) {
            insightNotifier.append(
              insight: _insight(
                ChatRole.agent,
                buffer.toString(),
                isStreaming: true,
              ),
            );
            isFirstChunk = false;
          } else {
            insightNotifier.updateLatest(
              insight: _insight(
                ChatRole.agent,
                buffer.toString(),
                isStreaming: true,
              ),
            );
          }
          await Future.delayed(Duration(milliseconds: 300));
        }
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      print("Conversation agent error $e");
      handleException(e, ref);
      failed = true;
    } finally {
      if (!isCalling && !failed) {
        insightNotifier.updateLatest(
          insight: _insight(
            ChatRole.agent,
            buffer.toString(),
            isStreaming: false,
          ),
        );
      }

      state = state.copyWith(isLoading: false, calls: []);
    }
  }

  void _callback(String? resultText) async {
    print("Running callback");
    var result = resultText;
    if (resultText == null) {
      result = "Generation Completed Successfully";
    }

    final insights = ref.read(insightProvider);
    final insightNotifier = ref.read(insightProvider.notifier);
    final functionCallResponse = Insight.meta(
      notes: "Result of function call: $result",
      queryEmbedding: null,
    );

    insightNotifier.append(insight: functionCallResponse);
    final history = _generateHistory(insights);

    final response = await _model.fetch(
      "Result of function call: $result",
      history: history,
      key: ref.read(appNotifierProvider.notifier).apiKey,
    );

    insightNotifier.append(
      insight: Insight.chat(
        role: ChatRole.agent,
        body: response.content,
        created: DateTime.now(),
        queryEmbedding: null,
      ),
    );
  }

  String _injectedSystemPrompt(String? fingerprint, DateTime? keyDate) {
    final prompt = "$fingerprint";
    if (keyDate != null) {
      return "$prompt. User has a key date scheduled for ${keyDate.formatDM()}. The current date is ${DateTime.now().formatDM()}";
    } else {
      return prompt;
    }
  }

  Insight _insight(ChatRole role, String body, {bool isStreaming = false}) =>
      Insight.chat(
        role: role,
        body: body,
        created: DateTime.now(),
        queryEmbedding: null,
        isStreaming: isStreaming,
      );

  List<ChatTurn> _generateHistory(Insights insights) {
    return insights
        .map(
          (i) => i.mapOrNull(
            chat: (chat) {
              // print("${chat.role}, ${chat.body}");
              return ChatTurn(chat.role, chat.body, null);
            },
            functionCall: (call) {
              // print("${ChatRole.function}, ${"text"}");
              return ChatTurn(ChatRole.function, null, call.function);
            },
          ),
        )
        .nonNulls
        .toList();
  }
}

final conversationAgentProvider =
    NotifierProvider<ConversationAgentNotifier, ConversationAgentState>(
      () => ConversationAgentNotifier(),
    );
