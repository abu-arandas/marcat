// lib/models/store_model.dart
//
// Mirrors public.stores
// ┌─────────────┬─────────────┬──────────┐
// │ column      │ pg type     │ nullable │
// ├─────────────┼─────────────┼──────────┤
// │ id          │ SERIAL PK   │ no       │
// │ name        │ TEXT        │ no       │
// │ location    │ TEXT        │ yes      │
// │ phone       │ TEXT        │ yes      │
// │ is_active   │ BOOLEAN     │ no       │
// │ created_at  │ TIMESTAMPTZ │ no       │
// │ updated_at  │ TIMESTAMPTZ │ no       │
// └─────────────┴─────────────┴──────────┘

class StoreModel {
  const StoreModel({
    required this.id,
    required this.name,
    this.location,
    this.phone,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final String? location;
  final String? phone;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] as int,
      name: json['name'] as String,
      location: json['location'] as String?,
      phone: json['phone'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'location': location,
        'phone': phone,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  StoreModel copyWith({
    int? id,
    String? name,
    String? location,
    String? phone,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StoreModel(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is StoreModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'StoreModel(id: $id, name: $name)';
}
