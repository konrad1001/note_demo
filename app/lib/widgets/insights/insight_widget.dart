import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:note_demo/agents/utils/agent_utils.dart';
import 'package:note_demo/app/theme.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/models/insights.dart';
import 'package:note_demo/providers/insight_notifier.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:note_demo/screens/mindmap_screen.dart';
import 'package:note_demo/screens/resource_screen.dart';
import 'package:note_demo/util/date_time.dart';
import 'package:note_demo/util/navigator.dart';
import 'package:note_demo/widgets/blurred_container.dart';
import 'package:note_demo/widgets/insights/overview_insight.dart';
import 'package:note_demo/widgets/insights/set_date_widget.dart';
import 'package:note_demo/widgets/mindmap_preview.dart';

part 'focus_event_widget.dart';
part 'error_insight_widget.dart';

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
        markdownBody: summary.body,
        date: summary.created,
        insight: insight,
      ),
      research: (research) => _InsightContainer(
        colour: Colors.lightGreen,
        title: "I found you a resource...",
        markdownBody: research.research,
        date: research.created,
        insight: insight,
      ),
      resource: (resource) => _InsightContainer(
        colour: resource.resource.colour,
        title: "I generated you a resource...",
        subtitle: resource.resource.title,
        body: "Tap to view",
        date: resource.created,
        insight: insight,
        onTap: () {
          navigator.push(ResourceScreen(tool: resource.resource));
        },
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
      chat: (chat) => _InsightContainer(
        colour: Colors.purple,
        markdownBody: "${chat.body}${chat.isStreaming ? " ***" : ""}",
        date: chat.created,
        insight: insight,
        role: chat.role,
        rateable: false,
      ),
      focusEvent: (event) => FocusEventWidget(
        key: UniqueKey(),
        insight: insight,
        event: FocusEvent(startTime: event.startTime, duration: event.duration),
      ),
      error: (error) => ErrorInsight(
        message: error.message,
        date: error.created,
        code: error.code,
      ),
      setDate: (date) => KeyDateWidget(created: date.created, insight: date),
      overview: (overview) => _InsightContainer(
        title: _overviewTitle(),
        markdownBody: _overviewBody(overview.title, overview.keyDate),
        widget: (overview.recommendedInsights.isNotEmpty)
            ? RecommendedInsightWrap(insights: overview.recommendedInsights)
            : null,
        rateable: false,
        colour: Colors.cyan,
        date: DateTime.now(),
        insight: insight,
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }

  String _overviewTitle() {
    final now = DateTime.now();
    if (now.hour < 12) {
      return "Good Morning";
    } else if (now.hour < 18) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  String _overviewBody(String? title, DateTime? keyDate) {
    return "Welcome back to your notes${(title == null) ? "" : " on $title"}. ${(keyDate != null) ? "You have ${keyDate.formatDaysFromNow()} days to go until your key date." : ""} Well done for checking in! \nWhat should we tackle today?";
  }
}

class _InsightContainer extends ConsumerWidget {
  const _InsightContainer({
    required this.colour,
    this.title,
    this.subtitle,
    this.markdownBody,
    required this.date,
    required this.insight,
    this.widget,
    this.onTap,
    this.role = ChatRole.agent,
    this.rateable = true,
    this.body,
  });

  final Insight insight;
  final Color colour;
  final ChatRole role;

  final Widget? widget;

  final void Function()? onTap;

  final String? title;
  final String? subtitle;
  final String? markdownBody;
  final String? body;
  final DateTime date;

  final bool rateable;

  Widget _stagedForDeletionCard(
    Insight insight,
    WidgetRef ref,
    BuildContext context,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: BoxBorder.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text("Staged for deletion.", style: TextStyle(fontSize: 13.0)),
          TextButton(
            onPressed: () {
              ref
                  .read(insightProvider.notifier)
                  .updateInsight(
                    insight,
                    newInsight: insight.copyWith(stagedForDeletion: false),
                  );
            },
            child: Opacity(
              opacity: 0.5,
              child: Text(
                "Undo?",
                style: TextStyle(
                  fontSize: 13.0,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUser = role == ChatRole.user;

    return Padding(
      padding: EdgeInsets.only(left: isUser ? 40 : 0),
      child: InkWell(
        onTap: insight.stagedForDeletion ? null : onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isUser ? Theme.of(context).cardColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: insight.stagedForDeletion
              ? _stagedForDeletionCard(insight, ref, context)
              : Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: isUser ? 8 : 4,
                  ),
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
                        Text(
                          subtitle!,
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      if (markdownBody != null)
                        DefaultTextStyle(
                          style: isUser
                              ? TextStyle()
                              : GoogleFonts.ptSerif(
                                  letterSpacing: 0.15,
                                  fontWeight: FontWeight.w200,
                                ),
                          child: MarkdownWidget(
                            data: markdownBody!,
                            shrinkWrap: true,
                            config: MarkdownConfig(
                              configs: [
                                PConfig(
                                  textStyle: TextStyle(
                                    fontSize: 14.0,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color
                                        ?.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (widget != null) widget!,

                      if (body != null)
                        Text(body!, style: TextStyle(fontSize: 12.0)),
                      if (insight.markForDeletion)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 6,
                            ),
                            child: Text.rich(
                              TextSpan(
                                style: TextStyle(fontSize: 12.0),
                                text:
                                    "I think this insight might be outdated.  ",
                                children: [
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: GestureDetector(
                                      child: Text(
                                        "Delete it?",
                                        style: TextStyle(
                                          fontSize: 12.0,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      onTap: () {
                                        ref
                                            .read(insightProvider.notifier)
                                            .updateInsight(
                                              insight,
                                              newInsight: insight.copyWith(
                                                stagedForDeletion: true,
                                              ),
                                            );
                                      },
                                    ),
                                  ),
                                  WidgetSpan(child: SizedBox(width: 8)),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: GestureDetector(
                                      child: Text(
                                        "Keep.",
                                        style: TextStyle(
                                          fontSize: 12.0,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      onTap: () {
                                        ref
                                            .read(insightProvider.notifier)
                                            .updateInsight(
                                              insight,
                                              newInsight: insight.copyWith(
                                                markForDeletion: false,
                                              ),
                                            );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      Row(
                        children: [
                          if (insight.rating != UserRating.dislike && rateable)
                            IconButton(
                              onPressed: () {
                                if (insight.rating == UserRating.like) {
                                  ref
                                      .read(insightProvider.notifier)
                                      .updateInsight(
                                        insight,
                                        newInsight: insight.copyWith(
                                          rating: UserRating.neither,
                                        ),
                                      );
                                } else {
                                  ref
                                      .read(insightProvider.notifier)
                                      .updateInsight(
                                        insight,
                                        newInsight: insight.copyWith(
                                          rating: UserRating.like,
                                        ),
                                      );
                                }
                              },
                              iconSize: 18,
                              color: (insight.rating == UserRating.like)
                                  ? NTheme.primary
                                  : Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                              icon: Icon(Icons.thumb_up),
                            ),
                          if (insight.rating != UserRating.like && rateable)
                            IconButton(
                              onPressed: () {
                                if (insight.rating == UserRating.dislike) {
                                  ref
                                      .read(insightProvider.notifier)
                                      .updateInsight(
                                        insight,
                                        newInsight: insight.copyWith(
                                          rating: UserRating.neither,
                                        ),
                                      );
                                } else {
                                  ref
                                      .read(insightProvider.notifier)
                                      .updateInsight(
                                        insight,
                                        newInsight: insight.copyWith(
                                          rating: UserRating.dislike,
                                        ),
                                      );
                                }
                              },
                              iconSize: 18,
                              color: (insight.rating == UserRating.dislike)
                                  ? NTheme.primary
                                  : Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                              icon: Icon(Icons.thumb_down),
                            ),
                          if (rateable)
                            IconButton(
                              onPressed: () {
                                ref
                                    .read(insightProvider.notifier)
                                    .updateInsight(
                                      insight,
                                      newInsight: insight.copyWith(
                                        stagedForDeletion: true,
                                      ),
                                    );
                              },
                              icon: Icon(Icons.delete_sharp, size: 18),
                            ),
                          Spacer(),
                          Text(
                            date.formatHmDM(),
                            style: TextStyle(
                              fontSize: 11.0,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color
                                  ?.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class RecommendedInsightWrap extends StatelessWidget {
  const RecommendedInsightWrap({super.key, required this.insights});

  final Insights insights;

  @override
  Widget build(BuildContext context) {
    final navigator = DefaultNavigator.of(context);

    final filter = insights.where(
      (i) => i.maybeMap(
        mindmap: (_) => true,
        resource: (_) => true,
        orElse: () => false,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(
          "Recommended study",
          style: TextStyle(
            fontSize: 12.0,
            color: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(155),
          ),
        ),
        Wrap(
          spacing: 3,
          children: [
            ...filter.map(
              (i) => InkWell(
                onTap: i.maybeMap(
                  mindmap: (mindmap) =>
                      () => navigator.push(
                        MindmapScreen(mindmap: mindmap.mindmap),
                      ),
                  resource: (resource) =>
                      () => navigator.push(
                        ResourceScreen(tool: resource.resource),
                      ),
                  orElse: () => null,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: BoxBorder.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.all(2),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 2,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 11.0,
                          color: Colors.deepOrangeAccent,
                        ),
                        Text(
                          i.maybeMap(
                            resource: (r) => r.resource.title,
                            mindmap: (m) => m.title,
                            research: (r) => i.name,
                            orElse: () => "orElse",
                          ),
                          style: TextStyle(fontSize: 11.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
