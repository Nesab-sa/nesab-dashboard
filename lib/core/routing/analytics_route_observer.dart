import 'package:flutter/widgets.dart';
import 'package:nesab/core/services/analytics_service.dart';

/// A [NavigatorObserver] that logs screen views via [AnalyticsService]
/// whenever the top-most route changes.
class AnalyticsRouteObserver extends NavigatorObserver {
  AnalyticsRouteObserver(this._analyticsService);

  final AnalyticsService _analyticsService;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logScreenView(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) _logScreenView(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) _logScreenView(previousRoute);
  }

  void _logScreenView(Route<dynamic> route) {
    final screenName = route.settings.name;
    if (screenName != null && screenName.isNotEmpty) {
      _analyticsService.logScreenView(screenName);
    }
  }
}
