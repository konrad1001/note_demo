import 'package:flutter/material.dart';

class MarkdownTextEditingController extends TextEditingController {
  MarkdownTextEditingController({super.text});

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<TextSpan> children = [];
    final lines = text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      children.addAll(_parseLineToSpans(line, style ?? const TextStyle()));

      if (i < lines.length - 1) {
        children.add(TextSpan(text: '\n', style: style));
      }
    }

    return TextSpan(style: style, children: children);
  }

  List<TextSpan> _parseLineToSpans(String line, TextStyle baseStyle) {
    final List<TextSpan> spans = [];

    final headerMatch = RegExp(r'^(#{1,3})(\s+)(.*)$').firstMatch(line);
    if (headerMatch != null) {
      final level = headerMatch.group(1)!.length;
      final headerText = headerMatch.group(3)!;
      final fontSize = baseStyle.fontSize ?? 16.0;

      spans.add(
        TextSpan(
          text: '${headerMatch.group(1)!} ',
          style: baseStyle.copyWith(color: Colors.grey, fontSize: fontSize - 3),
        ),
      );
      spans.add(
        TextSpan(
          text: headerText,
          style: baseStyle.copyWith(
            fontSize: fontSize + (5 - level) * 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      return spans;
    }

    final bulletMatch = RegExp(r'^(\s*)([-*+])\s+(.*)$').firstMatch(line);
    if (bulletMatch != null) {
      final indent = bulletMatch.group(1)!;
      final bulletType = bulletMatch.group(2)!;
      final content = bulletMatch.group(3)!;

      spans.add(TextSpan(text: indent, style: baseStyle));
      spans.add(
        TextSpan(
          text: '$bulletType ',
          style: baseStyle.copyWith(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      spans.addAll(_parseInlineMarkdown(content, baseStyle));
      return spans;
    }

    final numberedMatch = RegExp(r'^(\s*)(\d+)\.\s+(.*)$').firstMatch(line);
    if (numberedMatch != null) {
      final indent = numberedMatch.group(1)!;
      final number = numberedMatch.group(2)!;
      final content = numberedMatch.group(3)!;

      spans.add(TextSpan(text: indent, style: baseStyle));
      spans.add(
        TextSpan(
          text: '$number. ',
          style: baseStyle.copyWith(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      spans.addAll(_parseInlineMarkdown(content, baseStyle));
      return spans;
    }

    if (line.startsWith('> ')) {
      spans.add(
        TextSpan(
          text: '> ',
          style: baseStyle.copyWith(color: Colors.grey),
        ),
      );
      spans.addAll(
        _parseInlineMarkdown(
          line.substring(2),
          baseStyle.copyWith(
            fontStyle: FontStyle.italic,
            color: Colors.grey[700],
          ),
        ),
      );
      return spans;
    }

    spans.addAll(_parseInlineMarkdown(line, baseStyle));
    return spans;
  }

  List<TextSpan> _parseInlineMarkdown(String text, TextStyle baseStyle) {
    final List<TextSpan> spans = [];
    int lastIndex = 0;

    final boldRegex = RegExp(r'(\*\*|__)(.*?)\1');
    final italicRegex = RegExp(
      r'(?<!\*)\*(?!\*)([^*]+)\*(?!\*)|(?<!_)_(?!_)([^_]+)_(?!_)',
    );
    final codeRegex = RegExp(r'`([^`]+)`');
    final strikeRegex = RegExp(r'~~(.*?)~~');

    final patterns = <Pattern, TextStyle Function(TextStyle)>{
      boldRegex: (style) => style.copyWith(fontWeight: FontWeight.bold),
      italicRegex: (style) => style.copyWith(fontStyle: FontStyle.italic),
      codeRegex: (style) => style.copyWith(
        fontFamily: 'monospace',
        backgroundColor: Colors.grey[200],
        color: Colors.red[700],
      ),
      strikeRegex: (style) =>
          style.copyWith(decoration: TextDecoration.lineThrough),
    };

    final matches = <MapEntry<int, _MarkdownMatch>>[];

    for (final entry in patterns.entries) {
      final pattern = entry.key;
      final styleFunc = entry.value;

      for (final match in pattern.allMatches(text)) {
        matches.add(MapEntry(match.start, _MarkdownMatch(match, styleFunc)));
      }
    }

    matches.sort((a, b) => a.key.compareTo(b.key));

    for (final entry in matches) {
      final match = entry.value.match;

      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex, match.start),
            style: baseStyle,
          ),
        );
      }

      final fullText = match.group(0)!;
      final contentGroup = match.groupCount >= 2 && match.group(2) != null
          ? match.group(2)!
          : (match.group(1) ?? fullText);

      final beforeMarker = fullText.substring(
        0,
        fullText.indexOf(contentGroup),
      );
      final afterMarker = fullText.substring(
        fullText.indexOf(contentGroup) + contentGroup.length,
      );

      if (beforeMarker.isNotEmpty) {
        spans.add(
          TextSpan(
            text: beforeMarker,
            style: baseStyle.copyWith(color: Colors.grey),
          ),
        );
      }

      spans.add(
        TextSpan(text: contentGroup, style: entry.value.styleFunc(baseStyle)),
      );

      if (afterMarker.isNotEmpty) {
        spans.add(
          TextSpan(
            text: afterMarker,
            style: baseStyle.copyWith(color: Colors.grey),
          ),
        );
      }

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex), style: baseStyle));
    }

    return spans.isEmpty ? [TextSpan(text: text, style: baseStyle)] : spans;
  }
}

class _MarkdownMatch {
  final Match match;
  final TextStyle Function(TextStyle) styleFunc;

  _MarkdownMatch(this.match, this.styleFunc);
}

class MarkdownEditor extends StatefulWidget {
  final String? initialText;
  final ValueChanged<String>? onChanged;
  final TextStyle? style;
  final InputDecoration? decoration;
  final int? maxLines;
  final int? minLines;
  final Color? cursorColor;
  final MarkdownTextEditingController? controller;

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

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {
  late MarkdownTextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        MarkdownTextEditingController(text: widget.initialText ?? '');
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    widget.onChanged?.call(_controller.text);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(vertical: 12.0),
      child: TextField(
        controller: _controller,
        style: widget.style ?? const TextStyle(fontSize: 16),
        cursorColor: widget.cursorColor,
        decoration:
            widget.decoration ??
            const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter markdown text...',
            ),
        maxLines: widget.maxLines,
        minLines: widget.minLines ?? 10,
        keyboardType: TextInputType.multiline,
      ),
    );
  }
}
