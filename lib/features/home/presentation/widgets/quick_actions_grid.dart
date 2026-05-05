import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nesab/core/extensions/context_extensions.dart';
import 'package:nesab/core/routing/route_names.dart';
import 'package:nesab/core/theme/app_colors.dart';
import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/core/theme/app_text_styles.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  List<_QuickAction> _actions(BuildContext context) => [
    _QuickAction(
      '📦',
      context.l10n.quickActionProducts,
      RouteNames.productsPath,
    ),
    _QuickAction(
      '📋',
      context.l10n.quickActionRequests,
      RouteNames.myRequestsPath,
    ),
    _QuickAction('💬', 'تواصل', RouteNames.contactPath),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _actions(context)
          .map(
            (action) => Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppDimensions.spacingXs + 2,
                ),
                child: _QuickActionCard(action: action),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _QuickAction {
  const _QuickAction(this.emoji, this.label, this.route);
  final String emoji;
  final String label;
  final String route;
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.action});
  final _QuickAction action;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(action.route),
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
          vertical: 18,
          horizontal: AppDimensions.spacingSm,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(action.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              action.label,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
