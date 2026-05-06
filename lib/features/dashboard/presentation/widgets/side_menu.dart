import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:nesab_dashboard/core/extensions/context_extensions.dart';
import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/core/theme/app_dimensions.dart';
import 'package:nesab_dashboard/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/widgets/dashboard_section.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    super.key,
    required this.expanded,
    required this.selectedSection,
  });

  final bool expanded;
  final ValueNotifier<DashboardSection> selectedSection;

  static const double expandedWidth = 260;
  static const double collapsedWidth = 74;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final menuColor = isDark ? AppColors.dashboardBg : AppColors.lightModeBg;
    final borderColor = isDark
        ? AppColors.dashboardBorder
        : AppColors.lightModeBorder;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: expanded ? expandedWidth : collapsedWidth,
      decoration: BoxDecoration(
        color: menuColor,
        border: Border(right: BorderSide(color: borderColor, width: 1)),
      ),
      child: Column(
        children: [
          Logo(expanded: expanded),
          if (expanded) const SidebarSearch(),
          Divider(height: 1, color: borderColor),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.spacingMd,
              ),
              children: [
                NavItem(
                  icon: FontAwesomeIcons.users,
                  label: context.l10n.usersTitle,
                  section: DashboardSection.users,
                  expanded: expanded,
                  selectedSection: selectedSection,
                ),
                NavItem(
                  icon: FontAwesomeIcons.userPlus,
                  label: context.l10n.managersTitle,
                  section: DashboardSection.createAdmins,
                  expanded: expanded,
                  selectedSection: selectedSection,
                ),
                NavItem(
                  icon: FontAwesomeIcons.folderTree,
                  label: context.l10n.categoriesTitle,
                  section: DashboardSection.categories,
                  expanded: expanded,
                  selectedSection: selectedSection,
                ),
                NavItem(
                  icon: FontAwesomeIcons.wrench,
                  label: context.l10n.toolsTitle,
                  section: DashboardSection.tools,
                  expanded: expanded,
                  selectedSection: selectedSection,
                ),
                NavItem(
                  icon: FontAwesomeIcons.mobileScreen,
                  label: 'صفحات التطبيق',
                  section: DashboardSection.appPages,
                  expanded: expanded,
                  selectedSection: selectedSection,
                ),
                NavItem(
                  icon: FontAwesomeIcons.robot,
                  label: 'إعدادات الذكاء الاصطناعي',
                  section: DashboardSection.aiSettings,
                  expanded: expanded,
                  selectedSection: selectedSection,
                ),
                NavItem(
                  icon: FontAwesomeIcons.chartLine,
                  label: 'هوامش الربح',
                  section: DashboardSection.profitMargins,
                  expanded: expanded,
                  selectedSection: selectedSection,
                ),
                NavItem(
                  icon: FontAwesomeIcons.bell,
                  label: 'رسائل الإشعار',
                  section: DashboardSection.notifications,
                  expanded: expanded,
                  selectedSection: selectedSection,
                ),
                NavItem(
                  icon: FontAwesomeIcons.commentsDollar,
                  label: 'محادثات الـ AI',
                  section: DashboardSection.aiConversations,
                  expanded: expanded,
                  selectedSection: selectedSection,
                ),
Divider(height: 1, color: borderColor),
              ],
            ),
          ),
          Divider(height: 1, color: borderColor),
          SidebarLogoutButton(expanded: expanded),
          const SizedBox(height: AppDimensions.spacingSm),
        ],
      ),
    );
  }
}

class SidebarSearch extends StatelessWidget {
  const SidebarSearch({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hintColor = isDark
        ? AppColors.dashboardTextSecondary
        : AppColors.lightModeTextSecondary;
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(color: hintColor, fontSize: 14),
          prefixIcon: Icon(Icons.search, size: 20, color: hintColor),
          filled: true,
          fillColor: isDark ? AppColors.dashboardCard : AppColors.lightModeCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
            vertical: AppDimensions.spacingSm,
          ),
        ),
      ),
    );
  }
}

