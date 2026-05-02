import 'package:flutter/material.dart';

import 'package:nesab_dashboard/core/theme/app_colors.dart';

/// SAMA financial policy info dialog.
/// Matches the SAMA dialog content from the HTML bank fees page.
class SamaInfoDialog extends StatelessWidget {
  const SamaInfoDialog({super.key});

  static void show(BuildContext context) {
    showDialog(context: context, builder: (_) => const SamaInfoDialog());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.calcCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.calcBorder2),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'سياسات ساما — نسب الاستقطاع',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.calcNeon,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, color: AppColors.calcMuted, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _section('الموظف بدون تمويل عقاري', [
                    'تمويل شخصي: 33.33%',
                    'تمويل تأجيري: 45%',
                  ]),
                  _section('الموظف مع تمويل عقاري', [
                    'رواتب أقل من 15,000 ريال: 55%',
                    'رواتب 15,000 فأكثر: 65%',
                  ]),
                  _section('المتقاعد', [
                    'بدون عقاري: 25%',
                    'مع عقاري: 55%',
                  ]),
                  _section('الحد الأدنى للراتب', [
                    'القطاع الحكومي: 3,000 ريال',
                    'القطاع الخاص: 5,000 ريال',
                  ]),
                  _section('الرسوم الإدارية', [
                    '1% من مبلغ التمويل',
                    'بحد أقصى 5,000 ريال + ضريبة 15%',
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.calcNeon.withValues(alpha: 0.04),
          border: Border.all(color: AppColors.calcBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.calcText,
              ),
            ),
            const SizedBox(height: 6),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  children: [
                    const Text('• ', style: TextStyle(color: AppColors.calcNeon, fontSize: 12)),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 12, color: AppColors.calcMuted),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
