// lib/data/models/customer_model.dart
//
// Mirrors public.customers  (PK is also FK → public.profiles(id))
// ┌────────────────┬──────────────────────────────────┬──────────┐
// │ column         │ pg type                           │ nullable │
// ├────────────────┼──────────────────────────────────┼──────────┤
// │ id             │ UUID PK → profiles(id)            │ no       │
// │ loyalty_points │ INTEGER  CHECK >= 0  DEFAULT 0    │ no       │
// │ loyalty_tier   │ public.loyalty_tier DEFAULT Bronze│ no       │
// │ total_spent    │ DECIMAL(12,2) CHECK >= 0 DEFAULT 0│ no       │
// │ date_of_birth  │ DATE                              │ yes      │
// │ notes          │ TEXT                              │ yes      │
// │ created_at     │ TIMESTAMPTZ                       │ no       │
// │ updated_at     │ TIMESTAMPTZ                       │ no       │
// └────────────────┴──────────────────────────────────┴──────────┘

import 'enums.dart';

class CustomerModel {
  const CustomerModel({
    required this.id,
    required this.loyaltyPoints,
    required this.loyaltyTier,
    required this.totalSpent,
    this.dateOfBirth,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;

  /// CHECK (loyalty_points >= 0)
  final int loyaltyPoints;

  final LoyaltyTier loyaltyTier;

  /// CHECK (total_spent >= 0)  — updated by sale trigger, not manually.
  final double totalSpent;

  final DateTime? dateOfBirth;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      loyaltyPoints: (json['loyalty_points'] as num?)?.toInt() ?? 0,
      loyaltyTier: LoyaltyTierX.fromDb(json['loyalty_tier'] as String?),
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0.0,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'loyalty_points': loyaltyPoints,
        'loyalty_tier': loyaltyTier.dbValue,
        'total_spent': totalSpent,
        // DATE column — send only the date part, no time component.
        'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  CustomerModel copyWith({
    String? id,
    int? loyaltyPoints,
    LoyaltyTier? loyaltyTier,
    double? totalSpent,
    DateTime? dateOfBirth,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      loyaltyTier: loyaltyTier ?? this.loyaltyTier,
      totalSpent: totalSpent ?? this.totalSpent,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CustomerModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'CustomerModel(id: $id, tier: $loyaltyTier, points: $loyaltyPoints)';
}
