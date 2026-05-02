import 'package:cloud_firestore/cloud_firestore.dart';

/// هوامش الربح لكل بنك
class BankProfitMargin {
  const BankProfitMargin({
    required this.bankId,
    required this.bankName,
    required this.personal,
    required this.realEstate,
    required this.leasing,
    this.notes = '',
  });

  final String bankId;
  final String bankName;
  final ProductMargin personal;
  final ProductMargin realEstate;
  final ProductMargin leasing;
  final String notes;

  factory BankProfitMargin.fromMap(Map<String, dynamic> map) {
    return BankProfitMargin(
      bankId: map['bankId'] as String? ?? '',
      bankName: map['bankName'] as String? ?? '',
      personal: ProductMargin.fromMap(
          map['personal'] as Map<String, dynamic>? ?? {}),
      realEstate: ProductMargin.fromMap(
          map['realEstate'] as Map<String, dynamic>? ?? {}),
      leasing: ProductMargin.fromMap(
          map['leasing'] as Map<String, dynamic>? ?? {}),
      notes: map['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'bankId': bankId,
        'bankName': bankName,
        'personal': personal.toMap(),
        'realEstate': realEstate.toMap(),
        'leasing': leasing.toMap(),
        'notes': notes,
      };

  BankProfitMargin copyWith({
    String? bankName,
    ProductMargin? personal,
    ProductMargin? realEstate,
    ProductMargin? leasing,
    String? notes,
  }) =>
      BankProfitMargin(
        bankId: bankId,
        bankName: bankName ?? this.bankName,
        personal: personal ?? this.personal,
        realEstate: realEstate ?? this.realEstate,
        leasing: leasing ?? this.leasing,
        notes: notes ?? this.notes,
      );
}

class ProductMargin {
  const ProductMargin({
    required this.min,
    required this.max,
    this.available = true,
  });

  final double min;
  final double max;
  final bool available;

  factory ProductMargin.fromMap(Map<String, dynamic> map) {
    return ProductMargin(
      min: (map['min'] as num?)?.toDouble() ?? 0.0,
      max: (map['max'] as num?)?.toDouble() ?? 0.0,
      available: map['available'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'min': min,
        'max': max,
        'available': available,
      };
}

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

  static ProfitMarginsConfig defaultConfig() {
    return ProfitMarginsConfig(
      updatedBy: 'default',
      banks: _defaultBanks,
    );
  }
}

const _defaultBanks = [
  BankProfitMargin(
    bankId: 'rajhi',
    bankName: 'بنك الراجحي',
    personal: ProductMargin(min: 3.99, max: 5.50),
    realEstate: ProductMargin(min: 3.50, max: 4.75),
    leasing: ProductMargin(min: 4.00, max: 6.00),
  ),
  BankProfitMargin(
    bankId: 'snb',
    bankName: 'البنك الأهلي السعودي',
    personal: ProductMargin(min: 4.00, max: 5.75),
    realEstate: ProductMargin(min: 3.45, max: 4.90),
    leasing: ProductMargin(min: 4.20, max: 6.50),
  ),
  BankProfitMargin(
    bankId: 'jazira',
    bankName: 'بنك الجزيرة',
    personal: ProductMargin(min: 4.25, max: 6.00),
    realEstate: ProductMargin(min: 3.75, max: 5.00),
    leasing: ProductMargin(min: 4.50, max: 6.75),
  ),
  BankProfitMargin(
    bankId: 'saab',
    bankName: 'بنك ساب',
    personal: ProductMargin(min: 4.10, max: 5.90),
    realEstate: ProductMargin(min: 3.60, max: 4.85),
    leasing: ProductMargin(min: 4.30, max: 6.25),
  ),
  BankProfitMargin(
    bankId: 'fransi',
    bankName: 'البنك السعودي الفرنسي',
    personal: ProductMargin(min: 4.15, max: 5.80),
    realEstate: ProductMargin(min: 3.55, max: 4.80),
    leasing: ProductMargin(min: 4.25, max: 6.20),
  ),
  BankProfitMargin(
    bankId: 'inma',
    bankName: 'مصرف الإنماء',
    personal: ProductMargin(min: 3.95, max: 5.60),
    realEstate: ProductMargin(min: 3.40, max: 4.70),
    leasing: ProductMargin(min: 4.10, max: 6.10),
  ),
  BankProfitMargin(
    bankId: 'riyadh',
    bankName: 'بنك الرياض',
    personal: ProductMargin(min: 4.05, max: 5.70),
    realEstate: ProductMargin(min: 3.50, max: 4.80),
    leasing: ProductMargin(min: 4.20, max: 6.30),
  ),
  BankProfitMargin(
    bankId: 'anb',
    bankName: 'البنك العربي الوطني',
    personal: ProductMargin(min: 4.20, max: 5.95),
    realEstate: ProductMargin(min: 3.65, max: 4.90),
    leasing: ProductMargin(min: 4.35, max: 6.40),
  ),
  BankProfitMargin(
    bankId: 'bilad',
    bankName: 'بنك البلاد',
    personal: ProductMargin(min: 4.30, max: 6.10),
    realEstate: ProductMargin(min: 3.80, max: 5.10),
    leasing: ProductMargin(min: 4.55, max: 6.80),
  ),
];
