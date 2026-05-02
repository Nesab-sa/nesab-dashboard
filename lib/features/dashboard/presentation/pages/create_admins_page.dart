import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nesab_dashboard/core/theme/app_dimensions.dart';
import 'package:nesab_dashboard/features/dashboard/data/repositories/create_admin_repository.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/cubit/create_admins_cubit.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/widgets/create_manager_form.dart';

/// Standalone page for creating managers. Use [ManagersPage] for list + create flow.
class CreateAdminsPage extends StatelessWidget {
  const CreateAdminsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateAdminsCubit(CreateAdminRepository()),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXxl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: const CreateManagerForm(),
          ),
        ),
      ),
    );
  }
}
