class CartItem {
  String id, productId, color, size;
  int quantity;
  double price;

  CartItem({
    required this.id,
    required this.productId,
    required this.color,
    required this.size,
    required this.quantity,
    required this.price,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id'] as String,
        productId: json['productId'] as String,
        color: json['color'] as String,
        size: json['size'] as String,
        quantity: json['quantity'] as int,
        price: (json['price'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'color': color,
        'size': size,
        'quantity': quantity,
        'price': price,
      };
}
