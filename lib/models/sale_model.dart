// lib/data/models/sale_model.dart
//
// Mirrors public.sales  (covers both online orders and POS tickets)
// ┌──────────────────────┬─────────────────────────────────────────────┬──────────┐
// │ column               │ pg type                                      │ nullable │
// ├──────────────────────┼─────────────────────────────────────────────┼──────────┤
// │ id                   │ SERIAL PK                                    │ no       │
// │ reference_number     │ TEXT UNIQUE                                  │ no       │
// │ channel              │ public.sale_channel                          │ no       │
// │ store_id             │ INTEGER → stores(id)                         │ yes      │
// │ customer_id          │ UUID → customers(id)                         │ yes      │
// │ staff_id             │ UUID → staff(id)                             │ yes      │
// │ offer_id             │ INTEGER → offers(id)                         │ yes      │
// │ shipping_address_id  │ INTEGER → customer_addresses(id)             │ yes      │
// │ status               │ public.sale_status DEFAULT 'pending'         │ no       │
// │ subtotal             │ DECIMAL(12,2) CHECK >= 0                     │ no       │
// │ discount_total       │ DECIMAL(12,2) CHECK >= 0  DEFAULT 0          │ no       │
// │ tax_total            │ DECIMAL(12,2) CHECK >= 0  DEFAULT 0          │ no       │
// │ shipping_cost        │ DECIMAL(12,2) CHECK >= 0  DEFAULT 0          │ no       │
// │ grand_total          │ DECIMAL(12,2) CHECK >= 0                     │ no       │
// │ notes                │ TEXT                                         │ yes      │
// │ created_at           │ TIMESTAMPTZ                                  │ no       │
// │ updated_at           │ TIMESTAMPTZ                                  │ no       │
// └──────────────────────┴─────────────────────────────────────────────┴──────────┘

import 'enums.dart';

class SaleModel {
  const SaleModel({
    required this.id,
    required this.referenceNumber,
    required this.channel,
    this.storeId,
    this.customerId,
    this.staffId,
    this.offerId,
    this.shippingAddressId,
    required this.status,
    required this.subtotal,
    required this.discountTotal,
    required this.taxTotal,
    required this.shippingCost,
    required this.grandTotal,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String referenceNumber;
  final SaleChannel channel;
  final int? storeId;
  final String? customerId;
  final String? staffId;
  final int? offerId;
  final int? shippingAddressId;
  final SaleStatus status;

  /// DECIMAL(12,2)
  final double subtotal;
  final double discountTotal;
  final double taxTotal;
  final double shippingCost;
  final double grandTotal;

  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      id: json['id'] as int,
      referenceNumber: json['reference_number'] as String,
      channel: SaleChannelX.fromDb(json['channel'] as String?),
      storeId: json['store_id'] as int?,
      customerId: json['customer_id'] as String?,
      staffId: json['staff_id'] as String?,
      offerId: json['offer_id'] as int?,
      shippingAddressId: json['shipping_address_id'] as int?,
      status: SaleStatusX.fromDb(json['status'] as String?),
      subtotal: (json['subtotal'] as num).toDouble(),
      discountTotal: (json['discount_total'] as num?)?.toDouble() ?? 0.0,
      taxTotal: (json['tax_total'] as num?)?.toDouble() ?? 0.0,
      shippingCost: (json['shipping_cost'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['grand_total'] as num).toDouble(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reference_number': referenceNumber,
        'channel': channel.dbValue,
        'store_id': storeId,
        'customer_id': customerId,
        'staff_id': staffId,
        'offer_id': offerId,
        'shipping_address_id': shippingAddressId,
        'status': status.dbValue,
        'subtotal': subtotal,
        'discount_total': discountTotal,
        'tax_total': taxTotal,
        'shipping_cost': shippingCost,
        'grand_total': grandTotal,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  SaleModel copyWith({
    int? id,
    String? referenceNumber,
    SaleChannel? channel,
    int? storeId,
    String? customerId,
    String? staffId,
    int? offerId,
    int? shippingAddressId,
    SaleStatus? status,
    double? subtotal,
    double? discountTotal,
    double? taxTotal,
    double? shippingCost,
    double? grandTotal,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SaleModel(
      id: id ?? this.id,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      channel: channel ?? this.channel,
      storeId: storeId ?? this.storeId,
      customerId: customerId ?? this.customerId,
      staffId: staffId ?? this.staffId,
      offerId: offerId ?? this.offerId,
      shippingAddressId: shippingAddressId ?? this.shippingAddressId,
      status: status ?? this.status,
      subtotal: subtotal ?? this.subtotal,
      discountTotal: discountTotal ?? this.discountTotal,
      taxTotal: taxTotal ?? this.taxTotal,
      shippingCost: shippingCost ?? this.shippingCost,
      grandTotal: grandTotal ?? this.grandTotal,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SaleModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'SaleModel(id: $id, ref: $referenceNumber, status: $status)';
}
