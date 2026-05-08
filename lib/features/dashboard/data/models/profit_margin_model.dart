import 'package:cloud_firestore/cloud_firestore.dart';

/// هامش ربح منتج واحد (أدنى / أقصى / متاح)
class ProductMargin {
  const ProductMargin({
    required this.min,
    required this.max,
    this.available = true,
  });

  final double min;
  final double max;
  final bool available;

  factory ProductMargin.fromMap(Map<String, dynamic> map) => ProductMargin(
        min: (map['min'] as num?)?.toDouble() ?? 0.0,
        max: (map['max'] as num?)?.toDouble() ?? 0.0,
        available: map['available'] as bool? ?? true,
      );

  Map<String, dynamic> toMap() =>
      {'min': min, 'max': max, 'available': available};
}

/// بنك واحد مع كل منتجاته — Map مرن لدعم إضافة منتجات جديدة
class BankProfitMargin {
  const BankProfitMargin({
    required this.bankId,
    required this.bankName,
    required this.products,
    this.notes = '',
  });

  final String bankId;
  final String bankName;

  /// key = معرّف المنتج (مثل: personalBasic, leasingVehicles)
  final Map<String, ProductMargin> products;
  final String notes;

  /// إرجاع هامش منتج بعينه (أو غير متاح إذا لم يوجد)
  ProductMargin product(String key) =>
      products[key] ?? const ProductMargin(min: 0, max: 0, available: false);

  /// نسخة مع تعديل منتج واحد فقط
  BankProfitMargin withProduct(String key, ProductMargin margin) =>
      BankProfitMargin(
        bankId: bankId,
        bankName: bankName,
        products: {...products, key: margin},
        notes: notes,
      );

  BankProfitMargin copyWith({String? bankName, String? notes}) =>
      BankProfitMargin(
        bankId: bankId,
        bankName: bankName ?? this.bankName,
        products: products,
        notes: notes ?? this.notes,
      );

