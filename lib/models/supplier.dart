class Supplier {
  String id;
  String name;
  String contactPerson;
  String phone;
  String email;
  DateTime createdAt;
  DateTime updatedAt;

  Supplier({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  Supplier.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        contactPerson = map['contactPerson'],
        phone = map['phone'],
        email = map['email'],
        createdAt = map['createdAt'].toDate(),
        updatedAt = map['updatedAt'].toDate();
}