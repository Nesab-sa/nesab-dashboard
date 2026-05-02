import 'package:flutter/material.dart';

import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/ai_chat_widget.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_footer.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_header.dart';

/// Full-page scaffold for calculator pages matching the HTML layout.
/// Provides background, gradient overlay, header, footer, and floating AI chat.
class CalculatorNeonScaffold extends StatelessWidget {
  const CalculatorNeonScaffold({
    super.key,
    required this.subtitle,
    required this.body,
    this.aiContextBuilder,
    this.showAiChat = true,
  });

  final String subtitle;
  final Widget body;
  final String Function()? aiContextBuilder;
  final bool showAiChat;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        color: AppColors.calcBg,
        child: Stack(
          children: [
            // Gradient overlay
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.4, -1),
                      radius: 1.2,
                      colors: [
                        AppColors.calcNeon2.withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Content
            SafeArea(
              child: Column(
                children: [
                  CalculatorHeader(subtitle: subtitle),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 820),
                            child: body,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const CalculatorFooter(),
                ],
              ),
            ),
            // Floating AI chat
            if (showAiChat)
              AiChatWidget(contextBuilder: aiContextBuilder),
          ],
        ),
      ),
    );
  }
}

/// A card container matching the HTML `.card` class.
class CalculatorNeonCard extends StatelessWidget {
  const CalculatorNeonCard({
    super.key,
    required this.children,
    this.isResult = false,
  });

  final List<Widget> children;
  final bool isResult;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isResult ? AppColors.calcCard2 : AppColors.calcCard,
        border: Border.all(color: AppColors.calcBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// Neon gradient calculate button matching the HTML calculate button.
class CalculatorNeonButton extends StatelessWidget {
  const CalculatorNeonButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.calcNeon2, AppColors.calcNeon],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

/// Back button matching HTML `.btn-back` for navigating from result to input.
class CalculatorBackButton extends StatelessWidget {
  const CalculatorBackButton({
    super.key,
    required this.onTap,
    this.label = 'العودة للبيانات',
  });

  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.calcNeon2.withValues(alpha: 0.15),
          border: Border.all(color: AppColors.calcBorder2),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('←', style: TextStyle(color: AppColors.calcNeon, fontSize: 14)),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.calcNeon,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
