import 'package:flutter/material.dart';

import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/core/theme/app_text_styles.dart';

/// A full-width button used for social login providers (Google, Apple).
///
/// Renders a rounded button with a leading [iconWidget] or [icon] and a [label].
/// Supports custom [backgroundColor] and [foregroundColor] for different providers.
class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    required this.label,
    this.icon,
    this.iconWidget,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    super.key,
  });

  final String label;
  final IconData? icon;
  final Widget? iconWidget;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = backgroundColor;
    final fg = foregroundColor ?? theme.colorScheme.onSurface;
    final isOutlined = bg == null;

    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeightLg,
      child: isOutlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: fg,
                side: BorderSide(
                  color: theme.colorScheme.outline,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusNav,
                  ),
                ),
              ),
              child: _buildContent(fg),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: bg,
                foregroundColor: fg,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusNav,
                  ),
                ),
              ),
              child: _buildContent(fg),
            ),
    );
  }

  Widget _buildContent(Color fg) {
    return Row(
      children: [
        if (iconWidget != null) iconWidget!
        else if (icon != null) Icon(icon, size: AppDimensions.iconLg),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.buttonLarge.copyWith(
              fontSize: 15,
              color: fg,
            ),
          ),
        ),
      ],
    );
  }
}
