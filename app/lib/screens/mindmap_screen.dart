import 'package:flutter/material.dart';
import 'package:note_demo/models/agent_responses/models.dart';

import 'package:flutter/material.dart';
import 'dart:math' as math;

class MindmapScreen extends StatefulWidget {
  final MindMap mindmap;

  const MindmapScreen({super.key, required this.mindmap});

  @override
  State<MindmapScreen> createState() => _MindMapFullViewState();
}

class _MindMapFullViewState extends State<MindmapScreen> {
  String? selectedNodeId;
  final TransformationController _transformationController =
      TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out_map, size: 20),
            onPressed: _resetZoom,
            tooltip: 'Reset View',
          ),
        ],
        actionsPadding: EdgeInsets.symmetric(horizontal: 8),
      ),
      body: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 0.1,
        maxScale: 4.0,
        boundaryMargin: const EdgeInsets.all(1000),
        child: Center(
          child: SizedBox(
            width: 2000,
            height: 1500,
            child: CustomPaint(
              painter: MindMapFullPainter(
                mindMap: widget.mindmap,
                selectedNodeId: selectedNodeId,
                context: context,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }
}

class MindMapFullPainter extends CustomPainter {
  final MindMap mindMap;
  final String? selectedNodeId;
  final BuildContext context;

  final Map<String, NodeBounds> _nodeBounds = {};

  MindMapFullPainter({
    required this.mindMap,
    required this.selectedNodeId,
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _nodeBounds.clear();
    final positions = _calculateNodePositions(size);

    _drawConnections(canvas, positions);
    _drawNodesWithLabels(canvas, positions, context);
  }

  Map<String, Offset> _calculateNodePositions(Size size) {
    final positions = <String, Offset>{};
    final rootNode = mindMap.nodes.firstWhere(
      (node) => node.parentId == null,
      orElse: () => mindMap.nodes.first,
    );

    final treeLevels = _buildTreeLevels(rootNode.id);

    final levelWidth = 300.0;
    final startX = 100.0;

    for (int level = 0; level < treeLevels.length; level++) {
      final nodesAtLevel = treeLevels[level];
      final x = startX + (level * levelWidth);

      final totalHeight = size.height;
      final verticalSpacing = totalHeight / (nodesAtLevel.length + 1);

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
      ..color = Colors.grey.withOpacity(0.4)
      ..strokeWidth = 2.0
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

  void _drawNodesWithLabels(
    Canvas canvas,
    Map<String, Offset> positions,
    BuildContext context,
  ) {
    for (final node in mindMap.nodes) {
      final position = positions[node.id];
      if (position == null) continue;

      final color = (node.parentId == null ? Colors.blue : Colors.teal);

      final nodeRadius = node.parentId == null ? 12.0 : 10.0;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(position, nodeRadius, paint);

      final borderPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(position, nodeRadius, borderPaint);

      _drawLabel(canvas, node, position, nodeRadius, context);
    }
  }

  void _drawLabel(
    Canvas canvas,
    MindMapNode node,
    Offset position,
    double nodeRadius,
    BuildContext context,
  ) {
    final textSpan = TextSpan(
      text: node.label,
      style: TextStyle(
        fontSize: node.parentId == null ? 16.0 : 14.0,
        fontWeight: node.parentId == null ? FontWeight.bold : FontWeight.normal,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '...',
    );

    textPainter.layout(maxWidth: 150);

    final labelOffset = Offset(
      position.dx + nodeRadius + 14,
      position.dy - textPainter.height / 2,
    );

    final backgroundRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        labelOffset.dx - 6,
        labelOffset.dy - 6,
        textPainter.width + 12,
        textPainter.height + 12,
      ),
      const Radius.circular(4),
    );

    final backgroundPaint = Paint()
      ..color = Theme.of(context).canvasColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(backgroundRect, backgroundPaint);

    textPainter.paint(canvas, labelOffset);

    _nodeBounds[node.id] = NodeBounds(
      center: position,
      radius: nodeRadius,
      labelRect: backgroundRect.outerRect,
    );
  }

  @override
  bool shouldRepaint(covariant MindMapFullPainter oldDelegate) {
    return oldDelegate.mindMap != mindMap ||
        oldDelegate.selectedNodeId != selectedNodeId;
  }
}

class NodeBounds {
  final Offset center;
  final double radius;
  final Rect labelRect;

  NodeBounds({
    required this.center,
    required this.radius,
    required this.labelRect,
  });
}
