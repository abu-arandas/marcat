// lib/models/enums.dart

// ─── public.user_role ────────────────────────────────────────────────────────
enum UserRole {
  admin,
  store_manager,
  salesperson,
  driver,
  customer,
}

extension UserRoleX on UserRole {
  String get dbValue => name; // 'admin' | 'store_manager' | …

  static UserRole fromDb(String? v) => UserRole.values.firstWhere(
        (e) => e.name == v,
        orElse: () => UserRole.customer,
      );
}

// ─── public.loyalty_tier ─────────────────────────────────────────────────────
// DB stores PascalCase values: 'Bronze', 'Silver', 'Gold', 'Platinum'.
// Dart enum values are lowerCamelCase per lint rules.
// The dbValue getter handles the capitalisation for the wire format.
enum LoyaltyTier {
  bronze,
  silver,
  gold,
  platinum,
}

extension LoyaltyTierX on LoyaltyTier {
  /// Database value — capitalises first letter to match the Postgres ENUM.
  /// 'bronze' → 'Bronze', 'silver' → 'Silver', etc.
  String get dbValue {
    final s = name;
    return s[0].toUpperCase() + s.substring(1);
  }

  /// Human-readable label for UI display (same as DB value).
  String get displayLabel => dbValue;

  static LoyaltyTier fromDb(String? v) => LoyaltyTier.values.firstWhere(
        (e) => e.dbValue == v,
        orElse: () => LoyaltyTier.bronze,
      );
}

// ─── public.sale_channel ─────────────────────────────────────────────────────
enum SaleChannel {
  online,
  pos,
}

extension SaleChannelX on SaleChannel {
  String get dbValue => name; // 'online' | 'pos'

  static SaleChannel fromDb(String? v) => SaleChannel.values.firstWhere(
        (e) => e.name == v,
        orElse: () => SaleChannel.online,
      );
}

// ─── public.sale_status ──────────────────────────────────────────────────────
enum SaleStatus {
  pending,
  paid,
  shipped,
  delivered,
  cancelled,
}

extension SaleStatusX on SaleStatus {
  String get dbValue => name; // 'pending' | 'paid' | 'shipped' | …

  static SaleStatus fromDb(String? v) => SaleStatus.values.firstWhere(
        (e) => e.name == v,
        orElse: () => SaleStatus.pending,
      );
}

// ─── public.delivery_status ──────────────────────────────────────────────────
enum DeliveryStatus {
  pending,
  out_for_delivery,
  delivered,
  failed,
}

extension DeliveryStatusX on DeliveryStatus {
  String get dbValue => name; // 'pending' | 'out_for_delivery' | …

  static DeliveryStatus fromDb(String? v) => DeliveryStatus.values.firstWhere(
        (e) => e.name == v,
        orElse: () => DeliveryStatus.pending,
      );
}

// ─── public.return_status ────────────────────────────────────────────────────
enum ReturnStatus {
  requested,
  approved,
  received,
  refunded,
  rejected,
}

extension ReturnStatusX on ReturnStatus {
  String get dbValue => name; // 'requested' | 'approved' | …

  static ReturnStatus fromDb(String? v) => ReturnStatus.values.firstWhere(
        (e) => e.name == v,
        orElse: () => ReturnStatus.requested,
      );
}

// ─── public.product_status ───────────────────────────────────────────────────
enum ProductStatus {
  active,
  draft,
  archived,
}

extension ProductStatusX on ProductStatus {
  String get dbValue => name; // 'active' | 'draft' | 'archived'

  static ProductStatus fromDb(String? v) => ProductStatus.values.firstWhere(
        (e) => e.name == v,
        orElse: () => ProductStatus.active,
      );
}

// ─── public.commission_status ────────────────────────────────────────────────
enum CommissionStatus {
  pending,
  paid,
}

extension CommissionStatusX on CommissionStatus {
  String get dbValue => name; // 'pending' | 'paid'

  static CommissionStatus fromDb(String? v) =>
      CommissionStatus.values.firstWhere(
        (e) => e.name == v,
        orElse: () => CommissionStatus.pending,
      );
}
