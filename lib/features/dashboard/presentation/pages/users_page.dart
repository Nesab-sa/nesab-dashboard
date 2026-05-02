import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:nesab_dashboard/core/extensions/context_extensions.dart';
import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/core/theme/app_dimensions.dart';
import 'package:nesab_dashboard/features/dashboard/data/models/user_model.dart';
import 'package:nesab_dashboard/features/dashboard/data/repositories/users_repository.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/cubit/users_cubit.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/cubit/users_state.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UsersCubit(UsersRepository())..loadPage(1),
      child: const _UsersView(),
    );
  }
}

class _UsersView extends StatefulWidget {
  const _UsersView();
  @override
  State<_UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends State<_UsersView>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.dashboardBorder : AppColors.lightModeBorder;

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.usersTitle,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          _SearchBar(
            controller: _searchController,
            onChanged: (v) => context.read<UsersCubit>().search(v),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: TabBar(
              controller: _tab,
              labelColor: AppColors.blue,
              unselectedLabelColor: isDark
                  ? AppColors.dashboardTextSecondary
                  : AppColors.lightModeTextSecondary,
              indicatorColor: AppColors.blue,
              tabs: const [Tab(text: 'الكل'), Tab(text: 'الجدد')],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Expanded(
            child: BlocBuilder<UsersCubit, UsersState>(
              builder: (context, state) {
                return state.when(
                  initial: () => const SizedBox(),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  loaded: (users, page, totalCount, pageSize) {
                    final newUsers = users
                        .where((u) => u.createdAt
                            .isAfter(DateTime.now().subtract(const Duration(days: 7))))
                        .toList();
                    final activeCount = users
                        .where((u) =>
                            u.lastLogin != null &&
                            u.lastLogin!.isAfter(
                                DateTime.now().subtract(const Duration(days: 30))))
                        .length;
                    final displayUsers = _tab.index == 0 ? users : newUsers;
                    return Column(
                      children: [
                        Expanded(
                          child: _PaginatedTable(
                            users: displayUsers,
                            page: page,
                            totalCount: _tab.index == 0 ? totalCount : newUsers.length,
                            pageSize: pageSize,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingMd),
                        _StatsBar(
                          totalUsers: totalCount,
                          activeUsers: activeCount,
                          newUsers: newUsers.length,
                        ),
                      ],
                    );
                  },
                  error: (msg) => Center(child: Text(msg)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats Bar ──────────────────────────────────────────────────────────────

class _StatsBar extends StatelessWidget {
  const _StatsBar({
    required this.totalUsers,
    required this.activeUsers,
    required this.newUsers,
  });
  final int totalUsers;
  final int activeUsers;
  final int newUsers;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingLg, vertical: AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: isDark ? AppColors.dashboardCard : AppColors.lightModeCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
            color: isDark ? AppColors.dashboardBorder : AppColors.lightModeBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: FontAwesomeIcons.users,
            label: 'إجمالي المستخدمين',
            value: totalUsers.toString(),
            color: AppColors.blue,
          ),
          Container(
              height: 40,
              width: 1,
              color: isDark ? AppColors.dashboardBorder : AppColors.lightModeBorder),
          _StatItem(
            icon: FontAwesomeIcons.circleCheck,
            label: 'النشطون (30 يوم)',
            value: activeUsers.toString(),
            color: AppColors.success,
          ),
          Container(
              height: 40,
              width: 1,
              color: isDark ? AppColors.dashboardBorder : AppColors.lightModeBorder),
          _StatItem(
            icon: FontAwesomeIcons.userPlus,
            label: 'الجدد (7 أيام)',
            value: newUsers.toString(),
            color: AppColors.categoryTools,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.dashboardTextPrimary : AppColors.lightModeTextPrimary;
    final textSecondary =
        isDark ? AppColors.dashboardTextSecondary : AppColors.lightModeTextSecondary;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: FaIcon(icon, size: 16, color: color),
        ),
        const SizedBox(width: AppDimensions.spacingMd),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary)),
            Text(label, style: TextStyle(fontSize: 11, color: textSecondary)),
          ],
        ),
      ],
    );
  }
}

// ── Search Bar ─────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: context.l10n.search,
        prefixIcon: Icon(Icons.search, color: context.colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: context.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide(color: context.colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide(color: context.colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide(color: context.colorScheme.primary, width: 2),
        ),
      ),
      onChanged: onChanged,
    );
  }
}

// ── Table ──────────────────────────────────────────────────────────────────

class _PaginatedTable extends StatelessWidget {
  const _PaginatedTable({
    required this.users,
    required this.page,
    required this.totalCount,
    required this.pageSize,
  });
  final List<UserModel> users;
  final int page;
  final int totalCount;
  final int pageSize;