class Logo extends StatelessWidget {
  const Logo({super.key, required this.expanded});

  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingLg,
        vertical: AppDimensions.spacingMd,
      ),
      child: Row(
        children: [
          const LogoImage(),
          if (expanded) ...[
            const SizedBox(width: AppDimensions.spacingMd),
            const Expanded(
              child: LogoText(),
            ),
          ],
        ],
      ),
    );
  }
}

class LogoImage extends StatelessWidget {
  const LogoImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      height: 40,
      width: 40,
      fit: BoxFit.contain,
      cacheWidth: 80,
      cacheHeight: 80,
      filterQuality: FilterQuality.medium,
    );
  }
}

class LogoText extends StatelessWidget {
  const LogoText({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColors.dashboardTextPrimary
        : AppColors.lightModeTextPrimary;
    return Text(
      context.l10n.dashboardTitle,
      style: context.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

class NavItem extends StatelessWidget {
  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.section,
    required this.expanded,
    required this.selectedSection,
    this.badge,
  });

  final IconData icon;
  final String label;
  final DashboardSection section;
  final bool expanded;
  final ValueNotifier<DashboardSection> selectedSection;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DashboardSection>(
      valueListenable: selectedSection,
      builder: (context, current, _) {
        final isActive = current == section;
        return NavItemContent(
          icon: icon,
          label: label,
          isActive: isActive,
          expanded: expanded,
          badge: badge,
          onTap: () => selectedSection.value = section,
        );
      },
    );
  }
}

class NavItemContent extends StatelessWidget {
  const NavItemContent({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.expanded,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final bool expanded;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? AppColors.blue : AppColors.blue600;
    final textColor = isDark
        ? AppColors.dashboardTextPrimary
        : AppColors.lightModeTextPrimary;
    final secondaryColor = isDark
        ? AppColors.dashboardTextSecondary
        : AppColors.lightModeTextSecondary;
    final selectedColor = isDark
        ? AppColors.dashboardSideMenuHover
        : AppColors.lightModeNavActive;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingSm),
      child: ListTile(
        selectedTileColor: selectedColor,
        contentPadding: EdgeInsets.symmetric(
          horizontal: expanded ? 16 : 8,
          vertical: 4,
        ),
        leading: NavItemIcon(
          icon: icon,
          isActive: isActive,
          activeColor: activeColor,
          secondaryColor: secondaryColor,
          badge: badge,
        ),
        title: expanded
            ? Text(
                label,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? textColor : secondaryColor,
                ),
                overflow: TextOverflow.ellipsis,
              )
            : null,
        selected: isActive,
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
      ),
    );
  }
}

class NavItemIcon extends StatelessWidget {
  const NavItemIcon({
    super.key,
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.secondaryColor,
    this.badge,
  });

  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final Color secondaryColor;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: FaIcon(
              icon,
              size: AppDimensions.iconLg,
              color: isActive ? activeColor : secondaryColor,
            ),
          ),
          if (badge != null)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  '$badge',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SidebarLogoutButton extends StatelessWidget {
  const SidebarLogoutButton({super.key, required this.expanded});

  final bool expanded;

  static Future<void> _showLogoutDialog(BuildContext context) async {
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
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark
        ? AppColors.dashboardTextSecondary
        : AppColors.lightModeTextSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingSm),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: expanded ? 16 : 8,
          vertical: 4,
        ),
        leading: SizedBox(
          width: 28,
          height: 28,
          child: Center(
            child: FaIcon(
              FontAwesomeIcons.arrowRightFromBracket,
              size: AppDimensions.iconLg,
              color: secondaryColor,
            ),
          ),
        ),
        title: expanded
            ? Text(
                context.l10n.logout,
                style: TextStyle(color: secondaryColor),
                overflow: TextOverflow.ellipsis,
              )
            : null,
        onTap: () => _showLogoutDialog(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
      ),
    );
  }
}