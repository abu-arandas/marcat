// lib/models/enums.dart
//
// Mirrors every PostgreSQL ENUM defined in database.sql.
// Each extension provides:
//   • dbValue  → the string stored in Postgres
//   • fromDb() → safe parser that falls back to a sensible default

// ignore_for_file: constant_identifier_names

// ─── public.user_role ────────────────────────────────────────────────────────
enum UserRole {
  admin,
  store_manager,
  salesperson,
  driver,
  customer,
}

extension UserRoleX on UserRole {
  String get dbValue => name; // 'admin' | 'store_manager' | ...

  static UserRole fromDb(String? v) => UserRole.values.firstWhere(
        (e) => e.name == v,
        orElse: () => UserRole.customer,
      );
}

// ─── public.loyalty_tier ─────────────────────────────────────────────────────
// NOTE: LoyaltyTier values use PascalCase intentionally — they match
// the Postgres ENUM values ('Bronze', 'Silver', etc.) stored in the DB.
enum LoyaltyTier {
  Bronze,
  Silver,
  Gold,
  Platinum,
}

extension LoyaltyTierX on LoyaltyTier {
  /// Database value stored in Postgres (PascalCase by DB design).
  String get dbValue => name; // 'Bronze' | 'Silver' | 'Gold' | 'Platinum'

  /// Human-readable label for UI display.
  String get displayLabel => name;

  static LoyaltyTier fromDb(String? v) => LoyaltyTier.values.firstWhere(
        (e) => e.name == v,
        orElse: () => LoyaltyTier.Bronze,
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
  String get dbValue => name; // 'pending' | 'paid' | 'shipped' | ...

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
  String get dbValue => name; // 'pending' | 'out_for_delivery' | ...

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
  String get dbValue => name; // 'requested' | 'approved' | ...

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
