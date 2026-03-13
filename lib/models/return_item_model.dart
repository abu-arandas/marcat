// lib/data/models/return_item_model.dart
//
// Mirrors public.return_items
// ┌────────────────────┬──────────────────────────────────────────────┬──────────┐
// │ column             │ pg type                                       │ nullable │
// ├────────────────────┼──────────────────────────────────────────────┼──────────┤
// │ id                 │ SERIAL PK                                     │ no       │
// │ return_id          │ INTEGER → returns(id) ON DELETE CASCADE       │ no       │
// │ sale_item_id       │ INTEGER → sale_items(id) ON DELETE RESTRICT   │ no       │
// │ quantity_returned  │ INTEGER CHECK > 0                             │ no       │
// │ reason             │ TEXT                                          │ yes      │
// └────────────────────┴──────────────────────────────────────────────┴──────────┘
// NOTE: return_items has NO timestamp columns.
// A DB trigger (trg_check_return_quantity) enforces that
// quantity_returned ≤ original sale_item.quantity.

class ReturnItemModel {
  const ReturnItemModel({
    required this.id,
    required this.returnId,
    required this.saleItemId,
    required this.quantityReturned,
    this.reason,
  });

  final int id;
  final int returnId;
  final int saleItemId;

  /// CHECK (quantity_returned > 0)
  /// DB trigger also ensures this does not exceed the original sold quantity.
  final int quantityReturned;

  final String? reason;

  factory ReturnItemModel.fromJson(Map<String, dynamic> json) {
    return ReturnItemModel(
      id: json['id'] as int,
      returnId: json['return_id'] as int,
      saleItemId: json['sale_item_id'] as int,
      quantityReturned: json['quantity_returned'] as int,
      reason: json['reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'return_id': returnId,
        'sale_item_id': saleItemId,
        'quantity_returned': quantityReturned,
        'reason': reason,
      };

  ReturnItemModel copyWith({
    int? id,
    int? returnId,
    int? saleItemId,
    int? quantityReturned,
    String? reason,
  }) {
    return ReturnItemModel(
      id: id ?? this.id,
      returnId: returnId ?? this.returnId,
      saleItemId: saleItemId ?? this.saleItemId,
      quantityReturned: quantityReturned ?? this.quantityReturned,
      reason: reason ?? this.reason,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ReturnItemModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ReturnItemModel(id: $id, saleItemId: $saleItemId, qty: $quantityReturned)';
}
