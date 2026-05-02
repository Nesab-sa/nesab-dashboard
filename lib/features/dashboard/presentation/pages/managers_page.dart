import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:nesab_dashboard/core/extensions/context_extensions.dart';
import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/core/theme/app_dimensions.dart';
import 'package:nesab_dashboard/features/dashboard/data/models/user_model.dart';
import 'package:nesab_dashboard/features/dashboard/data/repositories/create_admin_repository.dart';
import 'package:nesab_dashboard/features/dashboard/data/repositories/managers_repository.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/cubit/create_admins_cubit.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/cubit/create_admins_state.dart';
import 'package:nesab_dashboard/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:nesab_dashboard/features/auth/presentation/cubit/auth_state.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/cubit/managers_cubit.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/cubit/managers_state.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/widgets/create_manager_form.dart';
import 'package:nesab_dashboard/shared/widgets/custom_button.dart';

class ManagersPage extends StatelessWidget {
  const ManagersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ManagersCubit(
            repository: ManagersRepository(),
            createAdminRepository: CreateAdminRepository(),
          )..loadManagers(),
        ),
        BlocProvider(
          create: (_) => CreateAdminsCubit(CreateAdminRepository()),
        ),
      ],
      child: const _ManagersView(),
    );
  }
}

class _ManagersView extends StatefulWidget {
  const _ManagersView();

  @override
  State<_ManagersView> createState() => _ManagersViewState();
}

class _ManagersViewState extends State<_ManagersView> {
  bool _showCreateForm = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateAdminsCubit, CreateAdminsState>(
      listener: (context, state) {
        state.whenOrNull(
          success: () {
            setState(() => _showCreateForm = false);
            context.read<ManagersCubit>().loadManagers();
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.managersTitle,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingSm),
                    Text(
                      context.l10n.managersSubtitle,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                CustomButton(
                  text: context.l10n.addManagerButton,
                  width: 180,
                  onPressed: () =>
                      setState(() => _showCreateForm = !_showCreateForm),
                  icon: FaIcon(
                    _showCreateForm
                        ? FontAwesomeIcons.chevronUp
                        : FontAwesomeIcons.userPlus,
                    size: AppDimensions.iconMd,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingXl),
            if (_showCreateForm) ...[
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: CreateManagerForm(
                  compact: true,
                  onSuccess: () => setState(() => _showCreateForm = false),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXl),
            ],
            Expanded(child: _ManagersList()),
          ],
        ),
      ),
    );
  }
}

class _ManagersList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManagersCubit, ManagersState>(
      builder: (context, state) {
        return state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (managers) => _ManagersTable(managers: managers),
          error: (msg) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingXl),
              child: Text(
                msg,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: AppColors.error,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ManagersTable extends StatelessWidget {
  const _ManagersTable({required this.managers});

  final List<UserModel> managers;

  @override
  Widget build(BuildContext context) {
    if (managers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingXxl),
          child: Text(
            context.l10n.managersEmpty,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        side: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      child: ListView.builder(
        itemCount: managers.length,
        itemBuilder: (context, i) {
          final m = managers[i];
          final currentUserId = context
              .read<AuthCubit>()
              .state
              .maybeWhen(authenticated: (u) => u.id, orElse: () => null);
          return _ManagerListTile(
            manager: m,
            currentUserId: currentUserId,
          );
        },
      ),
    );
  }
}

class _ManagerListTile extends StatelessWidget {
  const _ManagerListTile({
    required this.manager,
    required this.currentUserId,
  });

  final UserModel manager;
  final String? currentUserId;

  Color _roleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppColors.blue600;
      case 'user':
        return AppColors.success;
      default:
        return AppColors.categoryTools;
    }
  }

  Future<void> _onDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.deleteManagerConfirmTitle),
        content: Text(
          context.l10n.deleteManagerConfirmMessage(manager.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(context.l10n.deleteManagerButton),
          ),
        ],
      ),
    );
    if (!context.mounted || confirmed != true) return;
    final success = await context.read<ManagersCubit>().deleteManager(manager.id);
    if (!context.mounted) return;
    if (success) {
      context.read<ManagersCubit>().loadManagers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.deleteManagerSuccess),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.deleteManagerError),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canDelete = currentUserId != null && currentUserId != manager.id;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _roleColor(manager.role).withValues(alpha: 0.2),
        child: Text(
          manager.name.isNotEmpty ? manager.name[0].toUpperCase() : '?',
          style: TextStyle(
            color: _roleColor(manager.role),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      title: Text(
        manager.name,
        style: context.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        manager.email,
        style: context.textTheme.bodySmall?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMd,
              vertical: AppDimensions.spacingXs,
            ),
            decoration: BoxDecoration(
              color: _roleColor(manager.role).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            ),
            child: Text(
              manager.role,
              style: context.textTheme.labelSmall?.copyWith(
                color: _roleColor(manager.role),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (canDelete) ...[
            const SizedBox(width: AppDimensions.spacingSm),
            TextButton.icon(
              onPressed: () => _onDelete(context),
              icon: Icon(Icons.delete_outline, size: 18, color: AppColors.error),
              label: Text(
                context.l10n.deleteManagerButton,
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
