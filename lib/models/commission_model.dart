// lib/data/models/commission_model.dart
//
// Mirrors public.commissions
// ┌────────────┬──────────────────────────────────────────────────┬──────────┐
// │ column     │ pg type                                           │ nullable │
// ├────────────┼──────────────────────────────────────────────────┼──────────┤
// │ id         │ SERIAL PK                                         │ no       │
// │ staff_id   │ UUID → staff(id) ON DELETE CASCADE                │ no       │
// │ sale_id    │ INTEGER → sales(id) ON DELETE CASCADE             │ no       │
// │ amount     │ DECIMAL(10,2) CHECK >= 0                          │ no       │
// │ status     │ public.commission_status DEFAULT 'pending'        │ no       │
// │ paid_at    │ TIMESTAMPTZ                                       │ yes      │
// │ created_at │ TIMESTAMPTZ                                       │ no       │
// └────────────┴──────────────────────────────────────────────────┴──────────┘
// NOTE: commissions has NO updated_at column.

import 'enums.dart';

class CommissionModel {
  const CommissionModel({
    required this.id,
    required this.staffId,
    required this.saleId,
    required this.amount,
    required this.status,
    this.paidAt,
    required this.createdAt,
  });

  final int id;

  /// UUID — references public.staff(id).
  final String staffId;

  final int saleId;

  /// DECIMAL(10,2) CHECK (amount >= 0)
  final double amount;

  final CommissionStatus status;

  /// Non-null once status = 'paid'.
  final DateTime? paidAt;

  final DateTime createdAt;

  factory CommissionModel.fromJson(Map<String, dynamic> json) {
    return CommissionModel(
      id: json['id'] as int,
      staffId: json['staff_id'] as String,
      saleId: json['sale_id'] as int,
      amount: (json['amount'] as num).toDouble(),
      status: CommissionStatusX.fromDb(json['status'] as String?),
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'staff_id': staffId,
        'sale_id': saleId,
        'amount': amount,
        'status': status.dbValue,
        'paid_at': paidAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  CommissionModel copyWith({
    int? id,
    String? staffId,
    int? saleId,
    double? amount,
    CommissionStatus? status,
    DateTime? paidAt,
    DateTime? createdAt,
  }) {
    return CommissionModel(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      saleId: saleId ?? this.saleId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      paidAt: paidAt ?? this.paidAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CommissionModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'CommissionModel(id: $id, staffId: $staffId, amount: $amount, status: $status)';
}
