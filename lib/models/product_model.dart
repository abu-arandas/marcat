// lib/models/product_model.dart
//
// Mirrors public.products
// ┌───────────────────┬────────────────────────────────────┬──────────┐
// │ column            │ pg type                             │ nullable │
// ├───────────────────┼────────────────────────────────────┼──────────┤
// │ id                │ SERIAL PK                           │ no       │
// │ name              │ TEXT                                │ no       │
// │ description       │ TEXT                                │ yes      │
// │ sku               │ TEXT UNIQUE                         │ no       │
// │ base_price        │ DECIMAL(10,2) CHECK >= 0            │ no       │
// │ brand_id          │ INTEGER → brands(id)                │ yes      │
// │ category_id       │ INTEGER → categories(id)            │ yes      │
// │ primary_image_url │ TEXT                                │ yes      │
// │ status            │ public.product_status DEFAULT active│ no       │
// │ created_at        │ TIMESTAMPTZ                         │ no       │
// │ updated_at        │ TIMESTAMPTZ                         │ no       │
// └───────────────────┴────────────────────────────────────┴──────────┘

import 'enums.dart';

class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.sku,
    required this.basePrice,
    this.brandId,
    this.categoryId,
    this.primaryImageUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final String? description;

  /// UNIQUE across products.
  final String sku;

  /// DECIMAL(10,2)  CHECK (base_price >= 0)
  final double basePrice;

  final int? brandId;
  final int? categoryId;
  final String? primaryImageUrl;
  final ProductStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      sku: json['sku'] as String,
      basePrice: (json['base_price'] as num).toDouble(),
      brandId: json['brand_id'] as int?,
      categoryId: json['category_id'] as int?,
      primaryImageUrl: json['primary_image_url'] as String?,
      status: ProductStatusX.fromDb(json['status'] as String?),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'sku': sku,
        'base_price': basePrice,
        'brand_id': brandId,
        'category_id': categoryId,
        'primary_image_url': primaryImageUrl,
        'status': status.dbValue,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  ProductModel copyWith({
    int? id,
    String? name,
    String? description,
    String? sku,
    double? basePrice,
    int? brandId,
    int? categoryId,
    String? primaryImageUrl,
    ProductStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sku: sku ?? this.sku,
      basePrice: basePrice ?? this.basePrice,
      brandId: brandId ?? this.brandId,
      categoryId: categoryId ?? this.categoryId,
      primaryImageUrl: primaryImageUrl ?? this.primaryImageUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ProductModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ProductModel(id: $id, sku: $sku, name: $name)';
}
