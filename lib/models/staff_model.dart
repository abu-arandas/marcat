// lib/data/models/staff_model.dart
//
// Mirrors public.staff  (PK is also FK → public.profiles(id))
// ┌───────────────────┬─────────────────────────────┬──────────┐
// │ column            │ pg type                      │ nullable │
// ├───────────────────┼─────────────────────────────┼──────────┤
// │ id                │ UUID PK → profiles(id)       │ no       │
// │ assigned_store_id │ INTEGER → stores(id)         │ yes      │
// │ pos_pin_hash      │ TEXT  (bcrypt hash, server)  │ yes      │
// │ target_sales      │ DECIMAL(12,2) DEFAULT 0      │ no       │
// │ is_active         │ BOOLEAN DEFAULT true         │ no       │
// │ created_at        │ TIMESTAMPTZ                  │ no       │
// │ updated_at        │ TIMESTAMPTZ                  │ no       │
// └───────────────────┴─────────────────────────────┴──────────┘
//
// NOTE: pos_pin_hash is returned by Supabase only for admin queries;
//       it should never be sent to a client-facing UI.

import 'enums.dart';


class StaffModel {
  const StaffModel({
    required this.id,
    this.assignedStoreId,
    this.posPinHash,
    required this.targetSales,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.firstName = 'Unknown',
    this.lastName,
    this.role,
  });

  /// UUID — shared PK/FK with public.profiles
  final String id;

  final int? assignedStoreId;

  /// Bcrypt hash — do NOT display or log.
  final String? posPinHash;

  /// DECIMAL(12,2)
  final double targetSales;

  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  final String firstName;
  final String? lastName;
  final UserRole? role;

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    final profiles = json['profiles'] as Map<String, dynamic>?;
    return StaffModel(
      id: json['id'] as String,
      assignedStoreId: json['assigned_store_id'] as int?,
      posPinHash: json['pos_pin_hash'] as String?,
      targetSales: (json['target_sales'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      firstName: (profiles?['first_name'] ?? json['first_name'] ?? 'Unknown') as String,
      lastName: (profiles?['last_name'] ?? json['last_name']) as String?,
      role: UserRoleX.fromDb(profiles?['role'] ?? json['role'] as String?),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'assigned_store_id': assignedStoreId,
        // pos_pin_hash intentionally excluded from client-side serialisation.
        'target_sales': targetSales,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'first_name': firstName,
        'last_name': lastName,
        'role': role?.dbValue,
      };

  StaffModel copyWith({
    String? id,
    int? assignedStoreId,
    String? posPinHash,
    double? targetSales,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? firstName,
    String? lastName,
    UserRole? role,
  }) {
    return StaffModel(
      id: id ?? this.id,
      assignedStoreId: assignedStoreId ?? this.assignedStoreId,
      posPinHash: posPinHash ?? this.posPinHash,
      targetSales: targetSales ?? this.targetSales,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is StaffModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'StaffModel(id: $id, active: $isActive)';
}
