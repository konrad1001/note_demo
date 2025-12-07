import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/models/gemini_response.dart';
import 'package:note_demo/providers/insight_notifier.dart';
import 'package:note_demo/providers/models/models.dart';

abstract class MockBuilder {
  static Insights get mockInsights => [
    Insight.summary(
      title:
          "Introduction to Natural Language Processing and Preprocessing Techniques",
      body:
          """This study plan covers the fundamentals of NLP, including data representation, 
          text preprocessing methods like tokenization and normalization, and an introduction
           to word meaning and deep learning concepts like RNNs for sequential data.""",
    ),
    Insight.resource(
      resource: StudyTools.flashcards(
        id: "id",
        title: "Mock flashcards",
        items: [
          FlashcardItem(front: "Front 1", back: "Back 1"),
          FlashcardItem(front: "Front 2", back: "Back 2"),
          FlashcardItem(front: "Front 3", back: "Back 3"),
        ],
      ),
    ),
    Insight.research(
      research:
          "Heres an interesting video that will summarise this concept...",
    ),
    Insight.resource(
      resource: StudyTools.qas(
        id: "id",
        title: "Mock flashcards",
        items: [
          QuestionAnswerItem(question: "Question 1", answer: "Answer 1"),
          QuestionAnswerItem(question: "Question 2", answer: "Answer 2"),
          QuestionAnswerItem(question: "Question 3", answer: "Answer 3"),
        ],
      ),
    ),
  ];

  static GeminiResponse get geminiResponse => GeminiResponse(
    candidates: [
      Candidate(
        content: Content(
          parts: [
            Part(
              text: '''```json
{
  "title": "Data Structures - Trees and Graphs",
  "summary": "This content introduces fundamental data structures: trees and graphs, covering types, properties, and common traversal algorithms for efficient data handling.",
  "study_plan": [
    "Understand Tree Data Structure: Definition, Terminologies (root, node, child, parent, leaf, depth, height), Types (Binary Tree, Binary Search Tree - BST, AVL, Red-Black) Types (Binary Tree, Binary Search Tree - BST, AVL, Red-Black).",
    "Learn about Binary Trees: Properties and basic operations.",
    "Study Binary Search Trees (BST): Properties, advantages (fast search, insertion, deletion), and operations (search, insert, delete).",
    "Explore Graph Data Structure: Definition, Terminologies (vertex, edge, degree, path, cycle), Types (Directed, Undirected, Weighted, Unweighted).",
    "Understand Graph Representations: Adjacency Matrix and Adjacency List, including their pros and cons.",
    "Learn Graph Traversal Algorithms: Breadth-First Search (BFS) and Depth-First Search (DFS)."
  ]
}
```''',
            ),
          ],
          role: 'model',
        ),
        finishReason: 'STOP',
        index: 0,
      ),
    ],
    usageMetadata: UsageMetadata(
      promptTokenCount: 202,
      candidatesTokenCount: 239,
      totalTokenCount: 441,
    ),
    modelVersion: 'gemini-2.5-flash',
    responseId: 'bdgAafrwKMu9kdUPiZX5wAQ',
  );
}
