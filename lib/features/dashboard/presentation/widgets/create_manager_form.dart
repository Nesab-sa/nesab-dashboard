import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:nesab_dashboard/core/extensions/context_extensions.dart';
import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/core/theme/app_dimensions.dart';
import 'package:nesab_dashboard/core/utils/app_validators.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/cubit/create_admins_cubit.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/cubit/create_admins_state.dart';
import 'package:nesab_dashboard/shared/widgets/custom_button.dart';

/// Form to create a new manager. Requires [CreateAdminsCubit] in context.
class CreateManagerForm extends StatefulWidget {
  const CreateManagerForm({super.key, this.onSuccess, this.compact = false});

  final VoidCallback? onSuccess;
  final bool compact;

  @override
  State<CreateManagerForm> createState() => _CreateManagerFormState();
}

class _CreateManagerFormState extends State<CreateManagerForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _obscurePassword = true;
 final String _selectedRole = 'admin';
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  String? _mapValidationKey(String? key) {
    if (key == null) return null;
    switch (key) {
      case 'emailRequired':
        return context.l10n.validationEmailRequired;
      case 'emailInvalid':
        return context.l10n.validationEmailInvalid;
      case 'passwordRequired':
        return context.l10n.validationPasswordRequired;
      case 'passwordTooShort':
        return context.l10n.validationPasswordTooShort;
      case 'nameRequired':
        return context.l10n.validationNameRequired;
      case 'nameTooShort':
        return context.l10n.validationNameTooShort;
      default:
        return context.l10n.validationFieldRequired;
    }
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<CreateAdminsCubit>().createAdmin(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: _displayNameController.text.trim(),
      role: _selectedRole,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateAdminsCubit, CreateAdminsState>(
      listener: (context, state) {
        state.whenOrNull(
          success: () {
            _emailController.clear();
            _passwordController.clear();
            _displayNameController.clear();
            context.read<CreateAdminsCubit>().reset();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.createAdminSuccess),
                backgroundColor: AppColors.success,
              ),
            );
            widget.onSuccess?.call();
          },
          error: (msg) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: AppColors.error),
            );
            context.read<CreateAdminsCubit>().reset();
          },
        );
      },
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          side: BorderSide(color: context.colorScheme.outline),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingXxl),
          child: Form(
            key: _formKey,
            child: BlocBuilder<CreateAdminsCubit, CreateAdminsState>(
              builder: (context, state) {
                final isLoading = state.maybeWhen(
                  loading: () => true,
                  orElse: () => false,
                );
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!widget.compact) ...[
                      Text(
                        context.l10n.createAdminsTitle,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingSm),
                      Text(
                        context.l10n.createAdminsSubtitle,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingLg),
                    ],
                    TextFormField(
                      controller: _displayNameController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: context.l10n.displayNameLabel,
                        hintText: context.l10n.displayNameHint,
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (v) =>
                          _mapValidationKey(AppValidators.name(v)),
                    ),
                    const SizedBox(height: AppDimensions.spacingLg),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: context.l10n.emailLabel,
                        hintText: context.l10n.emailHint,
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      validator: (v) =>
                          _mapValidationKey(AppValidators.email(v)),
                    ),
                    const SizedBox(height: AppDimensions.spacingLg),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _onSubmit(),
                      decoration: InputDecoration(
                        labelText: context.l10n.passwordLabel,
                        hintText: context.l10n.passwordHint,
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      validator: (v) =>
                          _mapValidationKey(AppValidators.password(v)),
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),

                    CustomButton(
                      text: context.l10n.createAdminButton,
                      onPressed: isLoading ? null : _onSubmit,
                      isLoading: isLoading,
                      icon: const FaIcon(
                        FontAwesomeIcons.userPlus,
                        size: AppDimensions.iconMd,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
