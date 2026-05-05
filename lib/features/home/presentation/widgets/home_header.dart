import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nesab/core/constants/app_assets.dart';
import 'package:nesab/core/extensions/context_extensions.dart';
import 'package:nesab/core/routing/route_names.dart';
import 'package:nesab/core/theme/cubit/theme_cubit.dart';
import 'package:nesab/core/theme/cubit/theme_state.dart';
import 'package:nesab/core/utils/app_responsive.dart';
import 'package:nesab/features/auth/domain/entities/user_entity.dart';
import 'package:nesab/shared/widgets/app_image.dart';
import 'package:nesab/shared/widgets/glass_card.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Theme toggle with glass card
        BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, state) {
            final icon = switch (state.themeMode) {
              ThemeMode.light => Icons.light_mode_rounded,
              ThemeMode.dark => Icons.dark_mode_rounded,
              ThemeMode.system => Icons.brightness_auto_rounded,
            };

            return GlassCard(
              radius: 100,
              width: 40,
              height: 40,
              alignment: Alignment.center,
              onTap: () => context.read<ThemeCubit>().toggleTheme(),
              child: Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            );
          },
        ),

        // App logo centered
        Expanded(
          child: Center(
            child: AppImage(
              colorBlendMode: BlendMode.srcIn,
              path: context.isDark
                  ? AppAssets.headerLogoDark
                  : AppAssets.headerLogoLight,

              height: 40,
              width: AppResponsive.numberOfGrid(context) * 45,
            ),
          ),
        ),

        // Settings button with glass card
        GlassCard(
          radius: 100,
          width: 40,
          height: 40,
          alignment: Alignment.center,
          onTap: () => context.push(RouteNames.profilePath),
          child: Icon(
            Icons.settings_rounded,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
