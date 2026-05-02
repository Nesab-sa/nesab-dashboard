import 'package:flutter/material.dart';

import 'package:nesab_dashboard/core/theme/app_colors.dart';

/// Shared header widget matching the HTML `.hdr` section.
/// Used by all calculator pages: logo, title, subtitle, update badge.
class CalculatorHeader extends StatelessWidget {
  const CalculatorHeader({
    super.key,
    required this.subtitle,
    this.updateDate = 'مارس 2026',
  });

  final String subtitle;
  final String updateDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.calcHeaderTop, AppColors.calcBg],
        ),
        border: Border(bottom: BorderSide(color: AppColors.calcBorder2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 500;
          return Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/logo.png', height: isNarrow ? 38 : 52),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (b) => const LinearGradient(
                          colors: [AppColors.calcNeon, AppColors.calcNeon2],
                        ).createShader(b),
                        child: const Text(
                          'نسب',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 12, color: AppColors.calcMuted),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'www.Nesab.sa',
                    style: TextStyle(fontSize: 12, color: AppColors.calcNeon),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 3),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.calcNeon.withValues(alpha: 0.08),
                      border: Border.all(color: AppColors.calcNeon.withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'آخر تحديث: $updateDate',
                      style: const TextStyle(fontSize: 11, color: AppColors.calcNeon),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
