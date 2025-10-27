import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markdown_widget/widget/markdown.dart';
import 'package:note_demo/app/agent_provider.dart';
import 'package:note_demo/app/app_notifier.dart';

class StudyScreen extends ConsumerWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteText = ref.watch(appNotifierProvider);
    final response = ref.watch(agentProvider);

    return ListView(
      children: [
        switch (response) {
          AsyncData(:final value) => SizedBox(
            height: 500,
            child: MarkdownWidget(data: value.firstCandidateText),
          ),
          AsyncLoading() => Center(child: const CircularProgressIndicator()),
          AsyncError(:final error) => Text('Error: $error'),
        },
      ],
    );
  }
}
