import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nesab/app/dependency_injection.dart';
import 'package:nesab/core/constants/app_constants.dart';
import 'package:nesab/core/routing/analytics_route_observer.dart';
import 'package:nesab/core/routing/route_names.dart';
import 'package:nesab/core/services/analytics_service.dart';
import 'package:nesab/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:nesab/features/auth/presentation/pages/login_page.dart';
import 'package:nesab/features/auth/presentation/pages/register_page.dart';
import 'package:nesab/features/category_details/pages/category_detail_page.dart';
import 'package:nesab/features/home/presentation/pages/home_page.dart';
import 'package:nesab/features/onboarding/onboarding_page.dart';
import 'package:nesab/features/profile/presentation/pages/profile_page.dart';
import 'package:nesab/features/calculators/presentation/pages/profit_margins_compare_page.dart';
import 'package:nesab/features/splash/presentation/pages/splash_page.dart';

/// Central GoRouter configuration for the Nesab app.
///
/// All route definitions live here.
abstract class AppRouter {
  const AppRouter._();

  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    initialLocation: RouteNames.splashPath,
    observers: [AnalyticsRouteObserver(getIt<AnalyticsService>())],
    routes: [
      // ── Standalone routes (no bottom nav) ──────────────────────────────
      GoRoute(
        path: RouteNames.splashPath,
        name: RouteNames.splashName,
        pageBuilder: (context, state) =>
            _buildPage(state: state, child: const SplashPage()),
      ),
      GoRoute(
        path: RouteNames.loginPath,
        name: RouteNames.loginName,
        pageBuilder: (context, state) =>
            _buildPage(state: state, child: const LoginPage()),
      ),
      GoRoute(
        path: RouteNames.registerPath,
        name: RouteNames.registerName,
        pageBuilder: (context, state) =>
            _buildPage(state: state, child: const RegisterPage()),
      ),
      GoRoute(
        path: RouteNames.forgotPasswordPath,
        name: RouteNames.forgotPasswordName,
        pageBuilder: (context, state) =>
            _buildPage(state: state, child: const ForgotPasswordPage()),
      ),

      GoRoute(
        path: RouteNames.onboardingPath,
        name: RouteNames.onboardingName,
        pageBuilder: (context, state) =>
            _buildPage(state: state, child: const OnboardingPage()),
      ),

      // ── Home route (no bottom nav) ──────────────────────────────────────
      GoRoute(
        path: RouteNames.homePath,
        name: RouteNames.homeName,
        pageBuilder: (context, state) =>
            _buildPage(state: state, child: const HomePage()),
      ),

      // ── Main app routes ─────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.categoryDetailPath,
        name: RouteNames.categoryDetailName,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _buildPage(
            state: state,
            child: CategoryDetailPage(categoryId: id),
          );
        },
      ),
      GoRoute(
        path: RouteNames.profilePath,
        name: RouteNames.profileName,
        pageBuilder: (context, state) =>
            _buildPage(state: state, child: const ProfilePage()),
      ),
      GoRoute(
        path: RouteNames.profitMarginsPath,
        name: RouteNames.profitMarginsName,
        pageBuilder: (context, state) =>
            _buildPage(state: state, child: const ProfitMarginsComparePage()),
      ),
    ],
  );

  /// Builds a [CustomTransitionPage] with a horizontal [SlideTransition].
  ///
  /// Duration is controlled by [AppConstants.defaultAnimationDuration].
  static CustomTransitionPage<void> _buildPage({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: AppConstants.defaultAnimationDuration,
      reverseTransitionDuration: AppConstants.defaultAnimationDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.ease,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
      },
    );
  }
}
