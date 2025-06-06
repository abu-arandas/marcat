class Category {
  String id;
  String name;
  String description;
  DateTime createdAt;
  DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });
  
  Category.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        description = map['description'],
        createdAt = map['createdAt'].toDate(),
        updatedAt = map['updatedAt'].toDate();
}

