// lib/data/models/product_size_model.dart
//
// Mirrors public.product_sizes
// ┌────────────┬──────────────────────────────────────┬──────────┐
// │ column     │ pg type                               │ nullable │
// ├────────────┼──────────────────────────────────────┼──────────┤
// │ id         │ SERIAL PK                             │ no       │
// │ product_id │ INTEGER → products(id) ON DELETE CASCADE│ no     │
// │ label      │ TEXT                                  │ no       │
// └────────────┴──────────────────────────────────────┴──────────┘
// NOTE: product_sizes has no timestamp columns.

class ProductSizeModel {
  const ProductSizeModel({
    required this.id,
    required this.productId,
    required this.label,
  });

  final int id;
  final int productId;

  /// Human-readable size label: 'S', 'M', 'L', 'XL', '32', 'EU 42', etc.
  final String label;

  factory ProductSizeModel.fromJson(Map<String, dynamic> json) {
    return ProductSizeModel(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      label: json['label'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'label': label,
      };

  ProductSizeModel copyWith({
    int? id,
    int? productId,
    String? label,
  }) {
    return ProductSizeModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      label: label ?? this.label,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ProductSizeModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ProductSizeModel(id: $id, label: $label)';
}
