import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nesab/core/extensions/context_extensions.dart';
import 'package:nesab/core/routing/route_names.dart';
import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/core/constants/app_assets.dart';
import 'package:nesab/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:nesab/features/auth/presentation/cubit/auth_state.dart';
import 'package:nesab/features/onboarding/onboarding_page.dart';
import 'package:nesab/shared/widgets/app_image.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Timer _timer;
  bool _show = false;
  bool _canNavigate = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      _canNavigate = true;
      final state = context.read<AuthCubit>().state;
      state.whenOrNull(
        authenticated: (_) => context.go(RouteNames.homePath),
        unauthenticated: () => _navigateUnauthenticated(),
      );
      if (state == const AuthState.initial() ||
          state == const AuthState.loading()) {
        context.read<AuthCubit>().checkAuth();
      }
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _show = true);
    });
  }

  void _navigateUnauthenticated() {
    if (!mounted) return;
    if (hasSeenOnboarding()) {
      context.go(RouteNames.loginPath);
    } else {
      context.go(RouteNames.onboardingPath);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (!_canNavigate) return;
        state.whenOrNull(
          authenticated: (_) => context.go(RouteNames.homePath),
          unauthenticated: () => _navigateUnauthenticated(),
        );
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            // Decorative circles

            // Main content
            Center(
              child: AnimatedOpacity(
                opacity: _show ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                child: AnimatedSlide(
                  offset: _show ? Offset.zero : const Offset(0, 0.1),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo image
                      AppImage(
                        path:context.isDark ? AppAssets.appLogoDark : AppAssets.appLogoLight,
                        width: 100,
                        height: 100,
                        // color: Colors.white,
                      ),
                      const SizedBox(height: AppDimensions.spacingXxl),
                    ],
                  ),
                ),
              ),
            ),
            // Loading dots at bottom
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: _PulsingDots(controller: _controller),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingDots extends AnimatedWidget {
  const _PulsingDots({required AnimationController controller})
    : super(listenable: controller);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final delay = index * 0.2;
        final opacity = _staggeredOpacity(animation.value, delay);
        return Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 4),
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        );
      }),
    );
  }

  double _staggeredOpacity(double animationValue, double delay) {
    final adjusted = (animationValue - delay) % 1.0;
    if (adjusted < 0.5) return 0.3 + 0.7 * (adjusted / 0.5);
    return 1.0 - 0.7 * ((adjusted - 0.5) / 0.5);
  }
}
