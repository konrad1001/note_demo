import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/providers/insight_notifier.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:note_demo/screens/resource_screen.dart';
import 'package:note_demo/widgets/blurred_container.dart';

class InsightOverlay extends ConsumerStatefulWidget {
  const InsightOverlay({
    super.key,
    required this.externalResearch,
    required this.studyTools,
  });

  final ResourceAgentState studyTools;
  final String? externalResearch;

  @override
  ConsumerState<InsightOverlay> createState() => _InsightOverlayState();
}

class _InsightOverlayState extends ConsumerState<InsightOverlay> {
  var isOpen = false;

  @override
  Widget build(BuildContext context) {
    final insights = ref.watch(insightProvider);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 500),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            if (isOpen)
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 78),
                  clipBehavior: Clip.none,
                  reverse: true,
                  child: Column(
                    spacing: 8.0,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: insights
                        .map((insight) => InsightWidget(insight: insight))
                        .toList(),
                  ),
                ),
              ),
            GestureDetector(
              onTap: () {
                setState(() {
                  isOpen = !isOpen;
                });
              },
              child: BlurredContainer(
                circular: true,
                child: isOpen ? Text("n") : Text("n"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InsightWidget extends StatelessWidget {
  const InsightWidget({super.key, required this.insight});

  final Insight insight;

  @override
  Widget build(BuildContext context) {
    return insight.maybeMap(
      summary: (summary) => BlurredContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("I generated you a summary..."),
            Text(summary.title),
            Text(summary.body),
          ],
        ),
      ),
      research: (research) => BlurredContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("I found you a resource..."),
            Text(research.research),
          ],
        ),
      ),
      resource: (resource) => _ResourceInsight(resource: resource.resource),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _ResourceInsight extends StatelessWidget {
  final StudyTools resource;

  const _ResourceInsight({required this.resource});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) =>
              ResourceScreen(colour: resource.colour, tool: resource),
        ),
      ),
      child: BlurredContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("I generated you a resource..."),
            Text(resource.title),
            Text("Tap to view", style: TextStyle(color: Colors.black38)),
          ],
        ),
      ),
    );
  }
}
