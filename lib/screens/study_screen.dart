import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/providers/models.dart';
import 'package:note_demo/providers/study_content_provider.dart';
import 'package:note_demo/providers/study_tools_provider.dart';
import 'package:note_demo/widgets/study_tools_container.dart';

class StudyScreen extends ConsumerWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studyContent = ref.watch(studyContentProvider);
    final studyTools = ref.watch(studyResourcesProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          studyContent.when(
            empty: () => Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text('...'),
              ),
            ),
            loading: () => Center(child: CircularProgressIndicator()),
            idle: (design, isLoading) =>
                Dashboard(design: design, isLoading: isLoading),
            error: (error) => Center(child: Text(error.toString())),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: StudyToolsContainer(state: studyTools),
          ),
        ],
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key, required this.design, required this.isLoading});

  final StudyDesign design;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                Text(design.summary, style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
