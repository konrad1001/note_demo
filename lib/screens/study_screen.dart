import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/providers/agent_provider.dart';
import 'package:note_demo/models/gemini_response.dart';
import 'package:note_demo/models/study_design.dart';

class StudyScreen extends ConsumerWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final response = ref.watch(agentProvider);

    return ListView(
      children: [
        switch (response) {
          AsyncData(:final value) => Dashboard(design: value.getStudyDesign()),
          AsyncLoading() => Center(child: const CircularProgressIndicator()),
          AsyncError(:final error) => Text('Error: $error'),
        },
      ],
    );
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key, required this.design});

  final StudyDesign design;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Text(
              design.title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            Text(design.summary, style: TextStyle(fontSize: 16)),
            StudyPlanList(design: design),
          ],
        ),
      ),
    );
  }
}

class StudyPlanList extends StatelessWidget {
  final StudyDesign design;

  const StudyPlanList({super.key, required this.design});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...design.studyPlan.map(
            (e) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(value: false, onChanged: (_) {}),
                Flexible(child: Text(e)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
