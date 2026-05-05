import 'package:flutter/material.dart';
import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/shared/widgets/glass.dart';

Future<T?> showGlassDialog<T>({
  required BuildContext context,
  required Widget Function(BuildContext dialogContext) builder,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 350),
    transitionBuilder: (_, animation, _, child) {
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
    pageBuilder: (dialogContext, _, _) => Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppDimensions.spacingLg,
        ),
        child: Material(
          color: Colors.transparent,
          child: GlassEffect(child: builder(dialogContext)),
        ),
      ),
    ),
  );
}
