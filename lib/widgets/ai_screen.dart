import 'package:flutter/material.dart';

class AIScreen extends StatelessWidget {
  const AIScreen({
    super.key,
    required this.controller,
    required this.isLoading,
  });

  final TextEditingController controller;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          if (isLoading) Center(child: CircularProgressIndicator()),
          Opacity(
            opacity: isLoading ? 0.5 : 1.0,
            child: TextField(
              maxLines: 200,
              controller: controller,
              readOnly: true,
            ),
          ),
        ],
      ),
    );
  }
}
