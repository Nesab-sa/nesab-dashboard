import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:nesab_dashboard/core/constants/app_assets.dart';
import 'package:nesab_dashboard/core/extensions/context_extensions.dart';
import 'package:nesab_dashboard/core/localization/cubit/locale_cubit.dart';
import 'package:nesab_dashboard/core/localization/cubit/locale_state.dart';
import 'package:nesab_dashboard/core/theme/cubit/theme_cubit.dart';
import 'package:nesab_dashboard/core/theme/app_dimensions.dart';
import 'package:nesab_dashboard/core/utils/app_validators.dart';
import 'package:nesab_dashboard/core/routing/route_names.dart';
import 'package:nesab_dashboard/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:nesab_dashboard/features/auth/presentation/cubit/auth_state.dart';
import 'package:nesab_dashboard/shared/widgets/app_image.dart';
import 'package:nesab_dashboard/shared/widgets/app_loading.dart';
import 'package:nesab_dashboard/shared/widgets/custom_button.dart';
import 'package:nesab_dashboard/shared/widgets/glass.dart';

class AdminLoginPage extends StatelessWidget {
  const AdminLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AdminLoginView();
  }
}

class _AdminLoginView extends StatefulWidget {
  const _AdminLoginView();

  @override
  State<_AdminLoginView> createState() => _AdminLoginViewState();
}

class _AdminLoginViewState extends State<_AdminLoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
      default:
        return context.l10n.validationFieldRequired;
    }
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          BlocBuilder<LocaleCubit, LocaleState>(
            builder: (context, localeState) {
              final isArabic = localeState.locale.languageCode == 'ar';
              return IconButton(
                icon: const Icon(Icons.language),
                onPressed: () {
                  context.read<LocaleCubit>().setLocale(
                    isArabic ? const Locale('en') : const Locale('ar'),
                  );
                },
                tooltip: context.l10n.language,
              );
            },
          ),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => context.read<ThemeCubit>().toggleTheme(),
            tooltip: context.l10n.themeMode,
          ),
        ],
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          state.whenOrNull(
            authenticated: (_) => context.go(RouteNames.dashboardPath),
            error: (msg) => context.scaffoldMessenger.showSnackBar(
              SnackBar(content: Text(msg)),
            ),
          );
        },
        builder: (context, state) {
          return state.when(
            initial: () => _content(context),
            loading: () => const AppLoading(),
            authenticated: (_) => _content(context),
            unauthenticated: () => _content(context),
            error: (_) => _content(context),
          );
        },
      ),
    );
  }

  SafeArea _content(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spacingXxl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Form(
      key: _formKey,
      child: GlassEffect(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: AppDimensions.spacingXxl),
            _buildLogo(context),
            const SizedBox(height: AppDimensions.spacingXxl),
            _buildTitle(context),
            const SizedBox(height: AppDimensions.spacingXxxl),
            _buildForm(context),
            const SizedBox(height: AppDimensions.spacingXxl),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return AppImage(
      path: AppAssets.logo,
      width: 150,
      height: 150,
      fit: BoxFit.contain,
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Column(
      children: [
        Text(
          context.l10n.adminLoginTitle,
          style: context.textTheme.headlineMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        Text(
          context.l10n.adminLoginSubtitle,
          style: context.textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: context.l10n.emailLabel,
            hintText: context.l10n.emailHint,
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          validator: (v) => _mapValidationKey(AppValidators.email(v)),
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingLg,
              vertical: AppDimensions.spacingMd,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (v) => _mapValidationKey(AppValidators.password(v)),
        ),
        const SizedBox(height: AppDimensions.spacingXxl),
        BlocBuilder<AuthCubit, AuthState>(
          buildWhen: (p, c) =>
              p.maybeWhen(loading: () => true, orElse: () => false) !=
              c.maybeWhen(loading: () => true, orElse: () => false),
          builder: (context, state) {
            final isLoading = state.maybeWhen(
              loading: () => true,
              orElse: () => false,
            );
            return CustomButton(
              onPressed: isLoading ? null : _onSubmit,
              text: context.l10n.loginButton,
              isLoading: isLoading,
            );
          },
        ),
      ],
    );
  }
}
