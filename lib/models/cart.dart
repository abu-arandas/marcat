import '/config/exports.dart';

class CartItemModel {
  String id, productId;
  VariantModel variant;
  int quantity;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.variant,
    required this.quantity,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
        id: json['id'],
        productId: json['productId'],
        variant: VariantModel.fromJson(json['variant']),
        quantity: json['quantity'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'variant': variant.toJson(),
        'quantity': quantity,
      };
}
