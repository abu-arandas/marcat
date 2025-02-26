class Product {
  String id, storeId, categoryId, name, description;
  double basePrice;
  List<ProductColorVariant> colorVariants;
  List<Review> reviews;

  Product({
    required this.id,
    required this.storeId,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.colorVariants,
    required this.reviews,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        storeId: json['storeId'] as String,
        categoryId: json['categoryId'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        basePrice: (json['basePrice'] as num).toDouble(),
        colorVariants: (json['colorVariants'] as List<dynamic>)
            .map((e) => ProductColorVariant.fromJson(e as Map<String, dynamic>))
            .toList(),
        reviews: (json['reviews'] as List<dynamic>)
            .map((e) => Review.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'storeId': storeId,
        'categoryId': categoryId,
        'name': name,
        'description': description,
        'basePrice': basePrice,
        'colorVariants': colorVariants.map((e) => e.toJson()).toList(),
        'reviews': reviews.map((e) => e.toJson()).toList(),
      };
}

class ProductColorVariant {
  String color; // e.g., "Red", "Blue", etc.
  List<ProductSizeVariant> sizeVariants;
  List<String> images; // URLs for images corresponding to this color

  ProductColorVariant({
    required this.color,
    required this.sizeVariants,
    required this.images,
  });

  factory ProductColorVariant.fromJson(Map<String, dynamic> json) =>
      ProductColorVariant(
        color: json['color'] as String,
        sizeVariants: (json['sizeVariants'] as List<dynamic>)
            .map((e) => ProductSizeVariant.fromJson(e as Map<String, dynamic>))
            .toList(),
        images: List<String>.from(json['images']),
      );

  Map<String, dynamic> toJson() => {
        'color': color,
        'sizeVariants': sizeVariants.map((e) => e.toJson()).toList(),
        'images': images,
      };
}

class ProductSizeVariant {
  String size; // e.g., "S", "M", "L"
  int quantity;
  double? additionalPrice; // Optional price difference for this size

  ProductSizeVariant({
    required this.size,
    required this.quantity,
    this.additionalPrice,
  });

  factory ProductSizeVariant.fromJson(Map<String, dynamic> json) =>
      ProductSizeVariant(
        size: json['size'] as String,
        quantity: json['quantity'] as int,
        additionalPrice: json['additionalPrice'] != null
            ? (json['additionalPrice'] as num).toDouble()
            : null,
      );

  Map<String, dynamic> toJson() => {
        'size': size,
        'quantity': quantity,
        'additionalPrice': additionalPrice,
      };
}

class Review {
  String id, userId;
  double rating;
  String comment;
  DateTime createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'] as String,
        userId: json['userId'] as String,
        rating: (json['rating'] as num).toDouble(),
        comment: json['comment'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'rating': rating,
        'comment': comment,
        'createdAt': createdAt.toIso8601String(),
      };
}