  factory BankProfitMargin.fromMap(Map<String, dynamic> map) {
    final prods = <String, ProductMargin>{};

    // تنسيق جديد: products map
    final rawProds = map['products'];
    if (rawProds is Map) {
      for (final entry in rawProds.entries) {
        if (entry.value is Map) {
          prods[entry.key as String] =
              ProductMargin.fromMap(Map<String, dynamic>.from(entry.value as Map));
        }
      }
    }

    // توافق عكسي مع التنسيق القديم (personal / realEstate / leasing)
    if (prods.isEmpty) {
      void legacyPm(String newKey, String oldKey) {
        if (map.containsKey(oldKey) && map[oldKey] is Map) {
          prods[newKey] =
              ProductMargin.fromMap(Map<String, dynamic>.from(map[oldKey] as Map));
        }
      }

      legacyPm('personalBasic', 'personal');
      legacyPm('realEstateCommercial', 'realEstate');
      legacyPm('leasingVehicles', 'leasing');
    }

    return BankProfitMargin(
      bankId: map['bankId'] as String? ?? '',
      bankName: map['bankName'] as String? ?? '',
      products: prods,
      notes: map['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'bankId': bankId,
        'bankName': bankName,
        'products': products.map((k, v) => MapEntry(k, v.toMap())),
        'notes': notes,
      };
}

/// إعدادات المستند الكامل في Firestore
class ProfitMarginsConfig {
  const ProfitMarginsConfig({
    required this.banks,
    this.lastUpdated,
    this.updatedBy = '',
    this.aiSummary = '',
  });

  final List<BankProfitMargin> banks;
  final DateTime? lastUpdated;
  final String updatedBy;
  final String aiSummary;

  factory ProfitMarginsConfig.fromDoc(Map<String, dynamic> data) {
    final banksList = (data['banks'] as List<dynamic>? ?? [])
        .map((e) => BankProfitMargin.fromMap(e as Map<String, dynamic>))
        .toList();

    DateTime? lastUpdated;
    final ts = data['lastUpdated'];
    if (ts is Timestamp) lastUpdated = ts.toDate();

    return ProfitMarginsConfig(
      banks: banksList,
      lastUpdated: lastUpdated,
      updatedBy: data['updatedBy'] as String? ?? '',
      aiSummary: data['aiSummary'] as String? ?? '',
    );
  }

  static ProfitMarginsConfig defaultConfig() =>
      ProfitMarginsConfig(updatedBy: 'default', banks: List.from(_defaultBanks));
}

// ─────────────────────────────────────────────
// بيانات افتراضية — 11 بنكاً × 8 منتجات
// ─────────────────────────────────────────────
ProductMargin _p(double min, double max) => ProductMargin(min: min, max: max);
const ProductMargin _na = ProductMargin(min: 0, max: 0, available: false);

final _defaultBanks = <BankProfitMargin>[
  BankProfitMargin(
    bankId: 'rajhi',
    bankName: 'بنك الراجحي',
    products: {
      'personalBasic': _p(3.99, 5.50),
      'personalSpecial': _p(3.75, 5.00),
      'realEstateSupportedProgram': _p(3.50, 4.75),
      'realEstateSupportedMinistry': _p(2.50, 3.50),
      'realEstateCommercial': _p(4.00, 5.50),
      'realEstateResident': _p(3.75, 5.00),
      'leasingVehicles': _p(4.00, 6.00),
      'leasingEquipment': _p(4.50, 6.50),
    },
  ),
  BankProfitMargin(
    bankId: 'snb',
    bankName: 'البنك الأهلي السعودي',
    products: {
      'personalBasic': _p(4.00, 5.75),
      'personalSpecial': _p(3.80, 5.25),
      'realEstateSupportedProgram': _p(3.45, 4.90),
      'realEstateSupportedMinistry': _p(2.45, 3.45),
      'realEstateCommercial': _p(4.10, 5.60),
      'realEstateResident': _p(3.85, 5.10),
      'leasingVehicles': _p(4.20, 6.50),
      'leasingEquipment': _p(4.70, 6.80),
    },
  ),
  BankProfitMargin(
    bankId: 'inma',
    bankName: 'بنك الإنماء',
    products: {
      'personalBasic': _p(3.95, 5.60),
      'personalSpecial': _p(3.70, 5.10),
      'realEstateSupportedProgram': _p(3.40, 4.70),
      'realEstateSupportedMinistry': _p(2.40, 3.40),
      'realEstateCommercial': _p(4.05, 5.55),
      'realEstateResident': _p(3.80, 5.05),
      'leasingVehicles': _p(4.10, 6.10),
      'leasingEquipment': _p(4.60, 6.60),
    },
  ),
  BankProfitMargin(
    bankId: 'riyadh',
    bankName: 'بنك الرياض',
    products: {
      'personalBasic': _p(4.05, 5.70),
      'personalSpecial': _p(3.80, 5.20),
      'realEstateSupportedProgram': _p(3.50, 4.80),
      'realEstateSupportedMinistry': _p(2.50, 3.50),
      'realEstateCommercial': _p(4.10, 5.60),
      'realEstateResident': _p(3.85, 5.10),
      'leasingVehicles': _p(4.20, 6.30),
      'leasingEquipment': _p(4.70, 6.80),
    },
  ),
  BankProfitMargin(
    bankId: 'jazira',
    bankName: 'بنك الجزيرة',
    products: {
      'personalBasic': _p(4.25, 6.00),
      'personalSpecial': _p(4.00, 5.50),
      'realEstateSupportedProgram': _p(3.75, 5.00),
      'realEstateSupportedMinistry': _p(2.75, 3.75),
      'realEstateCommercial': _p(4.25, 5.75),
      'realEstateResident': _p(4.00, 5.25),
      'leasingVehicles': _p(4.50, 6.75),
      'leasingEquipment': _p(5.00, 7.00),
    },
  ),
  BankProfitMargin(
    bankId: 'saab',
    bankName: 'البنك السعودي البريطاني',
    products: {
      'personalBasic': _p(4.10, 5.90),
      'personalSpecial': _p(3.85, 5.35),
      'realEstateSupportedProgram': _p(3.60, 4.85),
      'realEstateSupportedMinistry': _p(2.60, 3.60),
      'realEstateCommercial': _p(4.15, 5.65),
      'realEstateResident': _p(3.90, 5.15),
      'leasingVehicles': _p(4.30, 6.25),
      'leasingEquipment': _p(4.80, 6.75),
    },
  ),
  BankProfitMargin(
    bankId: 'fransi',
    bankName: 'البنك السعودي الفرنسي',
    products: {
      'personalBasic': _p(4.15, 5.80),
      'personalSpecial': _p(3.90, 5.30),
      'realEstateSupportedProgram': _p(3.55, 4.80),
      'realEstateSupportedMinistry': _p(2.55, 3.55),
      'realEstateCommercial': _p(4.20, 5.70),
      'realEstateResident': _p(3.95, 5.20),
      'leasingVehicles': _p(4.25, 6.20),
      'leasingEquipment': _p(4.75, 6.70),
    },
  ),
  BankProfitMargin(
    bankId: 'anb',
    bankName: 'البنك العربي الوطني',
    products: {
      'personalBasic': _p(4.20, 5.95),
      'personalSpecial': _p(3.95, 5.45),
      'realEstateSupportedProgram': _p(3.65, 4.90),
      'realEstateSupportedMinistry': _p(2.65, 3.65),
      'realEstateCommercial': _p(4.25, 5.75),
      'realEstateResident': _p(4.00, 5.25),
      'leasingVehicles': _p(4.35, 6.40),
      'leasingEquipment': _p(4.85, 6.85),
    },
  ),
  BankProfitMargin(
    bankId: 'bilad',
    bankName: 'بنك البلاد',
    products: {
      'personalBasic': _p(4.30, 6.10),
      'personalSpecial': _p(4.05, 5.55),
      'realEstateSupportedProgram': _p(3.80, 5.10),
      'realEstateSupportedMinistry': _p(2.80, 3.80),
      'realEstateCommercial': _p(4.35, 5.85),
      'realEstateResident': _p(4.10, 5.35),
      'leasingVehicles': _p(4.55, 6.80),
      'leasingEquipment': _p(5.05, 7.05),
    },
  ),
  BankProfitMargin(
    bankId: 'sibc',
    bankName: 'البنك السعودي للاستثمار',
    products: {
      'personalBasic': _p(4.35, 6.15),
      'personalSpecial': _na,
      'realEstateSupportedProgram': _p(3.85, 5.15),
      'realEstateSupportedMinistry': _na,
      'realEstateCommercial': _p(4.40, 5.90),
      'realEstateResident': _p(4.15, 5.40),
      'leasingVehicles': _p(4.60, 6.85),
      'leasingEquipment': _na,
    },
  ),
  BankProfitMargin(
    bankId: 'gib',
    bankName: 'بنك الخليج الدولي',
    products: {
      'personalBasic': _p(4.40, 6.20),
      'personalSpecial': _na,
      'realEstateSupportedProgram': _na,
      'realEstateSupportedMinistry': _na,
      'realEstateCommercial': _p(4.45, 5.95),
      'realEstateResident': _p(4.20, 5.45),
      'leasingVehicles': _p(4.65, 6.90),
      'leasingEquipment': _p(5.15, 7.15),
    },
  ),
];
