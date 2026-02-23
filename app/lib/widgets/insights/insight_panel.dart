import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/providers/agent_providers/conversation_agent_provider.dart';
import 'package:note_demo/providers/agent_providers/mindmap_agent_provider.dart';
import 'package:note_demo/providers/agent_providers/principle_agent_provider.dart';
import 'package:note_demo/providers/agent_providers/research_agent_provider.dart';
import 'package:note_demo/providers/agent_providers/resource_agent_provider.dart';
import 'package:note_demo/providers/agent_providers/summary_agent_provider.dart';
import 'package:note_demo/providers/focus_event_provider.dart';
import 'package:note_demo/providers/insight_notifier.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:note_demo/widgets/insights/insight_widget.dart';

final _insightPanelKey = GlobalKey<AnimatedListState>();

class InsightPanel extends ConsumerStatefulWidget {
  const InsightPanel({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _InsightPanelState();
}

class _InsightPanelState extends ConsumerState<InsightPanel> {
  double _interfacePadding = 53;

  @override
  Widget build(BuildContext context) {
    ref.listen<Insights>(insightProvider, (prev, next) {
      if (prev?.length != next.length) {
        _insightPanelKey.currentState?.insertItem(next.length - 1);
      }
    });

    final insights = ref.watch(insightProvider);

    final isMobile = (Platform.isAndroid || Platform.isIOS);

    return GestureDetector(
      onTap: () {
        // FocusScope.of(context).unfocus();
      },
      child: Container(
        decoration: BoxDecoration(color: Theme.of(context).canvasColor),
        child: Stack(
          alignment: AlignmentGeometry.bottomCenter,
          children: [
            ListView(
              physics: AlwaysScrollableScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

              reverse: true,
              padding: EdgeInsets.fromLTRB(
                12,
                12,
                12,
                _interfacePadding + (isMobile ? 32 : 20) + 60,
              ),
              children: [
                ...(insights.reversed).map(
                  (insight) => Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: InsightWidget(insight: insight),
                  ),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Theme.of(context).cardColor.withValues(alpha: 0.2),
                    Theme.of(
                      context,
                    ).scaffoldBackgroundColor.withValues(alpha: 1.0),
                  ],
                  stops: const [0.0, 0.3, 1.0],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(12, 16, 12, isMobile ? 32 : 20),
                child: _AgentInterface(
                  onSubmit: (text) {
                    ref.read(conversationAgentProvider.notifier).chat(text);
                  },
                  onHeightChanged: (newHeight) {
                    setState(() {
                      _interfacePadding = newHeight;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgentInterface extends ConsumerStatefulWidget {
  const _AgentInterface({this.onSubmit, this.onHeightChanged});

  final Function(double newHeight)? onHeightChanged;
  final Function(String text)? onSubmit;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AgentInterfaceState();
}

class _AgentInterfaceState extends ConsumerState<_AgentInterface> {
  final GlobalKey _textFieldKey = GlobalKey();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reportHeight();
    });
  }

  void _reportHeight() {
    final RenderBox? renderBox =
        _textFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      widget.onHeightChanged?.call(renderBox.size.height);
    }
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSubmit?.call(text);
      _controller.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _reportHeight();
      });
    }
  }

  Widget _decideState(
    PrincipleAgentState pState,
    ConversationAgentState cState,
    SummaryAgentState sState,
    ResearchAgentState rState,
    ResourceAgentState srcState,
    MindmapAgentState mapState, {
    required BuildContext context,
  }) {
    String? text;

    if (cState.isLoading) {
      text = "Thinking";
    } else if (pState.isLoading) {
      text = "Reading...";
    } else if (sState.isLoading) {
      text = "Summarising...";
    } else if (srcState.isLoading) {
      text = "Resourcing...";
    } else if (mapState.isLoading) {
      text = "Mapping...";
    }

    if (text == null) {
      return Expanded(
        child: TextField(
          maxLines: 3,
          minLines: 1,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.send,
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Chat...',
            hintStyle: TextStyle(
              color: Theme.of(
                context,
              ).textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
            ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          ),
          style: TextStyle(fontSize: 14.0),
          onSubmitted: (_) => _handleSubmit(),
          onChanged: (_) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _reportHeight();
            });
          },
        ),
      );
    }

    return Expanded(
      child: Text(
        text,
        style: TextStyle(
          color: text == "Idle"
              ? Theme.of(context).textTheme.bodyMedium?.color
              : Theme.of(
                  context,
                ).textTheme.bodyLarge?.color?.withValues(alpha: 0.5),
          fontSize: 14.0,
        ),
      ),
    );
  }

  Widget _ToolButton(VoidCallback onTap, {bool active = true}) {
    return InkWell(
      onTap: active ? onTap : null,
      child: Opacity(
        opacity: active ? 1.0 : 0.5,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32.0),
            color: Theme.of(context).scaffoldBackgroundColor,
            border: BoxBorder.all(
              color: const Color.fromARGB(56, 255, 255, 255),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                spreadRadius: 0.3,
                blurRadius: 4.0,
                offset: Offset(-1, 2),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.timelapse,
                size: 14,
                color: Theme.of(
                  context,
                ).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              Text(
                "Start Focus Timer",
                style: TextStyle(
                  fontSize: 11.0,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final principle = ref.watch(principleAgentProvider);
    final conversation = ref.watch(conversationAgentProvider);
    final summary = ref.watch(summaryAgentProvider);
    final resources = ref.watch(resourceAgentProvider);
    final research = ref.watch(researchAgentProvider);
    final mindmap = ref.watch(mindmapAgentProvider);
    final events = ref.watch(focusEventProvider);

    final anyLoading = [
      principle,
      research,
      summary,
      conversation,
      resources,
      mindmap,
    ].any((p) => p.isLoading);

    return Column(
      spacing: 8.0,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          key: _textFieldKey,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32.0),
            color: Theme.of(context).scaffoldBackgroundColor,
            border: BoxBorder.all(
              color: const Color.fromARGB(56, 255, 255, 255),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                spreadRadius: 0.3,
                blurRadius: 4.0,
                offset: Offset(-1, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(12.0),
          child: Row(
            spacing: 12.0,
            children: [
              _decideState(
                principle,
                conversation,
                summary,
                research,
                resources,
                mindmap,
                context: context,
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: anyLoading ? null : _handleSubmit,
                icon: const Icon(Icons.send, size: 22),
                color: anyLoading ? Colors.blueGrey : Colors.blue,

                padding: EdgeInsets.all(2),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 30,
          child: ListView(
            clipBehavior: Clip.none,
            scrollDirection: Axis.horizontal,
            physics: AlwaysScrollableScrollPhysics(),
            children: [
              _ToolButton(() {
                ref
                    .read(focusEventProvider.notifier)
                    .setEvent(
                      FocusEvent(
                        startTime: DateTime.now(),
                        duration: Duration(minutes: 0, seconds: 10),
                      ),
                    );
              }, active: events == null),
              SizedBox(width: 8),
              // _ToolButton(),
              SizedBox(width: 8),
              // _ToolButton(),
            ],
          ),
        ),
      ],
    );
  }
}
