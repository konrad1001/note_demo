import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class BlurredContainer extends StatelessWidget {
  const BlurredContainer({
    super.key,
    required this.child,
    this.circular,
    this.filter,
    this.colour,
  });

  final Widget child;
  final bool? circular;
  final ImageFilter? filter;
  final Color? colour;

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
    final saturation = 0.9;
    final ui.ImageFilter? saturationFilter = saturation != 1.0
        ? ui.ColorFilter.matrix(_createSaturationMatrix(saturation))
        : null;

    final blurFilter = ui.ImageFilter.blur(
      sigmaX: 2,
      sigmaY: 2,
      tileMode: TileMode.mirror,
    );

    // Combine blur and saturation filters
    final combinedFilter = saturationFilter != null
        ? ui.ImageFilter.compose(inner: saturationFilter, outer: blurFilter)
        : blurFilter;

    return BackdropFilter(
      filter: combinedFilter,
      child: Container(
        decoration: BoxDecoration(
          color: colour ?? const Color.fromARGB(135, 221, 221, 221),
          borderRadius: (circular == true) ? null : BorderRadius.circular(16),
          shape: (circular == true) ? BoxShape.circle : BoxShape.rectangle,
          border: BoxBorder.all(width: 1),
        ),
        child: Padding(padding: const EdgeInsets.all(22.0), child: child),
      ),
    );
  }

  List<double> _createSaturationMatrix(double saturation) {
    // Rec. 709 luma coefficients for RGB to grayscale conversion
    const lumR = 0.299;
    const lumG = 0.587;
    const lumB = 0.114;

    // Saturation matrix that interpolates between grayscale and original color
    // Based on: result = luminance + (color - luminance) * saturation
    final s = saturation;
    final invSat = 1.0 - s;

    return [
      lumR * invSat + s, lumG * invSat, lumB * invSat, 0, 0, // R
      lumR * invSat, lumG * invSat + s, lumB * invSat, 0, 0, // G
      lumR * invSat, lumG * invSat, lumB * invSat + s, 0, 0, // B
      0, 0, 0, 1, 0, // A
    ];
  }
}
