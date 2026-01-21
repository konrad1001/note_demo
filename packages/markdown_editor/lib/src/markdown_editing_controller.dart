import 'package:flutter/material.dart';
import 'package:markdown_editor/src/markdown_patterns.dart';
import 'package:markdown_editor/src/markdown_spans.dart';

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
      final prevLine = (i > 0) ? lines[i - 1] : "";
      children.addAll(
        _parseLineToSpans(line, prevLine, style ?? const TextStyle()),
      );

      if (i < lines.length - 1) {
        children.add(TextSpan(text: '\n', style: style));
      }
    }

    return TextSpan(style: style, children: children);
  }

  List<TextSpan> _parseLineToSpans(
    String line,
    String prevLine,
    TextStyle baseStyle,
  ) {
    final List<TextSpan> spans = [];

    final headerMatch = RegExp(r'^(#{1,3})(\s+)(.*)$').firstMatch(line);
    if (headerMatch != null) {
      final level = headerMatch.group(1)!.length;
      final headerText = "${headerMatch.group(2)!}${headerMatch.group(3)!}";

      spans.add(MarkdownSpan.mark(headerMatch.group(1)!, baseStyle));
      spans.add(MarkdownSpan.header(headerText, level, baseStyle));
      return spans;
    }

    final bulletMatch = RegExp(r'^(\s*)([-*+])(\s+)(.*)$').firstMatch(line);
    if (bulletMatch != null) {
      final indent = bulletMatch.group(1)!;
      final bulletType = bulletMatch.group(2)!;
      final content = "${bulletMatch.group(3)!}${bulletMatch.group(4)!}";

      spans.add(TextSpan(text: indent, style: baseStyle));
      spans.add(MarkdownSpan.bullet(bulletType, baseStyle));
      spans.addAll(_parseInlineMarkdown(content, baseStyle));

      return spans;
    }

    final numberedMatch = RegExp(r'^(\s*)(\d+)\.\s+(.*)$').firstMatch(line);
    if (numberedMatch != null) {
      final indent = numberedMatch.group(1)!;
      final number = numberedMatch.group(2)!;
      final content = numberedMatch.group(3)!;

      spans.add(TextSpan(text: indent, style: baseStyle));
      spans.add(MarkdownSpan.bullet("$number ", baseStyle));
      spans.addAll(_parseInlineMarkdown(content, baseStyle));
      return spans;
    }

    if (line.startsWith('> ')) {
      spans.add(MarkdownSpan.mark('> ', baseStyle));
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

    final patterns = MarkdownPatterns.patterns;
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
        spans.add(MarkdownSpan.mark(beforeMarker, baseStyle));
      }

      spans.add(
        TextSpan(text: contentGroup, style: entry.value.styleFunc(baseStyle)),
      );

      if (afterMarker.isNotEmpty) {
        spans.add(MarkdownSpan.mark(afterMarker, baseStyle));
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
