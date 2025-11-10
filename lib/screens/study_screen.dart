import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/providers/study_content_provider.dart';
import 'package:note_demo/models/study_design.dart';
import 'package:note_demo/providers/study_tools_provider.dart';

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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      Text(design.summary, style: TextStyle(fontSize: 16)),
                      Container(
                        height: 300,
                        child: SingleChildScrollView(
                          child: StudyPlanList(design: design),
                        ),
                      ),
                      StudyToolsContainer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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

class StudyToolsContainer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studyTools = ref.watch(studyToolsProvider);
    return Container(
      height: 200,
      color: const Color.fromARGB(101, 169, 185, 194),
      child: Column(
        children: [
          Text(studyTools.isLoading.toString()),
          Text(studyTools.tools.toString()),
        ],
      ),
    );
  }
}
