import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
          AsyncData(:final value) => Text(
            'Agent Response: ${value.firstCandidateText}',
          ),
          AsyncLoading() => const CircularProgressIndicator(),
          AsyncError(:final error) => Text('Error: $error'),
        },
      ],
    );
  }
}
