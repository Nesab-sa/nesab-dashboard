import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Metrics describing the grid and list card dimensions during a transition.
class LayoutMetrics {
  const LayoutMetrics({
    required this.gridWidth,
    required this.gridHeight,
    required this.listWidth,
    required this.listHeight,
    required this.t,
  });

  /// Card dimensions in full-grid mode.
  final double gridWidth;
  final double gridHeight;

  /// Card dimensions in full-list mode.
  final double listWidth;
  final double listHeight;

  /// Animation progress: 0.0 = grid, 1.0 = list.
  final double t;
}

/// Animates items between a grid layout and a vertical list layout
/// using FLIP-style positional interpolation.
///
/// Each item smoothly moves from its grid position to its list position
/// (and vice versa) while its size morphs between the two layouts.
class AnimatedLayoutSwitcher extends StatefulWidget {
  const AnimatedLayoutSwitcher({
    required this.isGrid,
    required this.itemCount,
    required this.itemBuilder,
    this.gridCrossAxisCount = 2,
    this.gridSpacing = 14.0,
    this.gridAspectRatio = 1.0,
    this.listItemHeight = 80.0,
    this.listSpacing = 12.0,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeInOutCubic,
    super.key,
  });

  final bool isGrid;
  final int itemCount;

  /// Builder that receives the index and [LayoutMetrics] with animation
  /// progress `t` (0 = grid, 1 = list).
  final Widget Function(BuildContext context, int index, LayoutMetrics metrics)
  itemBuilder;

  final int gridCrossAxisCount;
  final double gridSpacing;
  final double gridAspectRatio;
  final double listItemHeight;
  final double listSpacing;
  final Duration duration;
  final Curve curve;

  @override
  State<AnimatedLayoutSwitcher> createState() => _AnimatedLayoutSwitcherState();
}

class _AnimatedLayoutSwitcherState extends State<AnimatedLayoutSwitcher>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.isGrid ? 0.0 : 1.0,
    );
    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);
  }

  @override
  void didUpdateWidget(covariant AnimatedLayoutSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isGrid != oldWidget.isGrid) {
      if (widget.isGrid) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final parentWidth = constraints.maxWidth;

        return AnimatedBuilder(
          animation: _animation,
          builder: (context, _) {
            final t = _animation.value;

            final cols = widget.gridCrossAxisCount;
            final gridItemW =
                (parentWidth - widget.gridSpacing * (cols - 1)) / cols;
            final gridItemH = gridItemW / widget.gridAspectRatio;
            final listItemW = parentWidth;
            final listItemH = widget.listItemHeight;

            final metrics = LayoutMetrics(
              gridWidth: gridItemW,
              gridHeight: gridItemH,
              listWidth: listItemW,
              listHeight: listItemH,
              t: t,
            );

            double totalHeight = 0;
            final rects = <Rect>[];

            for (int i = 0; i < widget.itemCount; i++) {
              // Grid position
              final col = i % cols;
              final row = i ~/ cols;
              final gStart = col * (gridItemW + widget.gridSpacing);
              final gTop = row * (gridItemH + widget.gridSpacing);

              // List position
              const lStart = 0.0;
              final lTop = i * (listItemH + widget.listSpacing);

              final start = lerpDouble(gStart, lStart, t)!;
              final top = lerpDouble(gTop, lTop, t)!;
              final w = lerpDouble(gridItemW, listItemW, t)!;
              final h = lerpDouble(gridItemH, listItemH, t)!;

              rects.add(Rect.fromLTWH(start, top, w, h));
              final bottom = top + h;
              if (bottom > totalHeight) totalHeight = bottom;
            }

            return SizedBox(
              height: totalHeight,
              child: Stack(
                children: [
                  for (int i = 0; i < widget.itemCount; i++)
                    PositionedDirectional(
                      start: rects[i].left,
                      top: rects[i].top,
                      width: rects[i].width,
                      height: rects[i].height,
                      child: widget.itemBuilder(context, i, metrics),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
