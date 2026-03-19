import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markdown_editor/markdown_editor.dart';
import 'package:note_demo/providers/agent_providers/principle_agent_provider.dart';
import 'package:note_demo/providers/app_notifier.dart';
import 'package:note_demo/providers/note_content_provider.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({
    super.key,
    required this.controller,
    required this.isInsightsExpanded,
  });

  final TextEditingController controller;
  final bool isInsightsExpanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteContent = ref.watch(noteContentProvider);

    return GestureDetector(
      child: Column(
        children: [
          Expanded(
            child: MarkdownEditor(
              cursorColor: Theme.of(
                context,
              ).textTheme.bodyLarge?.backgroundColor,
              style: TextStyle(fontSize: 14.5),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(0, 40, 0, 40),
                isDense: true,
                constraints: BoxConstraints(maxWidth: 700),
                border: InputBorder.none,
              ),
              controller: noteContent.editingController,
              onChanged: (value) {
                ref.read(principleAgentProvider.notifier).runPrinciple(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
