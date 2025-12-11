import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/providers/note_content_provider.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteContent = ref.watch(noteContentProvider);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        maxLines: 50,
        controller: noteContent.editingController,
        scrollPadding: EdgeInsets.only(bottom: 32),
      ),
    );
  }
}
