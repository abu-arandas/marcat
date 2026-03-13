// lib/data/models/loyalty_transaction_model.dart
//
// Mirrors public.loyalty_transactions
// ┌─────────────┬────────────────────────────────────────────┬──────────┐
// │ column      │ pg type                                     │ nullable │
// ├─────────────┼────────────────────────────────────────────┼──────────┤
// │ id          │ SERIAL PK                                   │ no       │
// │ customer_id │ UUID → customers(id) ON DELETE CASCADE      │ no       │
// │ sale_id     │ INTEGER → sales(id) ON DELETE SET NULL      │ yes      │
// │ points      │ INTEGER CHECK <> 0                          │ no       │
// │ description │ TEXT                                        │ yes      │
// │ created_at  │ TIMESTAMPTZ                                 │ no       │
// └─────────────┴────────────────────────────────────────────┴──────────┘
// NOTE: loyalty_transactions has NO updated_at column.
// CHECK (points <> 0) — zero-point rows are rejected by the DB.
// Positive points = earn; negative points = redeem.

class LoyaltyTransactionModel {
  const LoyaltyTransactionModel({
    required this.id,
    required this.customerId,
    this.saleId,
    required this.points,
    this.description,
    required this.createdAt,
  });

  final int id;

  /// UUID — references public.customers(id).
  final String customerId;

  /// NULL for manual adjustments not tied to a sale.
  final int? saleId;

  /// CHECK (points <> 0).  Positive = earn, negative = redeem.
  final int points;

  final String? description;
  final DateTime createdAt;

  bool get isEarn => points > 0;
  bool get isRedeem => points < 0;

  factory LoyaltyTransactionModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyTransactionModel(
      id: json['id'] as int,
      customerId: json['customer_id'] as String,
      saleId: json['sale_id'] as int?,
      points: json['points'] as int,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer_id': customerId,
        'sale_id': saleId,
        'points': points,
        'description': description,
        'created_at': createdAt.toIso8601String(),
      };

  LoyaltyTransactionModel copyWith({
    int? id,
    String? customerId,
    int? saleId,
    int? points,
    String? description,
    DateTime? createdAt,
  }) {
    return LoyaltyTransactionModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      saleId: saleId ?? this.saleId,
      points: points ?? this.points,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoyaltyTransactionModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'LoyaltyTransactionModel(id: $id, points: $points, earn: $isEarn)';
}
