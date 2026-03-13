// lib/data/models/product_image_model.dart
//
// Mirrors public.product_images
// ┌───────────────┬──────────────────────────────────────┬──────────┐
// │ column        │ pg type                               │ nullable │
// ├───────────────┼──────────────────────────────────────┼──────────┤
// │ id            │ SERIAL PK                             │ no       │
// │ product_id    │ INTEGER → products(id) ON DELETE CASCADE│ no     │
// │ image_url     │ TEXT                                  │ no       │
// │ display_order │ INTEGER DEFAULT 0                     │ no       │
// └───────────────┴──────────────────────────────────────┴──────────┘
// NOTE: product_images has no timestamp columns.
// display_order 0 = hero / primary image, higher = gallery images.

class ProductImageModel {
  const ProductImageModel({
    required this.id,
    required this.productId,
    required this.imageUrl,
    required this.displayOrder,
  });

  final int id;
  final int productId;
  final String imageUrl;

  /// 0 = hero image; higher numbers = additional gallery images.
  final int displayOrder;

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      imageUrl: json['image_url'] as String,
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'image_url': imageUrl,
        'display_order': displayOrder,
      };

  ProductImageModel copyWith({
    int? id,
    int? productId,
    String? imageUrl,
    int? displayOrder,
  }) {
    return ProductImageModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      imageUrl: imageUrl ?? this.imageUrl,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ProductImageModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ProductImageModel(id: $id, order: $displayOrder, url: $imageUrl)';
}
