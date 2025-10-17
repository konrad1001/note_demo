import 'package:flutter/material.dart';

class TextEditor extends StatelessWidget {
  const TextEditor({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(maxLines: 200, controller: controller),
    );
  }
}
