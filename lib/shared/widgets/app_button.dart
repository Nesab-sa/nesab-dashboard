import 'package:flutter/material.dart';

import 'package:nesab/core/theme/app_colors.dart';
import 'package:nesab/core/theme/app_dimensions.dart';

/// Supported visual variants for [AppButton].
enum AppButtonVariant { primary, secondary, outlined, text }

/// A versatile button supporting multiple variants, loading state,
/// full-width expansion, and an optional leading icon.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isExpanded = false,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isExpanded;
  final IconData? icon;

  static const _minSize = Size(0, AppDimensions.buttonHeightMd);

  @override
  Widget build(BuildContext context) {
    final child = _child(Theme.of(context));
    final onTap = isLoading ? null : onPressed;
    final hasIcon = icon != null && !isLoading;
    final iconW = Icon(icon, size: AppDimensions.iconMd);

    final button = switch (variant) {
      AppButtonVariant.primary => _elevated(
        AppColors.primary,
        Colors.white,
        onTap,
        child,
        hasIcon,
        iconW,
      ),
      AppButtonVariant.secondary => _elevated(
        AppColors.accent,
        Colors.white,
        onTap,
        child,
        hasIcon,
        iconW,
      ),
      AppButtonVariant.outlined => _outlined(onTap, child, hasIcon, iconW),
      AppButtonVariant.text => _text(onTap, child, hasIcon, iconW),
    };

    if (!isExpanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }

  Widget _elevated(
    Color bg,
    Color fg,
    VoidCallback? onTap,
    Widget child,
    bool hasIcon,
    Icon iconW,
  ) {
    final s = ElevatedButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: fg,
      minimumSize: _minSize,
    );
    return hasIcon
        ? ElevatedButton.icon(
            onPressed: onTap,
            style: s,
            icon: iconW,
            label: child,
          )
        : ElevatedButton(onPressed: onTap, style: s, child: child);
  }

  Widget _outlined(
    VoidCallback? onTap,
    Widget child,
    bool hasIcon,
    Icon iconW,
  ) {
    final s = OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary),
      minimumSize: _minSize,
    );
    return hasIcon
        ? OutlinedButton.icon(
            onPressed: onTap,
            style: s,
            icon: iconW,
            label: child,
          )
        : OutlinedButton(onPressed: onTap, style: s, child: child);
  }

  Widget _text(VoidCallback? onTap, Widget child, bool hasIcon, Icon iconW) {
    final s = TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      minimumSize: _minSize,
    );
    return hasIcon
        ? TextButton.icon(onPressed: onTap, style: s, icon: iconW, label: child)
        : TextButton(onPressed: onTap, style: s, child: child);
  }

  Widget _child(ThemeData theme) {
    if (!isLoading) return Text(label);
    return SizedBox(
      height: AppDimensions.iconMd,
      width: AppDimensions.iconMd,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: theme.colorScheme.onPrimary,
      ),
    );
  }
}
