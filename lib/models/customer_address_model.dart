// lib/data/models/customer_address_model.dart
//
// Mirrors public.customer_addresses
// ┌──────────────┬───────────────────────────────┬──────────┐
// │ column       │ pg type                        │ nullable │
// ├──────────────┼───────────────────────────────┼──────────┤
// │ id           │ SERIAL PK                      │ no       │
// │ customer_id  │ UUID → customers(id)           │ no       │
// │ label        │ TEXT                           │ no       │
// │ full_address │ TEXT                           │ no       │
// │ city         │ TEXT                           │ yes      │
// │ country      │ TEXT                           │ yes      │
// │ is_default   │ BOOLEAN DEFAULT false          │ no       │
// │ latitude     │ DECIMAL(9,6)                   │ yes      │
// │ longitude    │ DECIMAL(9,6)                   │ yes      │
// │ created_at   │ TIMESTAMPTZ                    │ no       │
// │ updated_at   │ TIMESTAMPTZ                    │ no       │
// └──────────────┴───────────────────────────────┴──────────┘

class CustomerAddressModel {
  const CustomerAddressModel({
    required this.id,
    required this.customerId,
    required this.label,
    required this.fullAddress,
    this.city,
    this.country,
    required this.isDefault,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;

  /// UUID — references public.customers(id)
  final String customerId;

  final String label;
  final String fullAddress;
  final String? city;
  final String? country;
  final bool isDefault;

  /// DECIMAL(9,6)
  final double? latitude;

  /// DECIMAL(9,6)
  final double? longitude;

  final DateTime createdAt;
  final DateTime updatedAt;

  factory CustomerAddressModel.fromJson(Map<String, dynamic> json) {
    return CustomerAddressModel(
      id: json['id'] as int,
      customerId: json['customer_id'] as String,
      label: json['label'] as String,
      fullAddress: json['full_address'] as String,
      city: json['city'] as String?,
      country: json['country'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer_id': customerId,
        'label': label,
        'full_address': fullAddress,
        'city': city,
        'country': country,
        'is_default': isDefault,
        'latitude': latitude,
        'longitude': longitude,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  CustomerAddressModel copyWith({
    int? id,
    String? customerId,
    String? label,
    String? fullAddress,
    String? city,
    String? country,
    bool? isDefault,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerAddressModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      label: label ?? this.label,
      fullAddress: fullAddress ?? this.fullAddress,
      city: city ?? this.city,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CustomerAddressModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'CustomerAddressModel(id: $id, label: $label, default: $isDefault)';
}
