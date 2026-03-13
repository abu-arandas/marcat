// lib/data/models/wishlist_model.dart
//
// Mirrors public.wishlist
// ┌────────────┬────────────────────────────────────────────────┬──────────┐
// │ column     │ pg type                                         │ nullable │
// ├────────────┼────────────────────────────────────────────────┼──────────┤
// │ id         │ BIGSERIAL PK                                    │ no       │
// │ user_id    │ UUID → auth.users(id) ON DELETE CASCADE         │ no       │
// │ product_id │ BIGINT → products(id) ON DELETE CASCADE         │ no       │
// │ created_at │ TIMESTAMPTZ                                     │ no       │
// └────────────┴────────────────────────────────────────────────┴──────────┘
// UNIQUE (user_id, product_id)
// NOTE: wishlist has no updated_at column.
//
// id and product_id are stored as BIGSERIAL / BIGINT in Postgres.
// Dart's int is 64-bit on all platforms (VM), so no precision is lost.

class WishlistModel {
  const WishlistModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.createdAt,
  });

  /// BIGSERIAL — 64-bit integer.
  final int id;

  /// UUID — references auth.users(id).
  final String userId;

  /// BIGINT — references public.products(id).
  final int productId;

  final DateTime createdAt;

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    return WishlistModel(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      productId: json['product_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'product_id': productId,
        'created_at': createdAt.toIso8601String(),
      };

  WishlistModel copyWith({
    int? id,
    String? userId,
    int? productId,
    DateTime? createdAt,
  }) {
    return WishlistModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WishlistModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'WishlistModel(id: $id, userId: $userId, productId: $productId)';
}
