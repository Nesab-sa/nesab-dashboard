import 'package:flutter/material.dart';

import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_neon_scaffold.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/result_section_header.dart';

/// Bank fees info page matching `alrusum-albankiya.html`.
/// Info-only page — no calculator, just SAMA fee tables + AI chat.
class BankFeesPage extends StatelessWidget {
  const BankFeesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CalculatorNeonScaffold(
      subtitle: 'الرسوم البنكية — مقارنة السابقة والمحدثة',
      aiContextBuilder: () => 'الرسوم البنكية ساما',
      body: Column(
        children: [
          // Note box
          _noteBox(
            'الرسوم وفق دليل تعرفة خدمات المؤسسات المالية الصادر من ساما — الأسعار غير شاملة ضريبة القيمة المضافة (VAT 15%) إلا إذا نُص عليها',
          ),
          const SizedBox(height: 14),
          // Financing fees
          const ResultSectionHeader(title: 'الرسوم الإدارية للتمويل', icon: '💳'),
          _feeCard([
            _FeeRow('التمويل الشخصي والتأجيري والإيجاري', '1% | أقصى 5,000', '0.5% | أقصى 2,500', isUpdated: true),
            _FeeRow('التمويل العقاري', '1% | أقصى 5,000', '1% | أقصى 5,000'),
          ], hasCompare: true, header: 'رسوم التمويل الإدارية'),
          const SizedBox(height: 14),
          _feeCard([
            _FeeRow('إعادة إصدار بطاقة (مفقودة/تالفة)', '30 ر', '10 ر', isUpdated: true),
            _FeeRow('إصدار بطاقة مدى إضافية', '-', '2% من مبلغ العملية'),
            _FeeRow('الاعتراض الخاطئ على العمليات', '25 ر', '15 ر', isUpdated: true),
          ], hasCompare: true, header: 'بطاقة مدى'),
          const SizedBox(height: 20),
          // Basic banking services
          const ResultSectionHeader(title: 'الخدمات البنكية الأساسية', icon: '🏦'),
          _serviceTable([
            _ServiceRow('فتح حساب جاري أساسي', 'مجاناً', 'مجاناً'),
            _ServiceRow('كشف حساب أقل من سنة', 'مجاناً', '25 ر'),
            _ServiceRow('كشف حساب من سنة إلى خمس سنوات', 'مجاناً', '30 ر'),
            _ServiceRow('كشف حساب أكثر من خمس سنوات', 'مجاناً', '50 ر'),
            _ServiceRow('السحب النقدي والإيداع', 'مجاناً', 'مجاناً'),
            _ServiceRow('إصدار شيك مصرفي', '10 ر', '10 ر'),
            _ServiceRow('إلغاء شيك مصرفي', '10 ر', '10 ر'),
            _ServiceRow('إصدار دفتر شيكات (25 شيك)', '10 ر', '10 ر'),
          ]),
          const SizedBox(height: 20),
          // Transfers
          const ResultSectionHeader(title: 'الحوالات المالية', icon: '💸'),
          _serviceTable([
            _ServiceRow('تحويل داخل البنك', 'مجاناً', 'مجاناً'),
            _ServiceRow('تحويل آني (≤500 ر) — فوري', 'أقصى 0.5 ر', 'أقصى 0.5 ر'),
            _ServiceRow('تحويل آني (>500 ر) — فوري', 'أقصى 1 ر', 'أقصى 1 ر'),
            _ServiceRow('تحويل سريع (نفس اليوم)', '7 ر', '25 ر'),
            _ServiceRow('تحويل سريع (آجل)', '5 ر', '15 ر'),
            _ServiceRow('تحويل لخارج المملكة', '5 ر', '75 ر'),
          ]),
          const SizedBox(height: 20),
          // Official documents
          const ResultSectionHeader(title: 'الوثائق الرسمية', icon: '📋'),
          _serviceTable([
            _ServiceRow('إصدار وثيقة إثبات مديونية (المرة الأولى)', 'مجاناً', 'مجاناً'),
            _ServiceRow('إصدار وثيقة إثبات مديونية (إضافي)', 'مجاناً', '25 ر'),
            _ServiceRow('إصدار كشف حساب دوري (أقل من سنة)', 'مجاناً', 'مجاناً'),
            _ServiceRow('إصدار كشف حساب دوري (أكثر من سنة)', '15 ر', 'من 30 لـ 50 ر'),
            _ServiceRow('تأسيس أمر مستديم', 'مجاناً', '15 ر'),
            _ServiceRow('إلغاء أمر مستديم', 'مجاناً', 'مجاناً'),
          ]),
          const SizedBox(height: 20),
          // Disclaimer
          _noteBox(
            'تنبيهات مهمة:\n'
            '• جميع الرسوم أعلاه غير شاملة ضريبة القيمة المضافة 15%\n'
            '• هذا الملف للاسترشاد فقط — يرجى التحقق من موقع ساما الرسمي (sama.gov.sa)\n'
            '• تسري التعليمات خلال 60 يوماً من تاريخ نشرها',
          ),
        ],
      ),
    );
  }

  Widget _noteBox(String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.calcNeon.withValues(alpha: 0.06),
        border: Border.all(color: AppColors.calcNeon.withValues(alpha: 0.18)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.calcText,
          height: 1.8,
        ),
      ),
    );
  }

  Widget _feeCard(List<_FeeRow> rows, {bool hasCompare = false, String? header}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.calcCard,
        border: Border.all(color: AppColors.calcBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if (header != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: AppColors.calcCard2,
              child: Text(
                header,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.calcNeon,
                ),
              ),
            ),
          for (final row in rows)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.calcBorder)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.service,
                    style: const TextStyle(fontSize: 12, color: AppColors.calcText),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            if (hasCompare)
                              const Text('السابق', style: TextStyle(fontSize: 10, color: AppColors.calcMuted)),
                            Text(row.oldValue, style: const TextStyle(fontSize: 12, color: AppColors.calcMuted)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            if (hasCompare)
                              const Text('المحدّث', style: TextStyle(fontSize: 10, color: AppColors.calcMuted)),
                            Container(
                              padding: row.isUpdated
                                  ? const EdgeInsets.symmetric(horizontal: 8, vertical: 2)
                                  : null,
                              decoration: row.isUpdated
                                  ? BoxDecoration(
                                      color: AppColors.calcGreen.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    )
                                  : null,
                              child: Text(
                                row.newValue,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: row.isUpdated ? AppColors.calcGreen : AppColors.calcText,
                                  fontWeight: row.isUpdated ? FontWeight.w700 : FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _serviceTable(List<_ServiceRow> rows) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.calcCard,
        border: Border.all(color: AppColors.calcBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: AppColors.calcCard2,
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text('الخدمة', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.calcNeon)),
                ),
                SizedBox(
                  width: 80,
                  child: Text('إلكتروني', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.calcNeon)),
                ),
                SizedBox(
                  width: 80,
                  child: Text('الفرع', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.calcNeon)),
                ),
              ],
            ),
          ),
          for (final row in rows)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.calcBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(row.service, style: const TextStyle(fontSize: 12, color: AppColors.calcText)),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      row.electronic,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: row.electronic == 'مجاناً' ? AppColors.calcGreen : AppColors.calcText,
                        fontWeight: row.electronic == 'مجاناً' ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      row.branch,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: row.branch == 'مجاناً' ? AppColors.calcGreen : AppColors.calcText,
                        fontWeight: row.branch == 'مجاناً' ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _FeeRow {
  const _FeeRow(this.service, this.oldValue, this.newValue, {this.isUpdated = false});
  final String service;
  final String oldValue;
  final String newValue;
  final bool isUpdated;
}

class _ServiceRow {
  const _ServiceRow(this.service, this.electronic, this.branch);
  final String service;
  final String electronic;
  final String branch;
}
