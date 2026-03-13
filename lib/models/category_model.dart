// lib/data/models/category_model.dart
//
// Mirrors public.categories  (self-referencing tree via parent_id)
// ┌───────────┬──────────────────────────────┬──────────┐
// │ column    │ pg type                       │ nullable │
// ├───────────┼──────────────────────────────┼──────────┤
// │ id        │ SERIAL PK                     │ no       │
// │ name      │ TEXT                          │ no       │
// │ parent_id │ INTEGER → categories(id)      │ yes      │
// │ image_url │ TEXT                          │ yes      │
// │ is_active │ BOOLEAN DEFAULT true          │ no       │
// └───────────┴──────────────────────────────┴──────────┘
// NOTE: categories has no created_at / updated_at columns.

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    this.parentId,
    this.imageUrl,
    required this.isActive,
  });

  final int id;
  final String name;

  /// NULL → root category; non-null → child category.
  final int? parentId;

  final String? imageUrl;
  final bool isActive;

  bool get isRoot => parentId == null;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      parentId: json['parent_id'] as int?,
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'parent_id': parentId,
        'image_url': imageUrl,
        'is_active': isActive,
      };

  CategoryModel copyWith({
    int? id,
    String? name,
    int? parentId,
    String? imageUrl,
    bool? isActive,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CategoryModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'CategoryModel(id: $id, name: $name, parentId: $parentId)';
}
