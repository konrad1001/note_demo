import 'dart:ui';

import 'package:flutter/material.dart';

class BlurredContainer extends StatelessWidget {
  const BlurredContainer({super.key, required this.child, this.circular});

  final Widget child;
  final bool? circular;

  @override
  Widget build(BuildContext context) {
    if (circular == true) {
      return ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(83, 182, 182, 182),
              borderRadius: (circular == true)
                  ? null
                  : BorderRadius.circular(16),
              shape: (circular == true) ? BoxShape.circle : BoxShape.rectangle,
            ),
            child: Padding(padding: const EdgeInsets.all(22.0), child: child),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: (circular == true)
          ? BorderRadius.zero
          : BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(83, 182, 182, 182),
            borderRadius: (circular == true) ? null : BorderRadius.circular(16),
            shape: (circular == true) ? BoxShape.circle : BoxShape.rectangle,
          ),
          child: Padding(padding: const EdgeInsets.all(22.0), child: child),
        ),
      ),
    );
  }
}
