import 'package:flutter/material.dart';

abstract class MarkdownPatterns {
  static final _boldRegex = RegExp(r'(\*\*|__)(.*?)\1');
  static final _italicRegex = RegExp(
    r'(?<!\*)\*(?!\*)([^*]+)\*(?!\*)|(?<!_)_(?!_)([^_]+)_(?!_)',
  );
  static final _codeRegex = RegExp(r'`([^`]+)`');
  static final _strikeRegex = RegExp(r'~~(.*?)~~');

  static Map<Pattern, TextStyle Function(TextStyle)> get patterns => {
    _boldRegex: (style) => style.copyWith(fontWeight: FontWeight.bold),
    _italicRegex: (style) => style.copyWith(fontStyle: FontStyle.italic),
    _codeRegex: (style) => style.copyWith(
      fontFamily: 'monospace',
      color: Colors.deepOrangeAccent,
      letterSpacing: 1.5,
    ),
    _strikeRegex: (style) =>
        style.copyWith(decoration: TextDecoration.lineThrough),
  };
}
