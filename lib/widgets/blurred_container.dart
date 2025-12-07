import 'dart:ui';

import 'package:flutter/material.dart';

class BlurredContainer extends StatelessWidget {
  const BlurredContainer({
    super.key,
    required this.child,
    this.circular,
    this.filter,
  });

  final Widget child;
  final bool? circular;
  final ImageFilter? filter;

  @override
  Widget build(BuildContext context) {
    if (circular == true) {
      return ClipOval(child: _blurredContainer());
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: _blurredContainer(),
    );
  }

  Widget _blurredContainer() {
    return BackdropFilter(
      filter: filter ?? ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(135, 221, 221, 221),
          borderRadius: (circular == true) ? null : BorderRadius.circular(16),
          shape: (circular == true) ? BoxShape.circle : BoxShape.rectangle,
          border: BoxBorder.all(width: 1),
        ),
        child: Padding(padding: const EdgeInsets.all(22.0), child: child),
      ),
    );
  }
}
