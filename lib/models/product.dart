import '../config/exports.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String? mainImageUrl;
  final String? sku;
  final List<VariantModel> variants;
  final String storeId;
  final double? discountPercentage;
  final bool isFeatured;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.mainImageUrl,
    this.sku,
    required this.variants,
    required this.storeId,
    this.isFeatured = false,
    this.discountPercentage,
  });

  factory ProductModel.fromJson(DocumentSnapshot doc) => ProductModel(
        id: doc.id,
        name: doc['name'],
        description: doc['description'],
        category: doc['category'],
        mainImageUrl: doc['mainImageUrl'],
        sku: doc['sku'],
        variants: (doc['variants'] as List<dynamic>)
            .map((e) => VariantModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        storeId: doc['storeId'],
        discountPercentage: doc['discountPercentage'],
        isFeatured: doc['isFeatured'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'category': category,
        'mainImageUrl': mainImageUrl,
        'sku': sku,
        'variants': List<dynamic>.from(variants.map((x) => x.toJson())),
        'storeId': storeId,
        'discountPercentage': discountPercentage,
        'isFeatured': isFeatured,
      };

  double getFinalPrice(double price) {
    if (discountPercentage != null && discountPercentage! > 0) {
      return price * (1 - discountPercentage! / 100);
    }
    return price;
  }
}

class VariantModel {
  final String? sku;
  final List<ColorVariantModel> colors;
  final double price;

  VariantModel({
    required this.colors,
    required this.price,
    this.sku,
  });

  factory VariantModel.fromJson(Map<String, dynamic> json) => VariantModel(
        colors: (json['colors'] as List<dynamic>)
            .map((e) => ColorVariantModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        price: (json['price'] as num).toDouble(),
        sku: json['sku'],
      );

  Map<String, dynamic> toJson() => {
        'colors': colors.map((e) => e.toJson()).toList(),
        'price': price,
        'sku': sku,
      };
}

class ColorVariantModel {
  String color;
  List<SizeVariantModel> sizes;
  List<String> images;

  ColorVariantModel({
    required this.color,
    required this.sizes,
    required this.images,
  });

  factory ColorVariantModel.fromJson(Map<String, dynamic> json) =>
      ColorVariantModel(
        color: json['color'] as String,
        sizes: (json['sizes'] as List<dynamic>)
            .map((e) => SizeVariantModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        images: json['images'] as List<String>,
      );

  Map<String, dynamic> toJson() => {
        'color': color,
        'sizes': sizes.map((e) => e.toJson()).toList(),
        'images': images,
      };
}

class SizeVariantModel {
  String size;
  int stock;

  SizeVariantModel({
    required this.size,
    required this.stock,
  });

  factory SizeVariantModel.fromJson(Map<String, dynamic> json) =>
      SizeVariantModel(
        size: json['size'] as String,
        stock: json['stock'] as int,
      );

  Map<String, dynamic> toJson() => {
        'size': size,
        'stock': stock,
      };
}
