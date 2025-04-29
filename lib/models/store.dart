
class Store {
    final String id;
    final String name;
    final String address;
    final String phone;
    final DateTime createdAt;
    final DateTime updatedAt;

    Store({
        required this.id,
        required this.name,
        required this.address,
        required this.phone,
        required this.createdAt,
        required this.updatedAt,
    });

    Store.fromMap(Map<String, dynamic> map)
        : id = map['id'],
          name = map['name'],
          address = map['address'],
          phone = map['phone'],
          createdAt = map['createdAt'].toDate(),
          updatedAt = map['updatedAt'].toDate();
}
