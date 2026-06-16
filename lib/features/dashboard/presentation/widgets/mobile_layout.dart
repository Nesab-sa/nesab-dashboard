import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:nesab_dashboard/core/extensions/context_extensions.dart';
import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/core/theme/app_dimensions.dart';
import 'package:nesab_dashboard/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/widgets/dashboard_section.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/widgets/side_menu.dart';

class MobileLayout extends StatelessWidget {
  const MobileLayout({
    super.key,
    required this.child,
    required this.selectedSection,
    this.aiConvBadge = 0,
  });

  final Widget child;
  final ValueNotifier<DashboardSection> selectedSection;
  final int aiConvBadge;

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
        width: 280,
        backgroundColor: bgColor,
        child: SafeArea(
          child: ValueListenableBuilder<DashboardSection>(
            valueListenable: selectedSection,
            builder: (context, current, _) {
              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.spacingMd,
                      ),
                      children: [
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
                        MobileNavItem(
                          icon: FontAwesomeIcons.commentsDollar,
                          label: 'محادثات الـ AI',
                          currentSection: current,
                          section: DashboardSection.aiConversations,
                          selectedSection: selectedSection,
                          textColor: textColor,
                          badge: aiConvBadge > 0 ? aiConvBadge : null,
                        ),
                        Divider(height: 1, color: dividerColor),
                        MobileLogoutButton(textColor: textColor),
                        const SizedBox(height: AppDimensions.spacingSm),
                      ],
                    ),
                  ),
                ],
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
    this.badge,
  });

  final FaIconData icon;
  final String label;
  final DashboardSection currentSection;
  final DashboardSection section;
  final ValueNotifier<DashboardSection> selectedSection;
  final Color textColor;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          FaIcon(icon, size: 18, color: textColor),
          if (badge != null)
            Positioned(
              top: -6,
              right: -8,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '$badge',
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        label,
        style: TextStyle(color: textColor),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      selected: currentSection == section,
      onTap: () {
        selectedSection.value = section;
        Navigator.of(context).pop();
      },
    );
  }
}

class MobileLogoutButton extends StatelessWidget {
  const MobileLogoutButton({super.key, required this.textColor});

  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: FaIcon(
        FontAwesomeIcons.arrowRightFromBracket,
        size: 18,
        color: textColor,
      ),
      title: Text(
        context.l10n.logout,
        style: TextStyle(color: textColor),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      onTap: () async {
        Navigator.of(context).pop();
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(context.l10n.logoutConfirmTitle),
            content: Text(context.l10n.logoutConfirmMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(context.l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(context.l10n.logout),
              ),
            ],
          ),
        );
        if (confirm == true && context.mounted) {
          await context.read<AuthCubit>().logout();
        }
      },
    );
  }
}