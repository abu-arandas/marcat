import '../config/exports.dart';

class CategoryModel {
  String id, name, description;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory CategoryModel.fromJson(DocumentSnapshot doc) => CategoryModel(
        id: doc.id,
        name: doc['name'],
        description: doc['description'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
      };
}
