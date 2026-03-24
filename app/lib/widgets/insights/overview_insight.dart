import 'package:flutter/material.dart';
import 'package:note_demo/providers/insight_notifier.dart';

class OverviewInsight extends StatelessWidget {
  const OverviewInsight({
    super.key,
    required this.recommendedInsights,
    this.keyDate,
  });

  final Insights recommendedInsights;
  final DateTime? keyDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8.0,
        children: [],
      ),
    );
  }
}
