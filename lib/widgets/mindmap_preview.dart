import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:note_demo/models/agent_responses/models.dart';

class MindMapPreview extends StatelessWidget {
  final MindMapResponse mindMap;
  final double width;
  final double height;

  const MindMapPreview({
    super.key,
    required this.mindMap,
    this.width = 200,
    this.height = 150,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(8),
        child: CustomPaint(painter: MindMapPreviewPainter(mindMap: mindMap)),
      ),
    );
  }
}

class MindMapPreviewPainter extends CustomPainter {
  final MindMapResponse mindMap;

  MindMapPreviewPainter({required this.mindMap});

  @override
  void paint(Canvas canvas, Size size) {
    final positions = _calculateNodePositions(size);
    _drawConnections(canvas, positions);
    _drawNodes(canvas, positions);
  }

  Map<String, Offset> _calculateNodePositions(Size size) {
    final positions = <String, Offset>{};
    final rootNode = mindMap.nodes.firstWhere(
      (node) => node.parentId == null,
      orElse: () => mindMap.nodes.first,
    );

    final treeLevels = _buildTreeLevels(rootNode.id);
    final levelWidth = size.width / (treeLevels.length + 1);

    for (int level = 0; level < treeLevels.length; level++) {
      final nodesAtLevel = treeLevels[level];
      final x = (level + 1) * levelWidth;

      final verticalSpacing = size.height / (nodesAtLevel.length + 1);

      for (int i = 0; i < nodesAtLevel.length; i++) {
        final y = (i + 1) * verticalSpacing;
        positions[nodesAtLevel[i]] = Offset(x, y);
      }
    }

    return positions;
  }

  List<List<String>> _buildTreeLevels(String rootId) {
    final levels = <List<String>>[];
    final visited = <String>{};

    void traverse(String nodeId, int level) {
      if (visited.contains(nodeId)) return;
      visited.add(nodeId);

      while (levels.length <= level) {
        levels.add([]);
      }

      levels[level].add(nodeId);

      final children = mindMap.nodes
          .where((n) => n.parentId == nodeId)
          .toList();
      for (final child in children) {
        traverse(child.id, level + 1);
      }
    }

    traverse(rootId, 0);
    return levels;
  }

  void _drawConnections(Canvas canvas, Map<String, Offset> positions) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (final node in mindMap.nodes) {
      if (node.parentId != null &&
          positions.containsKey(node.parentId) &&
          positions.containsKey(node.id)) {
        final start = positions[node.parentId]!;
        final end = positions[node.id]!;

        final path = Path();
        path.moveTo(start.dx, start.dy);

        final controlPoint1 = Offset(
          start.dx + (end.dx - start.dx) * 0.5,
          start.dy,
        );
        final controlPoint2 = Offset(
          start.dx + (end.dx - start.dx) * 0.5,
          end.dy,
        );

        path.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          end.dx,
          end.dy,
        );

        canvas.drawPath(path, paint);
      }
    }
  }

  void _drawNodes(Canvas canvas, Map<String, Offset> positions) {
    for (final node in mindMap.nodes) {
      final position = positions[node.id];
      if (position == null) continue;

      final color = (node.parentId == null ? Colors.blue : Colors.teal);

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final radius = node.parentId == null ? 6.0 : 4.0;
      canvas.drawCircle(position, radius, paint);

      final borderPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(position, radius, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant MindMapPreviewPainter oldDelegate) {
    return oldDelegate.mindMap != mindMap;
  }
}
