import 'package:flutter/material.dart';

/// Animated switcher with a hero-like transition between two views.
///
/// Phase 1 (0.0–0.4): Current view scales down + fades out.
/// Phase 2 (0.3–1.0): Container smoothly resizes + new view scales up + fades in.
class AnimatedViewSwitcher extends StatefulWidget {
  const AnimatedViewSwitcher({
    required this.isFirst,
    required this.first,
    required this.second,
    this.duration = const Duration(milliseconds: 450),
    super.key,
  });

  final bool isFirst;
  final Widget first;
  final Widget second;
  final Duration duration;

  @override
  State<AnimatedViewSwitcher> createState() => _AnimatedViewSwitcherState();
}

class _AnimatedViewSwitcherState extends State<AnimatedViewSwitcher>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _fadeOut;
  late Animation<double> _scaleOut;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleIn;

  bool _showFirst = true;

  @override
  void initState() {
    super.initState();
    _showFirst = widget.isFirst;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    _scaleOut = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
      ),
    );
    _scaleIn = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedViewSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFirst != oldWidget.isFirst) {
      _controller.forward(from: 0.0).then((_) {
        if (mounted) {
          setState(() => _showFirst = widget.isFirst);
        }
      });
      // Switch the underlying widget at the midpoint
      Future.delayed(widget.duration * 0.42, () {
        if (mounted) {
          setState(() => _showFirst = widget.isFirst);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Determine which phase we're in
        final progress = _controller.value;
        final isOutPhase = progress <= 0.42;

        final opacity = isOutPhase ? _fadeOut.value : _fadeIn.value;
        final scale = isOutPhase ? _scaleOut.value : _scaleIn.value;

        return AnimatedSize(
          duration: Duration(
            milliseconds: (widget.duration.inMilliseconds * 0.6).round(),
          ),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.topCenter,
            child: Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: _showFirst ? widget.first : widget.second,
            ),
          ),
        );
      },
    );
  }
}
