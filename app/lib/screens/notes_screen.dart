import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markdown_editor/markdown_editor.dart';
import 'package:note_demo/providers/agent_providers/principle_agent_provider.dart';
import 'package:note_demo/providers/app_notifier.dart';
import 'package:note_demo/providers/note_content_provider.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteContent = ref.watch(noteContentProvider);

    return Column(
      children: [
        Expanded(
          child: MarkdownEditor(
            cursorColor: Theme.of(context).textTheme.bodyLarge?.backgroundColor,
            style: TextStyle(fontSize: 14.5),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(50, 0, 50, 0),
              constraints: BoxConstraints(maxWidth: 700),
              isDense: true,
              border: InputBorder.none,
            ),
            controller: noteContent.editingController,
            onChanged: (value) {
              ref.read(principleAgentProvider.notifier).runPrinciple(value);
            },
          ),
        ),
      ],
    );
  }
}
