// lib/data/models/product_color_model.dart
//
// Mirrors public.product_colors
// ┌────────────┬───────────────────────────────────────────────┬──────────┐
// │ column     │ pg type                                        │ nullable │
// ├────────────┼───────────────────────────────────────────────┼──────────┤
// │ id         │ SERIAL PK                                      │ no       │
// │ product_id │ INTEGER → products(id) ON DELETE CASCADE       │ no       │
// │ name       │ TEXT                                           │ no       │
// │ hex_code   │ TEXT CHECK (hex_code ~ '^#[0-9A-Fa-f]{6}$')   │ no       │
// └────────────┴───────────────────────────────────────────────┴──────────┘
// NOTE: product_colors has no timestamp columns.

class ProductColorModel {
  const ProductColorModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.hexCode,
  });

  final int id;
  final int productId;
  final String name;

  /// CSS hex color — always matches '^#[0-9A-Fa-f]{6}$' (enforced by DB CHECK).
  final String hexCode;

  factory ProductColorModel.fromJson(Map<String, dynamic> json) {
    return ProductColorModel(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      name: json['name'] as String,
      hexCode: json['hex_code'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'name': name,
        'hex_code': hexCode,
      };

  ProductColorModel copyWith({
    int? id,
    int? productId,
    String? name,
    String? hexCode,
  }) {
    return ProductColorModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      hexCode: hexCode ?? this.hexCode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ProductColorModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ProductColorModel(id: $id, name: $name, hex: $hexCode)';
}
