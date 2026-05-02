import 'package:flutter/material.dart';

import 'package:nesab_dashboard/core/theme/app_dimensions.dart';

/// A reusable back button with an Apple-style chevron icon inside a
/// rounded-rectangle container.
///
/// Adapts to light/dark theme automatically via [Theme]. Supports an
/// optional custom [onPressed] callback; defaults to [Navigator.maybePop].
class AppBackButton extends StatelessWidget {
  const AppBackButton({this.onPressed, super.key});

  final VoidCallback? onPressed;

  static const _size = 40.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: _size,
      height: _size,
      child: Material(
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          side: BorderSide(color: colorScheme.outline),
        ),
        child: InkWell(
          onTap: onPressed ?? () => Navigator.maybePop(context),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: AppDimensions.iconSm,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
