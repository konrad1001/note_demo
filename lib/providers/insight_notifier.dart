import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/providers/models/models.dart';

typedef Insights = List<Insight>;

class InsightNotifier extends Notifier<Insights> {
  @override
  List<Insight> build() {
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
