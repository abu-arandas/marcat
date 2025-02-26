class Order {
  String id, userId;
  List<OrderItem> items;
  double totalAmount;
  Status status;
  DateTime createdAt;
  Payment payment;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.payment,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String,
        userId: json['userId'] as String,
        items: (json['items'] as List)
            .map((item) => OrderItem.fromJson(item))
            .toList(),
        totalAmount: (json['totalAmount'] as num).toDouble(),
        status: statusFromJson(json['status']),
        createdAt: DateTime.parse(json['createdAt'] as String),
        payment: paymentFromJson(json['payment']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'items': items.map((item) => item.toJson()).toList(),
        'totalAmount': totalAmount,
        'status': statusFromEnum(status),
        'createdAt': createdAt.toIso8601String(),
        'payment': paymentFromEnum(payment),
      };
}

class OrderItem {
  String productId, color, size;
  int quantity;
  double price;

  OrderItem({
    required this.productId,
    required this.color,
    required this.size,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        productId: json['productId'] as String,
        color: json['color'] as String,
        size: json['size'] as String,
        quantity: json['quantity'] as int,
        price: (json['price'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'color': color,
        'size': size,
        'quantity': quantity,
        'price': price,
      };
}

enum Status { bind, prepare, delivering, done }

String statusFromEnum(Status status) {
  switch (status) {
    case Status.bind:
      return 'bind';
    case Status.prepare:
      return 'prepare';
    case Status.delivering:
      return 'delivering';
    case Status.done:
      return 'done';
  }
}

Status statusFromJson(String role) {
  switch (role) {
    case 'bind':
      return Status.bind;
    case 'prepare':
      return Status.prepare;
    case 'delivering':
      return Status.delivering;
    case 'done':
      return Status.done;
    default:
      return Status.done;
  }
}

enum Payment { cash, credite }

String paymentFromEnum(Payment payment) {
  switch (payment) {
    case Payment.cash:
      return 'cash';
    case Payment.credite:
      return 'credite';
  }
}

Payment paymentFromJson(String payment) {
  switch (payment) {
    case 'cash':
      return Payment.cash;
    case 'credite':
      return Payment.credite;
    default:
      return Payment.cash;
  }
}
