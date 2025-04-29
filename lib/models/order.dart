import '/config/exports.dart';

enum OrderStatus { pending, processing, shipped, delivered, canceled }

extension OrderStatusExtension on OrderStatus {
  String fromEnum() => toString().split('.').last;

  static OrderStatus fromJson(String status) {
    return OrderStatus.values.firstWhere((e) => e.fromEnum() == status);
  }
}

class OrderModel {
  String id, userId;
  DateTime date;
  double total;
  OrderStatus status;
  List<OrderItemModel> items;
  String storeId;

  OrderModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.total,
    required this.status,
    required this.items,
    required this.storeId,
  });

  factory OrderModel.fromJson(DocumentSnapshot doc) => OrderModel(
        id: doc.id,
        userId: doc['userId'] as String,
        date: (doc['date'] as Timestamp).toDate(),
        total: (doc['total'] as num).toDouble(),
        status: OrderStatusExtension.fromJson(doc['status'] as String),
        items: List<OrderItemModel>.from((doc['items'] as List<dynamic>)
            .map((x) => OrderItemModel.fromJson(x))),
        storeId: doc['storeId'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'date': date,
        'total': total,
        'status': status.fromEnum(),
        'items': List<dynamic>.from(items.map((x) => x.toJson())),
        'storeId': storeId,
      };
}

class OrderItemModel {
  String id;
  String productId;
  int quantity;
  double price;
  VariantModel variant;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.variant,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
        id: json['id'] as String,
        productId: json['productId'] as String,
        quantity: json['quantity'] as int,
        price: (json['price'] as num).toDouble(),
        variant: VariantModel.fromJson(json['variant']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'quantity': quantity,
        'price': price,
        'variant': variant.toJson(),
      };
}
