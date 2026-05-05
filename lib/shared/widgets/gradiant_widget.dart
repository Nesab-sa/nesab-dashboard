import 'dart:ui';

import 'package:flutter/material.dart';

/// A blurred multi-color aurora background effect with optional child content.
///
/// Renders several overlapping color orbs with heavy Gaussian blur,
/// producing an organic mesh-gradient look similar to frosted glass cards.
///
/// The [child] is rendered on top of the gradient, making this widget
/// usable as a standalone decorated container:
/// ```dart
/// GradiantWidget(
///   width: 300,
///   height: 200,
///   child: Text('On top of aurora'),
/// )
/// ```
class GradiantWidget extends StatelessWidget {
  const GradiantWidget({
    this.width,
    this.height = 400,
    this.blurSigma = 80,
    this.opacity = 0,
    this.child,
    super.key,
  });

  /// Width of the gradient area. Defaults to full width if null.
  final double? width;

  /// Total height of the gradient area.
  final double height;

  /// Gaussian blur intensity. Higher = softer blobs.
  final double blurSigma;

  /// Overall opacity of the effect (0.0 – 1.0).
  final double opacity;

  /// Optional widget rendered on top of the gradient.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: blurSigma,
        sigmaY: blurSigma,
        tileMode: TileMode.decal,
      ),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              // const Color.fromARGB(255, 17, 41, 255).withValues(alpha: 0.3),
              // const Color(0xFF38BDF8).withValues(alpha: 0.3),
              const Color(0xFF8B5CF6).withValues(alpha: 0.15),
              const Color(0xFF38BDF8).withValues(alpha: 0.10),
            ],
          ),
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
    );
  }
}
