import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:nesab_dashboard/core/extensions/context_extensions.dart';
import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/core/theme/app_dimensions.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/widgets/dashboard_section.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/widgets/side_menu.dart';

class MobileLayout extends StatelessWidget {
  const MobileLayout({
    super.key,
    required this.child,
    required this.selectedSection,
  });

  final Widget child;
  final ValueNotifier<DashboardSection> selectedSection;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.dashboardBg : AppColors.lightModeBg;
    final dividerColor =
        isDark ? AppColors.dashboardBorder : AppColors.lightModeBorder;
    final textColor = isDark
        ? AppColors.dashboardTextPrimary
        : AppColors.lightModeTextPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const FaIcon(FontAwesomeIcons.bars),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
            tooltip: 'Menu',
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: bgColor,
        child: SafeArea(
          child: ValueListenableBuilder<DashboardSection>(
            valueListenable: selectedSection,
            builder: (context, current, _) {
              final items = <Widget>[
                const Logo(expanded: true),
                Divider(height: 1, color: dividerColor),
                MobileNavItem(
                  icon: FontAwesomeIcons.users,
                  label: context.l10n.usersTitle,
                  currentSection: current,
                  section: DashboardSection.users,
                  selectedSection: selectedSection,
                  textColor: textColor,
                ),
                MobileNavItem(
                  icon: FontAwesomeIcons.userPlus,
                  label: context.l10n.managersTitle,
                  currentSection: current,
                  section: DashboardSection.createAdmins,
                  selectedSection: selectedSection,
                  textColor: textColor,
                ),
                MobileNavItem(
                  icon: FontAwesomeIcons.folderTree,
                  label: context.l10n.categoriesTitle,
                  currentSection: current,
                  section: DashboardSection.categories,
                  selectedSection: selectedSection,
                  textColor: textColor,
                ),
                MobileNavItem(
                  icon: FontAwesomeIcons.wrench,
                  label: context.l10n.toolsTitle,
                  currentSection: current,
                  section: DashboardSection.tools,
                  selectedSection: selectedSection,
                  textColor: textColor,
                ),
                MobileNavItem(
                  icon: FontAwesomeIcons.mobileScreen,
                  label: 'صفحات التطبيق',
                  currentSection: current,
                  section: DashboardSection.appPages,
                  selectedSection: selectedSection,
                  textColor: textColor,
                ),
                MobileNavItem(
                  icon: FontAwesomeIcons.robot,
                  label: 'إعدادات الذكاء الاصطناعي',
                  currentSection: current,
                  section: DashboardSection.aiSettings,
                  selectedSection: selectedSection,
                  textColor: textColor,
                ),
                MobileNavItem(
                  icon: FontAwesomeIcons.chartLine,
                  label: 'هوامش الربح',
                  currentSection: current,
                  section: DashboardSection.profitMargins,
                  selectedSection: selectedSection,
                  textColor: textColor,
                ),
                MobileNavItem(
                  icon: FontAwesomeIcons.bell,
                  label: 'رسائل الإشعار',
                  currentSection: current,
                  section: DashboardSection.notifications,
                  selectedSection: selectedSection,
                  textColor: textColor,
                ),
                Divider(height: 1, color: dividerColor),
              ];

              return ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.spacingMd,
                ),
                children: items,
              );
            },
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = MediaQuery.sizeOf(context);
          final w = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : size.width;
          final h = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : size.height;
          return SizedBox(width: w, height: h, child: child);
        },
      ),
    );
  }
}

class MobileNavItem extends StatelessWidget {
  const MobileNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.currentSection,
    required this.section,
    required this.selectedSection,
    required this.textColor,
  });

  final IconData icon;
  final String label;
  final DashboardSection currentSection;
  final DashboardSection section;
  final ValueNotifier<DashboardSection> selectedSection;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final tile = ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(label, style: TextStyle(color: textColor)),
      selected: currentSection == section,
      onTap: () {
        selectedSection.value = section;
        Navigator.of(context).pop();
      },
    );
    return tile;
  }
}