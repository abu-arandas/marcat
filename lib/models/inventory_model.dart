// lib/data/models/inventory_model.dart
//
// Mirrors public.store_inventory
// ┌─────────────────┬─────────────────────────────────────────────┬──────────┐
// │ column          │ pg type                                      │ nullable │
// ├─────────────────┼─────────────────────────────────────────────┼──────────┤
// │ id              │ SERIAL PK                                    │ no       │
// │ store_id        │ INTEGER → stores(id) ON DELETE CASCADE       │ no       │
// │ product_size_id │ INTEGER → product_sizes(id) ON DELETE CASCADE│ no       │
// │ color_id        │ INTEGER → product_colors(id) ON DELETE CASCADE│ no      │
// │ available       │ INTEGER CHECK >= 0  DEFAULT 0               │ no       │
// │ reserved        │ INTEGER CHECK >= 0  DEFAULT 0               │ no       │
// │ updated_at      │ TIMESTAMPTZ                                  │ no       │
// └─────────────────┴─────────────────────────────────────────────┴──────────┘
// NOTE: store_inventory has NO created_at column — only updated_at.
// UNIQUE (store_id, product_size_id, color_id)

class InventoryModel {
  const InventoryModel({
    required this.id,
    required this.storeId,
    required this.productSizeId,
    required this.colorId,
    required this.available,
    required this.reserved,
    required this.updatedAt,
  });

  final int id;
  final int storeId;
  final int productSizeId;
  final int colorId;

  /// CHECK (available >= 0)
  final int available;

  /// CHECK (reserved >= 0)
  final int reserved;

  final DateTime updatedAt;

  /// Stock actually available to sell = available - reserved.
  int get trulyAvailable => available - reserved;

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      id: json['id'] as int,
      storeId: json['store_id'] as int,
      productSizeId: json['product_size_id'] as int,
      colorId: json['color_id'] as int,
      available: json['available'] as int? ?? 0,
      reserved: json['reserved'] as int? ?? 0,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'store_id': storeId,
        'product_size_id': productSizeId,
        'color_id': colorId,
        'available': available,
        'reserved': reserved,
        'updated_at': updatedAt.toIso8601String(),
      };

  InventoryModel copyWith({
    int? id,
    int? storeId,
    int? productSizeId,
    int? colorId,
    int? available,
    int? reserved,
    DateTime? updatedAt,
  }) {
    return InventoryModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      productSizeId: productSizeId ?? this.productSizeId,
      colorId: colorId ?? this.colorId,
      available: available ?? this.available,
      reserved: reserved ?? this.reserved,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is InventoryModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'InventoryModel(id: $id, available: $available, reserved: $reserved)';
}
