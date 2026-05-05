import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nesab/core/theme/cubit/theme_cubit.dart';
import 'package:nesab/core/theme/cubit/theme_state.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final icon = switch (state.themeMode) {
          ThemeMode.light => Icons.light_mode_rounded,
          ThemeMode.dark => Icons.dark_mode_rounded,
          ThemeMode.system => Icons.brightness_auto_rounded,
        };

        return IconButton(
          onPressed: () => context.read<ThemeCubit>().toggleTheme(),
          icon: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
        );
      },
    );
  }
}
