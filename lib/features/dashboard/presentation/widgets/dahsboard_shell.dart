import 'package:flutter/material.dart';

import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/pages/ai_settings_page.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/pages/app_pages_page.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/pages/notifications_page.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/pages/profit_margins_page.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/pages/categories_page.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/pages/managers_page.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/pages/tools_page.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/pages/users_page.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/widgets/dashboard_section.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/widgets/dashboard_section_provider.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/widgets/mobile_layout.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/widgets/side_menu.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/widgets/top_header.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  late final ValueNotifier<DashboardSection> _selectedSection;

  @override
  void initState() {
    super.initState();
    _selectedSection = ValueNotifier(DashboardSection.users);
  }

  @override
  void dispose() {
    _selectedSection.dispose();
    super.dispose();
  }

  Widget _buildContent(DashboardSection section) {
    return switch (section) {
      DashboardSection.users => const UsersPage(),
      DashboardSection.createAdmins => const ManagersPage(),
      DashboardSection.categories => const CategoriesPage(),
      DashboardSection.tools => const ToolsPage(),
      DashboardSection.appPages => const AppPagesPage(),
      DashboardSection.aiSettings => const AiSettingsPage(),
      DashboardSection.profitMargins => const ProfitMarginsPage(),
      DashboardSection.notifications => const NotificationsPage(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.dashboardBg : AppColors.lightModeBg;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        return DashboardSectionProvider(
          selectedSection: _selectedSection,
          child: Scaffold(
            backgroundColor: bgColor,
            body: isWide
                ? Row(
                    children: [
                      SideMenu(
                        expanded: constraints.maxWidth >= 960,
                        selectedSection: _selectedSection,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const TopHeader(),
                            Expanded(
                              child: ValueListenableBuilder<DashboardSection>(
                                valueListenable: _selectedSection,
                                builder: (context, section, _) =>
                                    _buildContent(section),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : ValueListenableBuilder<DashboardSection>(
                    valueListenable: _selectedSection,
                    builder: (context, section, _) => MobileLayout(
                      selectedSection: _selectedSection,
                      child: _buildContent(section),
                    ),
                  ),
          ),
        );
      },
    );
  }
}