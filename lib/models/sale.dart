import '/config/exports.dart';

class Sale {
  final String id;
  final DateTime date;
  final double total;
  final List<Map<String, dynamic>> products;
  final String storeId;
  final String userId;

  Sale({
    required this.id,
    required this.date,
    required this.total,
    required this.products,
    required this.storeId,
    required this.userId,
  });

  factory Sale.fromJson(DocumentSnapshot doc) => Sale(
        id: doc.id,
        date: (doc.data() as Map<String, dynamic>)['date'].toDate(),
        total: (doc.data() as Map<String, dynamic>)['total'],
        products: (doc.data() as Map<String, dynamic>)['products'],
        storeId: (doc.data() as Map<String, dynamic>)['storeId'],
        userId: (doc.data() as Map<String, dynamic>)['userId'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'total': total,
        'products': products,
        'storeId': storeId,
        'userId': userId,
      };
}
