import 'package:flutter/material.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/widgets/resources/flashcard_widget.dart';
import 'package:note_demo/widgets/resources/keyword_widget.dart';
import 'package:note_demo/widgets/resources/qa_widget.dart';

class ResourceScreen extends StatelessWidget {
  const ResourceScreen({super.key, required this.colour, required this.tool});

  final Color colour;
  final StudyTools tool;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: tool.map(
                flashcards: (flashcards) => [
                  FlashcardWidget(flashcards: flashcards.items),
                ],
                qas: (qas) => [
                  QuestionAnswerWidget(questionAnswers: qas.items),
                ],
                keywords: (keywords) => [
                  KeywordDefinitionsWidget(keywords: keywords.items),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
