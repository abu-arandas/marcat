// lib/data/models/brand_model.dart
//
// Mirrors public.brands
// ┌──────────┬────────────┬──────────┐
// │ column   │ pg type    │ nullable │
// ├──────────┼────────────┼──────────┤
// │ id       │ SERIAL PK  │ no       │
// │ name     │ TEXT       │ no       │
// │ logo_url │ TEXT       │ yes      │
// └──────────┴────────────┴──────────┘
// NOTE: brands has no created_at / updated_at columns.

class BrandModel {
  const BrandModel({
    required this.id,
    required this.name,
    this.logoUrl,
  });

  final int id;
  final String name;
  final String? logoUrl;

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'] as int,
      name: json['name'] as String,
      logoUrl: json['logo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'logo_url': logoUrl,
      };

  BrandModel copyWith({
    int? id,
    String? name,
    String? logoUrl,
  }) {
    return BrandModel(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BrandModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'BrandModel(id: $id, name: $name)';
}
