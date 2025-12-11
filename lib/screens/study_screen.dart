import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/providers/app_notifier.dart';
import 'package:note_demo/providers/agent_providers/research_agent_provider.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:note_demo/providers/note_content_provider.dart';
import 'package:note_demo/providers/agent_providers/summary_agent_provider.dart';
import 'package:note_demo/providers/agent_providers/resource_agent_provider.dart';
import 'package:note_demo/widgets/insights/insight_overlay.dart';
import 'package:markdown_widget/markdown_widget.dart';

class StudyScreen extends ConsumerWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteContent = ref.watch(noteContentProvider);
    final studyContent = ref.watch(summaryAgentProvider);
    final studyTools = ref.watch(resourceAgentProvider);
    final externalResearch = ref.watch(researchAgentProvider).content;

    final appNotifier = ref.watch(appNotifierProvider.notifier);

    final enhancedNotes = ref.watch(appNotifierProvider).enhancedNotes;

    if (noteContent.text == "") {
      return Center(
        child: DefaultTextStyle(
          style: TextStyle(color: Colors.black54),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(
              spacing: 12.0,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Nothing here yet..."),
                Text("Start writing to automatically generate AI insights."),
              ],
            ),
          ),
        ),
      );
    } else {
      return Stack(
        children: [
          SingleChildScrollView(
            child: Align(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 700),
                child: MarkdownWidget(
                  padding: const EdgeInsets.all(8.0),
                  shrinkWrap: true,
                  config: MarkdownConfig(
                    configs: [PConfig(textStyle: TextStyle(fontSize: 16))],
                  ),
                  data: noteContent.text,
                ),
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: InsightOverlay(
                externalResearch: externalResearch,
                studyTools: studyTools,
              ),
            ),
          ),
        ],
      );
    }
  }
}