  @override
  Widget build(BuildContext context) {
    final totalPages = (totalCount / pageSize).ceil().clamp(1, 999);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        side: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return Padding(
                    padding: const EdgeInsets.all(AppDimensions.spacingMd),
                    child: _MobileUserList(users: users),
                  );
                }
                return _StyledDataTable(users: users, minWidth: constraints.maxWidth);
              },
            ),
          ),
          _PaginationBar(
            page: page,
            totalPages: totalPages,
            totalCount: totalCount,
            pageSize: pageSize,
            onPageChanged: (p) => context.read<UsersCubit>().loadPage(p),
          ),
        ],
      ),
    );
  }
}

class _StyledDataTable extends StatelessWidget {
  const _StyledDataTable({required this.users, required this.minWidth});
  final List<UserModel> users;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: minWidth),
            child: DataTable(
              columnSpacing: 48,
              horizontalMargin: 24,
              headingRowColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.surfaceContainerHighest),
              headingTextStyle: context.textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              dataRowColor: WidgetStateProperty.resolveWith((_) => null),
              columns: [
                DataColumn(label: _TableHeader(text: context.l10n.displayNameLabel)),
                DataColumn(label: _TableHeader(text: context.l10n.emailLabel)),
                DataColumn(label: _TableHeader(text: context.l10n.authProviderLabel)),
                DataColumn(label: _TableHeader(text: context.l10n.createdAtLabel)),
                DataColumn(label: _TableHeader(text: context.l10n.lastLoginLabel)),
              ],
              rows: users.map((u) {
                return DataRow(
                  color: WidgetStateProperty.all(
                      Theme.of(context).colorScheme.surface),
                  cells: [
                    DataCell(_TableCell(text: u.name, isBold: true)),
                    DataCell(_TableCell(text: u.email)),
                    DataCell(_AuthProviderChip(provider: u.authProvider)),
                    DataCell(_TableCell(
                        text: _formatDateTime(u.createdAt), isMuted: true)),
                    DataCell(_TableCell(
                        text: u.lastLogin != null
                            ? _formatDateTime(u.lastLogin!)
                            : '-',
                        isMuted: true)),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

String _formatDateTime(DateTime dt) {
  final d =
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  final t =
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  return '$d  $t';
}

// keep for legacy
String formatDate(DateTime dt) => _formatDateTime(dt);

class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingMd),
      child: Text(text,
          style: context.textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600)),
    );
  }
}

class _TableCell extends StatelessWidget {
  const _TableCell(
      {required this.text, this.isBold = false, this.isMuted = false});
  final String text;
  final bool isBold;
  final bool isMuted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacingMd, horizontal: AppDimensions.spacingSm),
      child: Text(text,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: isMuted
                ? Theme.of(context).colorScheme.onSurfaceVariant
                : Theme.of(context).colorScheme.onSurface,
          )),
    );
  }
}

class _AuthProviderChip extends StatelessWidget {
  const _AuthProviderChip({required this.provider});
  final String? provider;

  @override
  Widget build(BuildContext context) {
    final p = provider ?? '-';
    final isGoogle = provider?.toLowerCase() == 'google';
    final color = isGoogle ? AppColors.blue600 : AppColors.categoryTools;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd, vertical: AppDimensions.spacingXs),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(p,
          style: context.textTheme.labelSmall
              ?.copyWith(color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _MobileUserList extends StatelessWidget {
  const _MobileUserList({required this.users});
  final List<UserModel> users;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, i) {
        final u = users[i];
        return Card(
          margin: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingLg,
                vertical: AppDimensions.spacingSm),
            title: Text(u.name,
                style: context.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(u.email,
                    style: context.textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text('تسجيل: ${_formatDateTime(u.createdAt)}',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.dashboardTextSecondary)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.page,
    required this.totalPages,
    required this.totalCount,
    required this.pageSize,
    required this.onPageChanged,
  });
  final int page;
  final int totalPages;
  final int totalCount;
  final int pageSize;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacingMd, horizontal: AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border:
            Border(top: BorderSide(color: Theme.of(context).colorScheme.outline)),
        borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(AppDimensions.radiusLg)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.l10n.pageOf(page, totalPages),
            style: context.textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PaginationButton(
                icon: FontAwesomeIcons.chevronLeft,
                onPressed: page > 1 ? () => onPageChanged(page - 1) : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingMd),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingLg,
                      vertical: AppDimensions.spacingSm),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Text('$page / $totalPages',
                      style: context.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface)),
                ),
              ),
              _PaginationButton(
                icon: FontAwesomeIcons.chevronRight,
                onPressed:
                    page < totalPages ? () => onPageChanged(page + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaginationButton extends StatelessWidget {
  const _PaginationButton({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.spacingSm),
          decoration: BoxDecoration(
            color: onPressed != null
                ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                : Theme.of(context).colorScheme.outline.withOpacity(0.5),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: FaIcon(icon,
              size: AppDimensions.iconLg,
              color: onPressed != null
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
