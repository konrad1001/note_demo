import 'package:flutter/material.dart';
import 'package:note_demo/models/agent_responses/models.dart';

class ResourceScreen extends StatelessWidget {
  const ResourceScreen({super.key, required this.colour, required this.tool});

  final Color colour;
  final StudyTools tool;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: colour,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.chevron_left),
        ),
      ),
      body: _ResourceWidget(tool: tool),
    );
  }
}

class _ResourceWidget extends StatelessWidget {
  const _ResourceWidget({required this.tool});

  final StudyTools tool;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: SingleChildScrollView(
        child: Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tool.title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: tool.map(
                flashcards: (flashcards) => [
                  ...flashcards.items.map(
                    (item) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(item.front),
                        Text(
                          item.back,
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ],
                qas: (qas) => [
                  ...qas.items.map(
                    (item) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(item.question),
                        Text(
                          item.answer,
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ],
                keywords: (keywords) => [
                  ...keywords.items.map(
                    (item) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(item.keyword),
                        Text(
                          item.definition,
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
