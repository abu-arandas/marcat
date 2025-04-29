import '../config/exports.dart';

enum Roles { customer, admin, store }

extension RolesExtension on Roles {
  String fromEnum() {
    return toString().split('.').last;
  }

  static Roles fromJson(String role) {
    return Roles.values.firstWhere((e) => e.fromEnum() == role);
  }
}

class UserModel {
  String id, name, email;
  PhoneNumber? phoneNumber;
  Roles role;
  String? storeId;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.role,
    this.storeId,
  });

  bool hasRole(Roles role) => this.role == role;

  factory UserModel.fromJson(DocumentSnapshot doc) => UserModel(
        id: doc.id,
        name: doc['name'],
        email: doc['email'],
        phoneNumber: PhoneNumber.fromJson(doc['phoneNumber']),
        role: RolesExtension.fromJson(doc['role']),
        storeId: doc['storeId'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'role': role.fromEnum(),
        'storeId': storeId,
      };

  StoreModel? store(DocumentSnapshot doc) {
    if (storeId == null) return null;

    return StoreModel(
      id: storeId!,
      name: doc['name'],
      location: doc['location'],
    );
  }
}

class StoreModel {
  String id, name, location;

  StoreModel({
    required this.id,
    required this.name,
    required this.location,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) => StoreModel(
        id: json['id'] as String,
        name: json['name'] as String,
        location: json['location'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'location': location,
      };
}
