import 'package:flutter/material.dart';

/// A tool/calculator item managed from the dashboard.
/// Built-in tools correspond to CalculatorType values.
/// Custom tools are user-created with isBuiltIn = false.
class ToolItem {
  final String id;
  final String nameAr;
  final String nameEn;
  final String imageUrl;
  final String description;
  final String link;
  final bool isActive;
  final int order;
  final bool isBuiltIn;

  const ToolItem({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.imageUrl = '',
    this.description = '',
    this.link = '',
    this.isActive = true,
    this.order = 0,
    this.isBuiltIn = false,
  });

  ToolItem copyWith({
    String? nameAr,
    String? nameEn,
    String? imageUrl,
    String? description,
    String? link,
    bool? isActive,
    int? order,
  }) =>
      ToolItem(
        id: id,
        nameAr: nameAr ?? this.nameAr,
        nameEn: nameEn ?? this.nameEn,
        imageUrl: imageUrl ?? this.imageUrl,
        description: description ?? this.description,
        link: link ?? this.link,
        isActive: isActive ?? this.isActive,
        order: order ?? this.order,
        isBuiltIn: isBuiltIn,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'nameAr': nameAr,
        'nameEn': nameEn,
        'imageUrl': imageUrl,
        'description': description,
        'link': link,
        'isActive': isActive,
        'order': order,
        'isBuiltIn': isBuiltIn,
      };

  factory ToolItem.fromMap(Map<String, dynamic> d) => ToolItem(
        id: d['id']?.toString() ?? '',
        nameAr: d['nameAr']?.toString() ?? '',
        nameEn: d['nameEn']?.toString() ?? '',
        imageUrl: d['imageUrl']?.toString() ?? '',
        description: d['description']?.toString() ?? '',
        link: d['link']?.toString() ?? '',
        isActive: d['isActive'] as bool? ?? true,
        order: d['order'] as int? ?? 99,
        isBuiltIn: d['isBuiltIn'] as bool? ?? false,
      );
}

/// Default built-in tools matching CalculatorType enum
List<ToolItem> defaultBuiltInTools() => [
      const ToolItem(id: 'personal_finance',       nameAr: 'التمويل الشخصي',           nameEn: 'Personal Finance (PLAS)', isBuiltIn: true, order: 0),
      const ToolItem(id: 'personal_finance_quick',  nameAr: 'التمويل الشخصي المختصر',    nameEn: 'Quick Personal Finance',  isBuiltIn: true, order: 1),
      const ToolItem(id: 'debt_purchase',           nameAr: 'شراء مديونية',              nameEn: 'Debt Purchase',           isBuiltIn: true, order: 2),
      const ToolItem(id: 'real_estate',             nameAr: 'التمويل العقاري',           nameEn: 'Real Estate',             isBuiltIn: true, order: 3),
      const ToolItem(id: 'real_estate_plus',        nameAr: 'التمويل العقاري بلص',       nameEn: 'Real Estate Plus',        isBuiltIn: true, order: 4),
      const ToolItem(id: 'leasing_regular',         nameAr: 'التأجيري (تاجيري)',         nameEn: 'Leasing (Tajiri)',        isBuiltIn: true, order: 5),
      const ToolItem(id: 'leasing_micro',           nameAr: 'التأجيري مايكرو',           nameEn: 'Leasing Micro',           isBuiltIn: true, order: 6),
      const ToolItem(id: 'pos_financing',           nameAr: 'تمويل نقاط البيع',          nameEn: 'POS Financing',           isBuiltIn: true, order: 7),
      const ToolItem(id: 'khairat',                 nameAr: 'حساب خيرات الادخاري',       nameEn: 'Khairat Savings',         isBuiltIn: true, order: 8),
      const ToolItem(id: 'protection_savings',      nameAr: 'الحماية والادخار',          nameEn: 'Protection & Savings',    isBuiltIn: true, order: 9),
      const ToolItem(id: 'age_calculator',          nameAr: 'حاسبة العمر',               nameEn: 'Age Calculator',          isBuiltIn: true, order: 10),
      const ToolItem(id: 'date_converter',          nameAr: 'تحويل التاريخ',             nameEn: 'Date Converter',          isBuiltIn: true, order: 11),
      const ToolItem(id: 'deductions',              nameAr: 'حاسبة الاستقطاعات',         nameEn: 'Deductions Calculator',   isBuiltIn: true, order: 12),
      const ToolItem(id: 'bank_fees',               nameAr: 'الرسوم البنكية',            nameEn: 'Bank Fees',               isBuiltIn: true, order: 13),
    ];

/// Fallback icon per tool id
IconData toolIcon(String id) {
  switch (id) {
    case 'personal_finance':
    case 'personal_finance_quick': return Icons.person_rounded;
    case 'debt_purchase':          return Icons.swap_horiz_rounded;
    case 'real_estate':
    case 'real_estate_plus':       return Icons.home_work_rounded;
    case 'leasing_regular':
    case 'leasing_micro':          return Icons.directions_car_rounded;
    case 'pos_financing':          return Icons.point_of_sale_rounded;
    case 'khairat':                return Icons.savings_rounded;
    case 'protection_savings':     return Icons.security_rounded;
    case 'age_calculator':         return Icons.cake_rounded;
    case 'date_converter':         return Icons.calendar_today_rounded;
    case 'deductions':             return Icons.calculate_rounded;
    case 'bank_fees':              return Icons.account_balance_rounded;
    default:                       return Icons.build_rounded;
  }
}
