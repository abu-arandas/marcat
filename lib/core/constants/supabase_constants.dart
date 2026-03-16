// lib/core/constants/supabase_constants.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SupabaseConstants
// ─────────────────────────────────────────────────────────────────────────────

class SupabaseConstants {
  SupabaseConstants._();

  static String get url {
    // --dart-define value takes precedence (release / CI builds).
    const buildTimeUrl = String.fromEnvironment('SUPABASE_URL');
    if (buildTimeUrl.isNotEmpty) return buildTimeUrl;
    // Fallback: .env for local debug.
    return dotenv.env['SUPABASE_URL'] ?? '';
  }

  static String get anonKey {
    const buildTimeKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (buildTimeKey.isNotEmpty) return buildTimeKey;
    return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  }

  // ── Storage buckets ───────────────────────────────────────────────────────
  static const String productImagesBucket = 'product-images';
  static const String avatarsBucket = 'avatars';

  // ── Tables ────────────────────────────────────────────────────────────────
  static const String profiles = 'profiles';
  static const String customers = 'customers';
  static const String customerAddresses = 'customer_addresses';
  static const String stores = 'stores';
  static const String categories = 'categories';
  static const String brands = 'brands';
  static const String products = 'products';
  static const String productColors = 'product_colors';
  static const String productSizes = 'product_sizes';
  static const String productImages = 'product_images';
  static const String storeProducts = 'store_products';
  static const String inventory = 'store_inventory';
  static const String staff = 'staff';
  static const String staffAssignments = 'staff_assignments';
  static const String offers = 'offers';
  static const String offerProducts = 'offer_products';
  static const String offerCategories = 'offer_categories';
  static const String offerStores = 'offer_stores';
  static const String sales = 'sales';
  static const String saleStatusHistory = 'sale_status_history';
  static const String saleItems = 'sale_items';
  static const String payments = 'payments';
  static const String commissions = 'commissions';
  static const String deliveries = 'deliveries';
  static const String deliveryStatusHistory = 'delivery_status_history';
  static const String returns = 'returns';
  static const String returnItems = 'return_items';
  static const String loyaltyTransactions = 'loyalty_transactions';
  // DB table is 'wishlist' (no trailing 's')
  static const String wishlists = 'wishlist';

  // ── Views ─────────────────────────────────────────────────────────────────
  static const String vCustomerSummary = 'v_customer_summary';
  static const String vStoreInventory = 'v_store_inventory';
  static const String vLowStockAlert = 'v_low_stock_alert';
  static const String vSalesSummary = 'v_sales_summary';
  static const String vCommissionReport = 'v_commission_report';
  static const String vActiveDeliveries = 'v_active_deliveries';

  // ── RPC functions ─────────────────────────────────────────────────────────
  static const String rpcCreateOrderWithItems = 'create_order_with_items';
  static const String rpcSetDefaultAddress = 'set_default_address';
  static const String rpcIncrementOfferUsage = 'increment_offer_usage';
  static const String rpcApplyOfferToCart = 'apply_coupon';
  static const String rpcProcessPosSale = 'process_pos_sale';
  static const String rpcApproveCommission = 'approve_commission';
  static const String rpcGetProductAvailability = 'get_product_availability';
  static const String rpcVerifyPosPin = 'verify_pos_pin';
  static const String rpcSetPosPin = 'set_pos_pin';
  static const String rpcAdjustLoyaltyPoints = 'adjust_loyalty_points';

  // ── Role name constants ───────────────────────────────────────────────────
  static const String roleAdmin = 'admin';
  static const String roleStoreManager = 'store_manager';
  static const String roleSalesperson = 'salesperson';
  static const String roleCustomer = 'customer';
  static const String roleDriver = 'driver';

  // ── Pagination ────────────────────────────────────────────────────────────
  static const int defaultPageSize = 20;

  // ── Business rules ────────────────────────────────────────────────────────
  static const String defaultCurrency = 'JOD';
  static const int loyaltyPointsPerJod = 1; // 1 JOD spent  → 1 point
  static const int loyaltyRedeemRate = 100; // 100 points   → 1 JOD discount
}
