import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:note_demo/app/theme.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/providers/insight_notifier.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:note_demo/screens/mindmap_screen.dart';
import 'package:note_demo/screens/resource_screen.dart';
import 'package:note_demo/util/navigator.dart';
import 'package:note_demo/widgets/blurred_container.dart';
import 'package:note_demo/widgets/mindmap_preview.dart';

class InsightWidget extends StatelessWidget {
  const InsightWidget({super.key, required this.insight});

  final Insight insight;

  @override
  Widget build(BuildContext context) {
    final colour = const Color.fromARGB(255, 255, 255, 255);
    final navigator = DefaultNavigator.of(context);

    return insight.maybeMap(
      summary: (summary) => _InsightContainer(
        colour: NTheme.primary,
        title: "I generated you a summary...",
        subtitle: summary.title,
        body: summary.body,
        date: summary.created,
        insight: insight,
      ),
      research: (research) => _InsightContainer(
        colour: NTheme.primary,
        title: "I found you a resource...",
        body: research.research,
        date: research.created,
        insight: insight,
      ),
      resource: (resource) => _ResourceInsight(
        resource: resource.resource,
        colour: resource.resource.colour,
        date: resource.created,
        insight: insight,
      ),
      mindmap: (mindmap) => _InsightContainer(
        colour: Colors.deepOrangeAccent,
        title: "I made you a mindmap...",
        subtitle: mindmap.title,
        body: "Tap to view",
        date: mindmap.created,
        insight: insight,
        widget: MindMapPreview(mindMap: mindmap.mindmap),
        onTap: () {
          navigator.push(MindmapScreen(mindmap: mindmap.mindmap));
        },
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _ResourceInsight extends StatelessWidget {
  final Insight insight;
  final StudyTools resource;
  final Color colour;
  final DateTime date;

  const _ResourceInsight({
    required this.resource,
    required this.colour,
    required this.date,
    required this.insight,
  });
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
        date: date,
        insight: insight,
      ),
    );
  }
}

class _InsightContainer extends ConsumerWidget {
  const _InsightContainer({
    required this.colour,
    this.title,
    this.subtitle,
    required this.body,
    required this.date,
    required this.insight,
    this.widget,
    this.onTap,
  });

  final Insight insight;
  final Color colour;

  final Widget? widget;

  final void Function()? onTap;

  final String? title;
  final String? subtitle;
  final String body;
  final DateTime date;

  String _formatDateTime(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');

    final hour = two(date.hour);
    final minute = two(date.minute);
    final day = two(date.day);
    final month = two(date.month);

    return "$hour:$minute $day/$month";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
                    Icon(Icons.auto_awesome, size: 14.0, color: colour),
                    Flexible(
                      child: Text(
                        title!,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              if (subtitle != null)
                Text(subtitle!, style: TextStyle(fontStyle: FontStyle.italic)),
              if (widget != null) widget!,

              MarkdownWidget(
                data: body,
                shrinkWrap: true,
                config: MarkdownConfig(
                  configs: [
                    PConfig(
                      textStyle: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (insight.rating != UserRating.dislike)
                    IconButton(
                      onPressed: () {
                        print(
                          ref.read(insightProvider.notifier).allUserRatings,
                        );

                        if (insight.rating == UserRating.like) {
                          ref
                              .read(insightProvider.notifier)
                              .updateRating(insight, UserRating.neither);
                        } else {
                          ref
                              .read(insightProvider.notifier)
                              .updateRating(insight, UserRating.like);
                        }
                      },
                      iconSize: 18,
                      color: (insight.rating == UserRating.like)
                          ? NTheme.primary
                          : Colors.black45,
                      icon: Icon(Icons.thumb_up),
                    ),
                  if (insight.rating != UserRating.like)
                    IconButton(
                      onPressed: () {
                        print(
                          ref.read(insightProvider.notifier).allUserRatings,
                        );

                        if (insight.rating == UserRating.dislike) {
                          ref
                              .read(insightProvider.notifier)
                              .updateRating(insight, UserRating.neither);
                        } else {
                          ref
                              .read(insightProvider.notifier)
                              .updateRating(insight, UserRating.dislike);
                        }
                      },
                      iconSize: 18,
                      color: (insight.rating == UserRating.dislike)
                          ? NTheme.primary
                          : Colors.black45,
                      icon: Icon(Icons.thumb_down),
                    ),
                  Spacer(),
                  Text(
                    _formatDateTime(date),
                    style: TextStyle(fontSize: 11.0, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
