import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nesab_dashboard/core/routing/auth_redirect_notifier.dart';
import 'package:nesab_dashboard/core/routing/route_names.dart';
import 'package:nesab_dashboard/features/auth/presentation/pages/admin_login_page.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/widgets/dahsboard_shell.dart';

abstract class AppRouter {
  const AppRouter._();

  static GoRouter createRouter(AuthRedirectNotifier authNotifier) {
    return GoRouter(
      initialLocation: RouteNames.loginPath,
      refreshListenable: authNotifier,
      redirect: (context, state) {
        final isLoggedIn = authNotifier.isAuthenticated;
        final isLoggingIn = state.uri.path == RouteNames.loginPath;
        if (!isLoggedIn && !isLoggingIn) {
          return RouteNames.loginPath;
        }
        if (isLoggedIn && isLoggingIn) {
          return RouteNames.dashboardPath;
        }
        return null;
      },
      routes: [
        GoRoute(
          path: RouteNames.loginPath,
          name: RouteNames.loginName,
          pageBuilder: (_, state) =>
              MaterialPage(key: state.pageKey, child: const AdminLoginPage()),
        ),
        GoRoute(
          path: RouteNames.dashboardPath,
          name: RouteNames.dashboardName,
          pageBuilder: (_, state) =>
              MaterialPage(key: state.pageKey, child:  DashboardShell()),
        ),
      ],
    );
  }
}
