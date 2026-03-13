// lib/data/models/offer_model.dart
//
// Mirrors public.offers
// ┌─────────────────┬──────────────────────────────────────────┬──────────┐
// │ column          │ pg type                                   │ nullable │
// ├─────────────────┼──────────────────────────────────────────┼──────────┤
// │ id              │ SERIAL PK                                 │ no       │
// │ code            │ TEXT UNIQUE                               │ no       │
// │ description     │ TEXT                                      │ yes      │
// │ discount_type   │ TEXT CHECK ('percentage','fixed')         │ no       │
// │ discount_value  │ DECIMAL(10,2) CHECK > 0                   │ no       │
// │ min_order_total │ DECIMAL(12,2) DEFAULT 0.00                │ no       │
// │ max_uses        │ INTEGER                                   │ yes      │
// │ used_count      │ INTEGER DEFAULT 0                         │ no       │
// │ expires_at      │ TIMESTAMPTZ                               │ yes      │
// │ is_active       │ BOOLEAN DEFAULT true                      │ no       │
// │ created_at      │ TIMESTAMPTZ                               │ no       │
// └─────────────────┴──────────────────────────────────────────┴──────────┘
// NOTE: offers has no updated_at column.

class OfferModel {
  const OfferModel({
    required this.id,
    required this.code,
    this.description,
    required this.discountType,
    required this.discountValue,
    required this.minOrderTotal,
    this.maxUses,
    required this.usedCount,
    this.expiresAt,
    required this.isActive,
    required this.createdAt,
  });

  final int id;
  final String code;
  final String? description;

  /// CHECK (discount_type IN ('percentage', 'fixed'))
  final String discountType;

  /// CHECK (discount_value > 0)
  final double discountValue;

  final double minOrderTotal;

  /// NULL → unlimited uses.
  final int? maxUses;

  final int usedCount;

  /// NULL → never expires.
  final DateTime? expiresAt;

  final bool isActive;
  final DateTime createdAt;

  /// True if the offer is currently usable (active, not expired, has remaining uses).
  bool isUsable({required double cartTotal}) {
    if (!isActive) return false;
    if (expiresAt != null && expiresAt!.isBefore(DateTime.now())) return false;
    if (maxUses != null && usedCount >= maxUses!) return false;
    if (cartTotal < minOrderTotal) return false;
    return true;
  }

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id'] as int,
      code: json['code'] as String,
      description: json['description'] as String?,
      discountType: json['discount_type'] as String,
      discountValue: (json['discount_value'] as num).toDouble(),
      minOrderTotal: (json['min_order_total'] as num?)?.toDouble() ?? 0.0,
      maxUses: json['max_uses'] as int?,
      usedCount: json['used_count'] as int? ?? 0,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'description': description,
        'discount_type': discountType,
        'discount_value': discountValue,
        'min_order_total': minOrderTotal,
        'max_uses': maxUses,
        'used_count': usedCount,
        'expires_at': expiresAt?.toIso8601String(),
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
      };

  OfferModel copyWith({
    int? id,
    String? code,
    String? description,
    String? discountType,
    double? discountValue,
    double? minOrderTotal,
    int? maxUses,
    int? usedCount,
    DateTime? expiresAt,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return OfferModel(
      id: id ?? this.id,
      code: code ?? this.code,
      description: description ?? this.description,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      minOrderTotal: minOrderTotal ?? this.minOrderTotal,
      maxUses: maxUses ?? this.maxUses,
      usedCount: usedCount ?? this.usedCount,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is OfferModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'OfferModel(id: $id, code: $code, active: $isActive)';
}
