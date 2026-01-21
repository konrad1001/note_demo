import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/mock/mocks.dart';
import 'package:note_demo/providers/app_event_provider.dart';
import 'package:note_demo/providers/mock_service_provider.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:note_demo/widgets/insights/insight_panel.dart';

typedef Insights = List<Insight>;

class InsightNotifier extends Notifier<Insights> {
  @override
  List<Insight> build() {
    final isMock = ref.watch(mockServiceProvider);
    if (isMock) return MockBuilder.mockInsights;

    return [];
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

  void updateRating(Insight insight, UserRating newRating) {
    Insights newState = [];
    for (var i in state) {
      if (i == insight) {
        i = i.copyWith(rating: newRating);
      }
      newState.add(i);
    }
    state = newState;
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
}

final insightProvider = NotifierProvider<InsightNotifier, Insights>(
  () => InsightNotifier(),
);
