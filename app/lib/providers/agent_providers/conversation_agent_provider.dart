import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/agents/gpt_agent.dart';
import 'package:note_demo/agents/models.dart';
import 'package:note_demo/agents/utils/agent_utils.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/providers/agent_providers/principle_agent_provider.dart';
import 'package:note_demo/providers/insight_notifier.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:note_demo/providers/note_content_provider.dart';
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

    final newInsight = _insight(ChatRole.user, message);

    insightNotifier.append(insight: newInsight);
    final chatHistory = _generateHistory(insights + [newInsight]);

    final buffer = StringBuffer();
    var isFirstChunk = true;
    var isCalling = false;

    try {
      await for (final chunk in _model.stream(
        message,
        history: chatHistory,
        injectedSystemInstructions: principle.fingerprint,
      )) {
        if (chunk.calls.isNotEmpty) {
          print("calling: ${chunk.calls}");
          isCalling = true;

          state = state.copyWith(isLoading: false, calls: chunk.calls);
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
    } finally {
      if (!isCalling) {
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

  String _message(String message) {
    final noteContent = ref.read(noteContentProvider);

    return "$message";
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
              return ChatTurn(chat.role, chat.body);
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
