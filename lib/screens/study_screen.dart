import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/providers/external_research_provider.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:note_demo/providers/study_content_provider.dart';
import 'package:note_demo/providers/study_tools_provider.dart';
import 'package:note_demo/widgets/study_tools_container.dart';
import 'package:markdown_widget/markdown_widget.dart';

class StudyScreen extends ConsumerWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studyContent = ref.watch(studyContentProvider);
    final studyTools = ref.watch(studyResourcesProvider);
    final externalResearch = ref.watch(externalResearchProvider);

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
          if (externalResearch.content != null)
            ExternalResearchWidget(externalResearch: externalResearch.content!),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: StudyToolsContainer(state: studyTools),
          ),
        ],
      ),
    );
  }
}

class ExternalResearchWidget extends StatelessWidget {
  const ExternalResearchWidget({super.key, required this.externalResearch});

  final String externalResearch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(65, 158, 158, 158),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                "Next Steps...",
                style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              ),
              MarkdownWidget(data: externalResearch, shrinkWrap: true),
            ],
          ),
        ),
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
