import 'package:note_demo/models/gemini_response.dart';

abstract class MockBuilder {
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
