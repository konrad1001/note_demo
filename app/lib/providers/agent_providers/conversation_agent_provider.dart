import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/agents/gpt_agent.dart';
import 'package:note_demo/agents/models.dart';
import 'package:note_demo/agents/utils/agent_utils.dart';
import 'package:note_demo/models/agent_responses/models.dart';
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
    final insightNotifier = ref.read(insightProvider.notifier);
    final insights = ref.read(insightProvider);
    final noteContent = ref.watch(noteContentProvider);

    state = state.copyWith(isLoading: true);

    final newInsight = _insight(ChatRole.user, message);

    insightNotifier.append(insight: newInsight);
    final chatHistory = _generateHistory(insights + [newInsight]);

    try {
      await retry(() async {
        final response = await _model.fetch(
          "<User message> $message  <Notes> ${noteContent.text}",
          history: chatHistory,
        );

        if (response.calls.isNotEmpty) {
          // Make calls
          insightNotifier.append(
            insight: _insight(ChatRole.agent, "Calling: ${response.calls}"),
          );
          state = state.copyWith(isLoading: false, calls: response.calls);
        } else {
          insightNotifier.append(
            insight: _insight(ChatRole.agent, response.content),
          );
          state = state.copyWith(isLoading: false, calls: []);
        }
      }, retries: 0);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      print("Conversation agent error $e");
    }
  }

  Insight _insight(ChatRole role, String body) => Insight.chat(
    role: role,
    body: body,
    created: DateTime.now(),
    queryEmbedding: null,
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
