// lib/data/models/sale_item_model.dart
//
// Mirrors public.sale_items
// ┌─────────────────┬──────────────────────────────────────────────┬──────────┐
// │ column          │ pg type                                       │ nullable │
// ├─────────────────┼──────────────────────────────────────────────┼──────────┤
// │ id              │ SERIAL PK                                     │ no       │
// │ sale_id         │ INTEGER → sales(id) ON DELETE CASCADE         │ no       │
// │ product_id      │ INTEGER → products(id) ON DELETE RESTRICT     │ no       │
// │ product_size_id │ INTEGER → product_sizes(id) ON DELETE RESTRICT│ no       │
// │ color_id        │ INTEGER → product_colors(id) ON DELETE RESTRICT│ no      │
// │ quantity        │ INTEGER CHECK > 0                             │ no       │
// │ unit_price      │ DECIMAL(10,2) CHECK >= 0                      │ no       │
// │ discount_amount │ DECIMAL(10,2) CHECK >= 0  DEFAULT 0           │ no       │
// │ total_price     │ DECIMAL(12,2) CHECK >= 0                      │ no       │
// └─────────────────┴──────────────────────────────────────────────┴──────────┘
// NOTE: sale_items has no timestamp columns.
//
// productName is a virtual/join field — not a DB column.
// It is populated when the query joins public.products  (e.g. via
// Supabase `select('*, products(name)')`).

class SaleItemModel {
  const SaleItemModel({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.productSizeId,
    required this.colorId,
    required this.quantity,
    required this.unitPrice,
    required this.discountAmount,
    required this.totalPrice,
    this.productName,
  });

  final int id;
  final int saleId;
  final int productId;
  final int productSizeId;
  final int colorId;

  /// CHECK (quantity > 0)
  final int quantity;

  /// DECIMAL(10,2)
  final double unitPrice;

  /// DECIMAL(10,2) — item-level discount, DEFAULT 0.
  final double discountAmount;

  /// DECIMAL(12,2)
  final double totalPrice;

  /// Virtual field — populated by joining public.products.
  final String? productName;

  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    return SaleItemModel(
      id: json['id'] as int,
      saleId: json['sale_id'] as int,
      productId: json['product_id'] as int,
      productSizeId: json['product_size_id'] as int,
      colorId: json['color_id'] as int,
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['total_price'] as num).toDouble(),
      // Supabase join: select('*, products(name)')
      productName: json['products'] != null
          ? (json['products'] as Map<String, dynamic>)['name'] as String?
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sale_id': saleId,
        'product_id': productId,
        'product_size_id': productSizeId,
        'color_id': colorId,
        'quantity': quantity,
        'unit_price': unitPrice,
        'discount_amount': discountAmount,
        'total_price': totalPrice,
        if (productName != null) 'products': {'name': productName},
      };

  SaleItemModel copyWith({
    int? id,
    int? saleId,
    int? productId,
    int? productSizeId,
    int? colorId,
    int? quantity,
    double? unitPrice,
    double? discountAmount,
    double? totalPrice,
    String? productName,
  }) {
    return SaleItemModel(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      productSizeId: productSizeId ?? this.productSizeId,
      colorId: colorId ?? this.colorId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discountAmount: discountAmount ?? this.discountAmount,
      totalPrice: totalPrice ?? this.totalPrice,
      productName: productName ?? this.productName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SaleItemModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'SaleItemModel(id: $id, productId: $productId, qty: $quantity)';
}
