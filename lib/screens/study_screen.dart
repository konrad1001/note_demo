import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/providers/study_content_provider.dart';
import 'package:note_demo/models/study_design.dart';

class StudyScreen extends ConsumerWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studyContent = ref.watch(studyContentProvider);

    return studyContent.when(
      empty: () => Center(child: Text('No study design available.')),
      loading: () => Center(child: CircularProgressIndicator()),
      idle: (design, isLoading) =>
          Dashboard(design: design, isLoading: isLoading),
    );
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key, required this.design, required this.isLoading});

  final StudyDesign design;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Opacity(
              opacity: isLoading ? 0.5 : 1.0,
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
