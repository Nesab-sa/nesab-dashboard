import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nesab/core/localization/generated/app_localizations.dart';
import 'package:nesab/app/dependency_injection.dart';
import 'package:nesab/core/theme/app_theme.dart';
import 'package:nesab/core/theme/cubit/theme_cubit.dart';
import 'package:nesab/core/theme/cubit/theme_state.dart';
import 'package:nesab/core/localization/cubit/locale_cubit.dart';
import 'package:nesab/core/localization/cubit/locale_state.dart';
import 'package:nesab/core/routing/app_router.dart';
import 'package:nesab/features/auth/presentation/cubit/auth_cubit.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ThemeCubit>()..loadTheme()),
        BlocProvider(create: (_) => getIt<LocaleCubit>()..loadLocale()),
        BlocProvider(create: (_) => getIt<AuthCubit>()),

      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LocaleCubit, LocaleState>(
            builder: (context, localeState) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: 'Nesab',
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: themeState.themeMode,
                locale: localeState.locale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                routerConfig: AppRouter.router,
              );
            },
          );
        },
      ),
    );
  }
}
