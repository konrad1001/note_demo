import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/agents/utils/agent_utils.dart';
import 'package:note_demo/mock/mocks.dart';
import 'package:note_demo/providers/mock_service_provider.dart';
import 'package:note_demo/providers/models/models.dart';

typedef Insights = List<Insight>;

class InsightNotifier extends Notifier<Insights> {
  @override
  List<Insight> build() {
    final isMock = ref.watch(mockServiceProvider);
    if (isMock) return MockBuilder.mockInsights;

    return [createChatIntro()];
  }

  void set(Insights insights) {
    state = insights;
  }

  void append({required Insight insight}) {
    state = state + [insight];
  }

  void clear() {
    state = [];
  }

  void deleteInsight(Insight insight) {
    state = state
        .map((i) {
          if (i == insight) {
            return null;
          } else {
            return i;
          }
        })
        .nonNulls
        .toList();
  }

  void updateLatest({required Insight insight}) {
    state.removeLast();
    state = state + [insight];
  }

  void updateInsight(Insight insight, {required Insight newInsight}) {
    state = state.map((i) {
      if (i == insight) {
        return newInsight;
      } else {
        return i;
      }
    }).toList();
  }

  Map<String, int> get allUserRatings {
    Map<String, int> ratings = {};
    for (final i in state) {
      ratings.update(
        i.name,
        (value) => value + i.rating.toValue,
        ifAbsent: () => i.rating.toValue,
      );
    }
    return ratings;
  }

  Insights getChatHistory() {
    return state.where((i) => i.name == "Chat").toList();
  }
}

final insightProvider = NotifierProvider<InsightNotifier, Insights>(
  () => InsightNotifier(),
);
