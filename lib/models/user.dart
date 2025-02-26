import 'package:phone_form_field/phone_form_field.dart';

class User {
  String id, name, email;
  PhoneNumber phoneNumber;
  String? password;
  Roles role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        name: json['first name'] + json['last name'] ?? '',
        email: json['email'] as String,
        phoneNumber: PhoneNumber.fromJson(json['phoneNumber']),
        password: json['password'],
        role: fromJson(json['role']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'first name': name.split(' ').first,
        'last name': name.split(' ').last,
        'email': email,
        'phoneNumber': phoneNumber.toJson(),
        'role': fromEnum(role),
      };
}

enum Roles { customer, admin, store }

String fromEnum(Roles role) {
  switch (role) {
    case Roles.customer:
      return 'customer';
    case Roles.admin:
      return 'admin';
    case Roles.store:
      return 'store';
  }
}

Roles fromJson(String role) {
  switch (role) {
    case 'customer':
      return Roles.customer;
    case 'admin':
      return Roles.admin;
    case 'store':
      return Roles.store;
    default:
      return Roles.customer;
  }
}
