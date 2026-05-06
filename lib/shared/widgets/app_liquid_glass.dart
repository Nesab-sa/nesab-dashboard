import 'package:flutter/material.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';

import 'package:nesab_dashboard/core/theme/app_dimensions.dart';

/// A reusable liquid glass lens widget wrapping [LiquidGlassView].
///
/// Place [backgroundWidget] behind the glass, and [lenses] on top
/// to create magnification / distortion / blur effects.
///
/// Example:
/// ```dart
/// AppLiquidGlass(
///   backgroundWidget: Image.asset('assets/images/bg.png'),
///   lenses: [
///     AppLiquidGlassLens(
///       width: 200,
///       height: 120,
///       position: LiquidGlassAlignPosition(alignment: Alignment.center),
///       child: Text('Hello'),
///     ),
///   ],
/// )
/// ```
class AppLiquidGlass extends StatelessWidget {
  const AppLiquidGlass({
    required this.backgroundWidget,
    required this.lenses,
    this.pixelRatio = 1.0,
    this.realTimeCapture = true,
    super.key,
  });

  /// The content rendered behind the glass lenses.
  final Widget backgroundWidget;

  /// One or more [AppLiquidGlassLens] placed over the background.
  final List<AppLiquidGlassLens> lenses;

  /// Quality / performance trade-off (higher = sharper, slower).
  final double pixelRatio;

  /// Whether to re-capture the background every frame.
  /// Set to `false` for static backgrounds.
  final bool realTimeCapture;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassView(
      pixelRatio: pixelRatio,
      realTimeCapture: realTimeCapture,
      backgroundWidget: backgroundWidget,
      children: [for (final lens in lenses) lens._build()],
    );
  }
}

/// Configuration for a single liquid glass lens.
///
/// Controls size, shape, distortion, magnification, tint, and
/// optional overlay [child].
class AppLiquidGlassLens {
  const AppLiquidGlassLens({
    required this.position,
    this.width = 200,
    this.height = 100,
    this.magnification = 1.0,
    this.distortion = 0.1,
    this.distortionWidth = 30,
    this.chromaticAberration = 0.003,
    this.shape = const RoundedRectangleShape(
      cornerRadius: AppDimensions.radiusLg,
    ),
    this.blur = const LiquidGlassBlur(),
    this.color = Colors.transparent,
    this.draggable = false,
    this.child,
  });

  final double width;
  final double height;

  /// Zoom intensity of the lens.
  final double magnification;

  /// Warping strength (0 = none, higher = more warp).
  final double distortion;

  /// Thickness of the distortion band around the lens perimeter.
  final double distortionWidth;

  /// RGB channel separation intensity.
  final double chromaticAberration;

  /// Geometric shape of the lens (e.g. [RoundedRectangleShape], [SuperellipseShape]).
  final LiquidGlassShape shape;

  /// Blur configuration for the lens background.
  final LiquidGlassBlur blur;

  /// Tint color applied to the glass.
  final Color color;

  /// Whether the lens can be dragged around.
  final bool draggable;

  /// Position of the lens.
  /// Use [LiquidGlassAlignPosition] or [LiquidGlassOffsetPosition].
  final LiquidGlassPosition position;

  /// Optional widget rendered on top of the glass surface.
  final Widget? child;

  LiquidGlass _build() {
    return LiquidGlass(
      width: width,
      height: height,
      magnification: magnification,
      distortion: distortion,
      distortionWidth: distortionWidth,
      chromaticAberration: chromaticAberration,
      shape: shape,
      blur: blur,
      color: color,
      draggable: draggable,
      position: position,
      child: child,
    );
  }
}
