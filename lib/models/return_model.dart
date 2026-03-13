// lib/data/models/return_model.dart
//
// Mirrors public.returns
// ┌───────────────┬──────────────────────────────────────────────┬──────────┐
// │ column        │ pg type                                       │ nullable │
// ├───────────────┼──────────────────────────────────────────────┼──────────┤
// │ id            │ SERIAL PK                                     │ no       │
// │ sale_id       │ INTEGER → sales(id) ON DELETE RESTRICT        │ no       │
// │ customer_id   │ UUID → customers(id) ON DELETE RESTRICT       │ no       │
// │ status        │ public.return_status DEFAULT 'requested'      │ no       │
// │ reason        │ TEXT                                          │ yes      │
// │ refund_amount │ DECIMAL(12,2) CHECK >= 0                      │ yes      │
// │ created_at    │ TIMESTAMPTZ                                   │ no       │
// │ updated_at    │ TIMESTAMPTZ                                   │ no       │
// └───────────────┴──────────────────────────────────────────────┴──────────┘

import 'enums.dart';

class ReturnModel {
  const ReturnModel({
    required this.id,
    required this.saleId,
    required this.customerId,
    required this.status,
    this.reason,
    this.refundAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int saleId;

  /// UUID — references public.customers(id).
  final String customerId;

  final ReturnStatus status;
  final String? reason;

  /// DECIMAL(12,2) — set once refund is processed; null until then.
  final double? refundAmount;

  final DateTime createdAt;
  final DateTime updatedAt;

  factory ReturnModel.fromJson(Map<String, dynamic> json) {
    return ReturnModel(
      id: json['id'] as int,
      saleId: json['sale_id'] as int,
      customerId: json['customer_id'] as String,
      status: ReturnStatusX.fromDb(json['status'] as String?),
      reason: json['reason'] as String?,
      refundAmount: (json['refund_amount'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sale_id': saleId,
        'customer_id': customerId,
        'status': status.dbValue,
        'reason': reason,
        'refund_amount': refundAmount,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  ReturnModel copyWith({
    int? id,
    int? saleId,
    String? customerId,
    ReturnStatus? status,
    String? reason,
    double? refundAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReturnModel(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      customerId: customerId ?? this.customerId,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      refundAmount: refundAmount ?? this.refundAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ReturnModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ReturnModel(id: $id, saleId: $saleId, status: $status)';
}
