// lib/models/delivery_model.dart
//
// Mirrors public.deliveries
// ┌─────────────────┬─────────────────────────────────────────────┬──────────┐
// │ column          │ pg type                                      │ nullable │
// ├─────────────────┼─────────────────────────────────────────────┼──────────┤
// │ id              │ SERIAL PK                                    │ no       │
// │ sale_id         │ INTEGER → sales(id) ON DELETE CASCADE        │ no       │
// │ driver_id       │ UUID → staff(id) ON DELETE SET NULL          │ yes      │
// │ status          │ public.delivery_status DEFAULT 'pending'     │ no       │
// │ tracking_number │ TEXT                                         │ yes      │
// │ proof_image_url │ TEXT                                         │ yes      │
// │ delivered_at    │ TIMESTAMPTZ                                  │ yes      │
// │ created_at      │ TIMESTAMPTZ                                  │ no       │
// │ updated_at      │ TIMESTAMPTZ                                  │ no       │
// └─────────────────┴─────────────────────────────────────────────┴──────────┘

import 'enums.dart';

class DeliveryModel {
  const DeliveryModel({
    required this.id,
    required this.saleId,
    this.driverId,
    required this.status,
    this.trackingNumber,
    this.proofImageUrl,
    this.deliveredAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int saleId;

  /// UUID — references public.staff(id); NULL until a driver is assigned.
  final String? driverId;

  final DeliveryStatus status;
  final String? trackingNumber;
  final String? proofImageUrl;

  /// Non-null once status = 'delivered'.
  final DateTime? deliveredAt;

  final DateTime createdAt;
  final DateTime updatedAt;

  factory DeliveryModel.fromJson(Map<String, dynamic> json) {
    return DeliveryModel(
      id: json['id'] as int,
      saleId: json['sale_id'] as int,
      driverId: json['driver_id'] as String?,
      status: DeliveryStatusX.fromDb(json['status'] as String?),
      trackingNumber: json['tracking_number'] as String?,
      proofImageUrl: json['proof_image_url'] as String?,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sale_id': saleId,
        'driver_id': driverId,
        'status': status.dbValue,
        'tracking_number': trackingNumber,
        'proof_image_url': proofImageUrl,
        'delivered_at': deliveredAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  DeliveryModel copyWith({
    int? id,
    int? saleId,
    String? driverId,
    DeliveryStatus? status,
    String? trackingNumber,
    String? proofImageUrl,
    DateTime? deliveredAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeliveryModel(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      driverId: driverId ?? this.driverId,
      status: status ?? this.status,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      proofImageUrl: proofImageUrl ?? this.proofImageUrl,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DeliveryModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'DeliveryModel(id: $id, saleId: $saleId, status: $status)';
}
