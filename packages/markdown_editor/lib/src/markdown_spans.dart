import 'package:flutter/material.dart';

abstract class MarkdownSpan {
  static double _fontSize(TextStyle baseStyle) => baseStyle.fontSize ?? 16.0;

  static TextSpan mark(String text, TextStyle baseStyle) => TextSpan(
    text: text,
    style: baseStyle.copyWith(
      color: Colors.grey,
      fontSize: _fontSize(baseStyle) - 3,
    ),
  );

  static TextSpan header(String text, int level, TextStyle baseStyle) =>
      TextSpan(
        text: text,
        style: baseStyle.copyWith(
          fontSize: _fontSize(baseStyle) + (5 - level) * 2,
          fontWeight: FontWeight.bold,
        ),
      );

  static TextSpan bullet(String type, TextStyle baseStyle) => TextSpan(
    children: [
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            type,
            style: baseStyle.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ],
  );
}
