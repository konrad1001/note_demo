import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/app/theme.dart';
import 'package:note_demo/providers/agent_providers/observer_agent_provider.dart';
import 'package:note_demo/providers/agent_providers/principle_agent_provider.dart';
import 'package:note_demo/providers/agent_providers/research_agent_provider.dart';
import 'package:note_demo/providers/agent_providers/resource_agent_provider.dart';
import 'package:note_demo/providers/agent_providers/summary_agent_provider.dart';
import 'package:note_demo/providers/insight_notifier.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:note_demo/widgets/insights/insight_widget.dart';

class InsightPanel extends ConsumerWidget {
  const InsightPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(insightProvider);

    return Container(
      decoration: BoxDecoration(color: Color.fromARGB(255, 245, 244, 240)),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width / 3,

      child: Stack(
        alignment: AlignmentGeometry.bottomCenter,
        children: [
          insights.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DefaultTextStyle(
                      style: TextStyle(color: Colors.black54),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 12.0,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Nothing here yet...",
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "Start writing to automatically generate AI insights.",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  reverse: true,
                  padding: EdgeInsets.fromLTRB(12, 12, 12, 64),
                  children: [
                    ...(insights.reversed).map(
                      (insight) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InsightWidget(insight: insight),
                      ),
                    ),
                  ],
                ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 12.0,
            ),
            child: _AgentFeedback(),
          ),
        ],
      ),
    );
  }
}

class _AgentFeedback extends ConsumerWidget {
  const _AgentFeedback();

  Widget _decideState(
    PrincipleAgentState pState,
    SummaryAgentState sState,
    ResearchAgentState rState,
    ResourceAgentState srcState,
  ) {
    String text = "Idle";

    if (pState.isLoading) {
      text = "Reading...";
    } else if (sState is SummaryAgentStateLoading) {
      text = "Summarising...";
    } else if (rState.isLoading) {
      text = "Researching...";
    } else if (srcState.isLoading) {
      text = "Resourcing...";
    }

    return Flexible(
      child: Text(
        text,
        style: TextStyle(
          color: text == "Idle" ? Colors.black : NTheme.greyed,
          fontSize: 14.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final principe = ref.watch(principleAgentProvider);
    final content = ref.watch(summaryAgentProvider);
    final tools = ref.watch(resourceAgentProvider);
    final research = ref.watch(researchAgentProvider);
    final overview = ref.watch(observerAgentProvider);

    const iconSize = 28.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            spreadRadius: 0.3,
            blurRadius: 4.0,
            offset: Offset(-1, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          spacing: 12.0,
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: NTheme.primary.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.abc),
            ),
            _decideState(principe, content, research, tools),
          ],
        ),
      ),
    );
  }
}
