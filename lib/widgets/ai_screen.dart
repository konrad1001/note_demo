import 'package:flutter/material.dart';

class AIScreen extends StatelessWidget {
  const AIScreen({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(maxLines: 200, controller: controller, readOnly: true),
    );
  }
}
