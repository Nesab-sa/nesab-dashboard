import 'package:flutter/material.dart';

import 'dashboard_section.dart';

/// Provides [ValueNotifier<DashboardSection>] to descendants.
/// Used so pages like Overview can switch to Users without navigation.
class DashboardSectionProvider extends InheritedWidget {
  const DashboardSectionProvider({
    super.key,
    required this.selectedSection,
    required super.child,
  });

  final ValueNotifier<DashboardSection> selectedSection;

  static ValueNotifier<DashboardSection>? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DashboardSectionProvider>()
        ?.selectedSection;
  }

  @override
  bool updateShouldNotify(covariant DashboardSectionProvider oldWidget) =>
      selectedSection != oldWidget.selectedSection;
}
