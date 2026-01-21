import 'package:flutter/material.dart';
import 'package:note_demo/models/agent_responses/models.dart';

class MindmapScreen extends StatelessWidget {
  const MindmapScreen({super.key, required this.mindmap});

  final MindMap mindmap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.chevron_left),
        ),
      ),
      body: GridPaper(),
    );
  }
}
