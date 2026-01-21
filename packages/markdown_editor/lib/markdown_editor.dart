import 'package:flutter/material.dart';
import 'package:markdown_editor/src/markdown_editing_controller.dart';

export 'src/markdown_editing_controller.dart';

class MarkdownEditor extends StatelessWidget {
  const MarkdownEditor({
    super.key,
    this.initialText,
    this.onChanged,
    this.style,
    this.decoration,
    this.maxLines,
    this.minLines,
    this.cursorColor,
    this.controller,
  });

  final String? initialText;
  final ValueChanged<String>? onChanged;
  final TextStyle? style;
  final InputDecoration? decoration;
  final int? maxLines;
  final int? minLines;
  final Color? cursorColor;
  final MarkdownTextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(vertical: 12.0),
      child: TextField(
        controller: controller,
        style: style ?? const TextStyle(fontSize: 16),
        cursorColor: cursorColor,
        decoration:
            decoration ??
            const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter markdown text...',
            ),
        maxLines: maxLines,
        minLines: minLines ?? 10,
        keyboardType: TextInputType.multiline,
        onChanged: onChanged,
      ),
    );
  }
}
