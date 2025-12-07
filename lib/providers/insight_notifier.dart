import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/mock/mocks.dart';
import 'package:note_demo/providers/mock_service_provider.dart';
import 'package:note_demo/providers/models/models.dart';

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
    print("set state to $state");
  }

  void append({required Insight insight}) {
    state.add(insight);
  }

  void clear() {
    state = [];
  }
}

final insightProvider = NotifierProvider<InsightNotifier, Insights>(
  () => InsightNotifier(),
);
