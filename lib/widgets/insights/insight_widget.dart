import 'package:flutter/material.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:note_demo/screens/resource_screen.dart';
import 'package:note_demo/widgets/blurred_container.dart';

class InsightWidget extends StatelessWidget {
  const InsightWidget({super.key, required this.insight});

  final Insight insight;

  @override
  Widget build(BuildContext context) {
    final colour = const Color.fromARGB(255, 255, 255, 255);

    return insight.maybeMap(
      summary: (summary) => _InsightContainer(
        colour: colour,
        title: "I generated you a summary...",
        subtitle: summary.title,
        body: summary.body,
        date: summary.created,
      ),
      research: (research) => _InsightContainer(
        colour: colour,
        title: "I found you a resource...",
        body: research.research,
        date: research.created,
      ),
      resource: (resource) =>
          _ResourceInsight(resource: resource.resource, colour: colour),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _ResourceInsight extends StatelessWidget {
  final StudyTools resource;
  final Color colour;

  const _ResourceInsight({required this.resource, required this.colour});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) =>
              ResourceScreen(colour: resource.colour, tool: resource),
        ),
      ),
      child: _InsightContainer(
        colour: colour,
        title: "I generated you a resource...",
        subtitle: resource.title,
        body: "Tap to view",
      ),
    );
  }
}

class _InsightContainer extends StatelessWidget {
  const _InsightContainer({
    required this.colour,
    this.title,
    this.subtitle,
    required this.body,
    this.date,
  });

  final Color colour;

  final String? title;
  final String? subtitle;
  final String body;
  final DateTime? date;

  String _formatDateTime(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');

    final hour = two(date.hour);
    final minute = two(date.minute);
    final day = two(date.day);
    final month = two(date.month);

    return "$hour:$minute $day/$month";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colour,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4.0,
          children: [
            if (title != null)
              Row(
                spacing: 12.0,
                children: [
                  Icon(Icons.auto_awesome, size: 14.0, color: Colors.black54),
                  Text(title!, style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            if (subtitle != null)
              Text(subtitle!, style: TextStyle(fontStyle: FontStyle.italic)),
            Text(body, style: TextStyle(color: Colors.black87)),

            Row(
              children: [
                Spacer(),
                Text(
                  _formatDateTime(date ?? DateTime.now()),
                  style: TextStyle(fontSize: 11.0, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
