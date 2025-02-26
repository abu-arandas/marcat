class VariantInventory {
  String productId;
  String color;
  String size;
  int quantity;

  VariantInventory({
    required this.productId,
    required this.color,
    required this.size,
    required this.quantity,
  });

  factory VariantInventory.fromJson(Map<String, dynamic> json) =>
      VariantInventory(
        productId: json['productId'] as String,
        color: json['color'] as String,
        size: json['size'] as String,
        quantity: json['quantity'] as int,
      );

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'color': color,
        'size': size,
        'quantity': quantity,
      };
}

class InventoryReport {
  String productId;
  int totalStock;
  int sold;
  int remaining;
  List<VariantInventory> variantInventories;

  InventoryReport({
    required this.productId,
    required this.totalStock,
    required this.sold,
    required this.remaining,
    required this.variantInventories,
  });

  factory InventoryReport.fromJson(Map<String, dynamic> json) =>
      InventoryReport(
        productId: json['productId'] as String,
        totalStock: json['totalStock'] as int,
        sold: json['sold'] as int,
        remaining: json['remaining'] as int,
        variantInventories: (json['variantInventories'] as List<dynamic>)
            .map((e) => VariantInventory.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'totalStock': totalStock,
        'sold': sold,
        'remaining': remaining,
        'variantInventories':
            variantInventories.map((e) => e.toJson()).toList(),
      };
}
