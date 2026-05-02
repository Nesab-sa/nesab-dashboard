import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nesab_dashboard/core/localization/cubit/locale_cubit.dart';
import 'package:nesab_dashboard/core/localization/cubit/locale_state.dart';
import 'package:nesab_dashboard/core/localization/generated/app_localizations.dart';
import 'package:nesab_dashboard/core/routing/app_router.dart';
import 'package:nesab_dashboard/core/routing/auth_redirect_notifier.dart';
import 'package:nesab_dashboard/core/theme/app_theme.dart';
import 'package:nesab_dashboard/core/theme/cubit/theme_cubit.dart';
import 'package:nesab_dashboard/core/theme/cubit/theme_state.dart';
import 'package:nesab_dashboard/features/auth/data/repositories/auth_repository.dart';
import 'package:nesab_dashboard/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:nesab_dashboard/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();

  final authNotifier = AuthRedirectNotifier();
  final authRepo = AuthRepository();
  final authCubit = AuthCubit(
    repository: authRepo,
    redirectNotifier: authNotifier,
  )..checkAuth();

  final router = AppRouter.createRouter(authNotifier);

  runApp(NesabDashboardApp(prefs: prefs, authCubit: authCubit, router: router));
}

class NesabDashboardApp extends StatelessWidget {
  const NesabDashboardApp({
    super.key,
    required this.prefs,
    required this.authCubit,
    required this.router,
  });

  final SharedPreferences prefs;
  final AuthCubit authCubit;
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: authCubit,
      child: BlocProvider(
        create: (_) => ThemeCubit(prefs)..loadTheme(),
        child: BlocProvider(
          create: (_) => LocaleCubit(prefs)..loadLocale(),
          child: BlocBuilder<ThemeCubit, ThemeState>(
            buildWhen: (p, c) => p.themeMode != c.themeMode,
            builder: (context, themeState) {
              return BlocBuilder<LocaleCubit, LocaleState>(
                buildWhen: (p, c) => p.locale != c.locale,
                builder: (context, localeState) {
                  return MaterialApp.router(
                    title: 'Nesab Dashboard',
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.light,
                    darkTheme: AppTheme.dark,
                    themeMode: themeState.themeMode,
                    locale: localeState.locale,
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,
                    supportedLocales: AppLocalizations.supportedLocales,
                    routerConfig: router,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
