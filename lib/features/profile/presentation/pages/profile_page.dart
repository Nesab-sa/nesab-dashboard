import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:nesab/features/auth/presentation/cubit/auth_state.dart';
import 'package:nesab/features/profile/presentation/dialogs/about_app_dialog.dart';
import 'package:nesab/features/profile/presentation/dialogs/about_developer_dialog.dart';
import 'package:nesab/features/profile/presentation/dialogs/change_password_dialog.dart';
import 'package:nesab/features/profile/presentation/dialogs/delete_account_dialog.dart';
import 'package:nesab/features/profile/presentation/dialogs/edit_details_dialog.dart';
import 'package:nesab/features/profile/presentation/dialogs/language_picker_dialog.dart';
import 'package:nesab/features/profile/presentation/dialogs/logout_dialog.dart';
import 'package:nesab/features/profile/presentation/dialogs/theme_picker_dialog.dart';
import 'package:nesab/features/profile/presentation/dialogs/upload_signature_dialog.dart';
import 'package:nesab/features/profile/presentation/widgets/profile_back_button.dart';
import 'package:nesab/features/profile/presentation/widgets/profile_header.dart';
import 'package:nesab/features/profile/presentation/widgets/settings_section.dart';
import 'package:nesab/shared/widgets/gradiant_widget.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned(child: GradiantWidget(width: double.infinity)),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              return state.maybeWhen(
                authenticated: (user) => SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: AppDimensions.screenPaddingHorizontal,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: AppDimensions.spacingMd),
                        const ProfileBackButton(),
                        const SizedBox(height: AppDimensions.spacingMd),
                        ProfileHeader(user: user),
                        SettingsSection(
                          user: user,
                          onEditDetails: () =>
                              showEditDetailsDialog(context, user),
                          onThemePicker: () => showThemePickerDialog(context),
                          onLanguagePicker: () =>
                              showLanguagePickerDialog(context),
                          onLogout: () => showLogoutDialog(context),
                          onDeleteAccount: () =>
                              showDeleteAccountDialog(context),
                          onAboutDeveloper: () =>
                              showAboutDeveloperDialog(context),
                          onAboutApp: () => showAboutAppDialog(context),
                          onChangePassword: () =>
                              showChangePasswordDialog(context),
                          onUploadSignature: () =>
                              showUploadSignatureDialog(context),
                        ),
                        const SizedBox(height: AppDimensions.spacingXxxl),
                        const SizedBox(height: AppDimensions.spacingXl),
                      ],
                    ),
                  ),
                ),
                initial: () => const Center(child: CircularProgressIndicator()),
                loading: () => const Center(child: CircularProgressIndicator()),
                orElse: () => const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
    );
  }
}
