import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/providers/external_research_provider.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:note_demo/providers/principle_agent_provider.dart';
import 'package:note_demo/providers/study_content_provider.dart';
import 'package:note_demo/providers/study_tools_provider.dart';

class AgentStatusBar extends ConsumerWidget {
  const AgentStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final principe = ref.watch(principleAgentProvider);
    final content = ref.watch(studyContentProvider);
    final tools = ref.watch(studyResourcesProvider);
    final research = ref.watch(externalResearchProvider);

    return Row(
      spacing: 16,
      children: [
        _agentIcon("Principle", principe.isLoading),
        _agentIcon(
          "Content",
          content.maybeWhen(
            loading: () => true,
            idle: (_, isLoading) => isLoading,
            orElse: () => false,
          ),
        ),
        _agentIcon("Tools", tools.isLoading),
        _pipeIcon("Research", research.pipeLevel),
      ],
    );
  }

  Widget _pipeIcon(String name, int runningIndex) {
    final isLoading = runningIndex > 0;
    return Opacity(
      opacity: isLoading ? 0.5 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(146, 33, 149, 243),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            spacing: 8,
            children: [
              Text(name, style: TextStyle(fontSize: 12)),
              Text(
                isLoading ? "Loading" : "Ready",
                style: TextStyle(
                  fontSize: 12,
                  color: const Color.fromARGB(137, 0, 0, 0),
                ),
              ),
              ...[1, 2, 3].map((i) => _statusCircle(i == runningIndex)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusCircle(bool isLoading, {double size = 8.0}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isLoading ? Colors.red : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _agentIcon(String name, bool isLoading) {
    return Opacity(
      opacity: isLoading ? 0.5 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(146, 33, 149, 243),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            spacing: 8,
            children: [
              Text(name, style: TextStyle(fontSize: 12)),
              Text(
                isLoading ? "Loading" : "Ready",
                style: TextStyle(
                  fontSize: 12,
                  color: const Color.fromARGB(137, 0, 0, 0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
