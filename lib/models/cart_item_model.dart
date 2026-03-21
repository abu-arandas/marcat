// lib/models/cart_item_model.dart
//
// CartItemModel is a CLIENT-SIDE model only — it has no corresponding
// database table.  It represents a line item in the local cart before
// an order is submitted.
//
// When submitting an order, use [encodeForRpc] to build the JSONB array
// required by the create_order_with_items / process_pos_sale RPCs.
//
// RPC item shape (from database.sql):
//   { product_id, product_size_id, color_id, quantity, unit_price, discount_amount }
// total_price is computed SERVER-SIDE — do NOT include it in the array.

class CartItemModel {
  const CartItemModel({
    required this.productId,
    required this.productName,
    required this.productSizeId,
    required this.sizeLabel,
    required this.colorId,
    required this.colorName,
    required this.unitPrice,
    required this.quantity,
    this.primaryImageUrl,
    this.discountAmount = 0.0,
  });

  final int productId;
  final String productName;
  final int productSizeId;
  final String sizeLabel;
  final int colorId;
  final String colorName;
  final double unitPrice;
  final int quantity;
  final String? primaryImageUrl;

  /// Item-level discount amount in currency units (default 0).
  /// Coupon / offer discounts are applied at the RPC level, not here.
  final double discountAmount;

  /// Computed client-side for display only.
  double get lineTotal => (unitPrice * quantity) - discountAmount;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      productSizeId: json['product_size_id'] as int,
      sizeLabel: json['size_label'] as String,
      colorId: json['color_id'] as int,
      colorName: json['color_name'] as String,
      unitPrice: (json['unit_price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      primaryImageUrl: json['primary_image_url'] as String?,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'product_name': productName,
        'product_size_id': productSizeId,
        'size_label': sizeLabel,
        'color_id': colorId,
        'color_name': colorName,
        'unit_price': unitPrice,
        'quantity': quantity,
        'primary_image_url': primaryImageUrl,
        'discount_amount': discountAmount,
      };

  CartItemModel copyWith({
    int? productId,
    String? productName,
    int? productSizeId,
    String? sizeLabel,
    int? colorId,
    String? colorName,
    double? unitPrice,
    int? quantity,
    String? primaryImageUrl,
    double? discountAmount,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productSizeId: productSizeId ?? this.productSizeId,
      sizeLabel: sizeLabel ?? this.sizeLabel,
      colorId: colorId ?? this.colorId,
      colorName: colorName ?? this.colorName,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      primaryImageUrl: primaryImageUrl ?? this.primaryImageUrl,
      discountAmount: discountAmount ?? this.discountAmount,
    );
  }

  /// Encodes a list of cart items into the JSONB array consumed by the
  /// create_order_with_items and process_pos_sale RPCs.
  ///
  /// Key names must match the RPC's internal JSONB field access:
  ///   v_item->>'product_id'        ← NOT 'p_product_id'
  ///   v_item->>'product_size_id'   ← NOT 'p_product_size_id'
  ///   v_item->>'color_id'          ← NOT 'p_color_id'
  ///   v_item->>'quantity'
  ///   v_item->>'unit_price'
  ///   v_item->>'discount_amount'
  ///
  /// total_price is intentionally omitted — it is calculated server-side
  /// to prevent client-side price tampering.
  static List<Map<String, dynamic>> encodeForRpc(List<CartItemModel> items) {
    return items
        .map((i) => {
              'product_id': i.productId,
              'product_size_id': i.productSizeId,
              'color_id': i.colorId,
              'quantity': i.quantity,
              'unit_price': i.unitPrice,
              'discount_amount': i.discountAmount,
            })
        .toList();
  }
}
