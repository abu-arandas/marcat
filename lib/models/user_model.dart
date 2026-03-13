// lib/data/models/user_model.dart
//
// Mirrors public.profiles  (extends auth.users via FK on id)
// ┌─────────────┬─────────────────────────────────────────┬──────────┐
// │ column      │ pg type                                  │ nullable │
// ├─────────────┼─────────────────────────────────────────┼──────────┤
// │ id          │ UUID PK → auth.users(id)                 │ no       │
// │ first_name  │ TEXT                                     │ no       │
// │ last_name   │ TEXT                                     │ no       │
// │ phone       │ TEXT                                     │ yes      │
// │ avatar_url  │ TEXT                                     │ yes      │
// │ role        │ public.user_role  DEFAULT 'customer'     │ no       │
// │ status      │ TEXT CHECK ('active','suspended','deleted')│ no      │
// │ created_at  │ TIMESTAMPTZ                              │ no       │
// │ updated_at  │ TIMESTAMPTZ                              │ no       │
// └─────────────┴─────────────────────────────────────────┴──────────┘

import 'enums.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.avatarUrl,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? avatarUrl;
  final UserRole role;

  /// CHECK (status IN ('active', 'suspended', 'deleted'))
  final String status;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Convenience getter — not a DB column.
  String get fullName => '$firstName $lastName'.trim();

  bool get isActive => status == 'active';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: UserRoleX.fromDb(json['role'] as String?),
      status: json['status'] as String? ?? 'active',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'avatar_url': avatarUrl,
        'role': role.dbValue,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
    UserRole? role,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UserModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'UserModel(id: $id, name: $fullName, role: $role)';
}
