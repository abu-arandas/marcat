// lib/controllers/cart_controller.dart
//
// Merges: cart_repository   (local cart state, persistence, coupon validation)
//         order_repository  (create online order, POS sale, order history)
//         return_repository (customer return requests, admin status updates)
//
// Delete those three repository files — everything lives here now.

import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'package:marcat/core/constants/supabase_constants.dart';
import 'package:marcat/core/error_handler.dart';
import 'package:marcat/models/cart_item_model.dart';
import 'package:marcat/models/return_model.dart';
import 'package:marcat/models/sale_item_model.dart';
import 'package:marcat/models/sale_model.dart';

const _cartPrefKey = 'marcat_cart_v1';

const _saleFields =
    'id, reference_number, channel, status, store_id, customer_id, staff_id, '
    'shipping_address_id, subtotal, discount_total, tax_total, shipping_cost, '
    'grand_total, offer_id, notes, created_at, updated_at';

const _saleItemFields =
    'id, sale_id, product_id, product_size_id, color_id, quantity, '
    'unit_price, discount_amount, total_price, '
    'products!product_id(name)';

const _returnFields =
    'id, sale_id, customer_id, status, reason, refund_amount, '
    'created_at, updated_at';

// ─────────────────────────────────────────────────────────────────────────────
// AppliedOffer  (value object — represents a validated coupon)
// ─────────────────────────────────────────────────────────────────────────────

class AppliedOffer {
  const AppliedOffer({
    required this.offerId,
    required this.offerName,
    required this.discountAmount,
    required this.message,
  });

  final int offerId;
  final String offerName;
  final double discountAmount;
  final String message;
}

// ─────────────────────────────────────────────────────────────────────────────
// CartController
// ─────────────────────────────────────────────────────────────────────────────

class CartController extends GetxController {
  sb.SupabaseClient get _client => sb.Supabase.instance.client;

  // ── Cart state ──────────────────────────────────────────────────────────────
  final items = <CartItemModel>[].obs;
  final appliedOffer = Rxn<AppliedOffer>();
  bool _cartLoaded = false;

  /// True while items are being restored from SharedPreferences.
  bool get isCartLoading => !_cartLoaded;

  // ── Checkout state ──────────────────────────────────────────────────────────
  final checkoutStep = 0.obs; // 0=bag 1=address 2=payment 3=confirm
  final selectedAddressId = Rxn<int>();
  final isPlacingOrder = false.obs;

  // ── Order history ───────────────────────────────────────────────────────────
  final orders = <SaleModel>[].obs;
  final totalOrders = 0.obs;
  final selectedOrder = Rxn<SaleModel>();
  final selectedOrderItems = <SaleItemModel>[].obs;
  final isLoadingOrders = false.obs;

  // ── Returns ─────────────────────────────────────────────────────────────────
  final returns = <ReturnModel>[].obs;
  final totalReturns = 0.obs;
  final isLoadingReturns = false.obs;

  // ── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _loadCart();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CART — LOCAL PERSISTENCE
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_cartPrefKey);
    if (stored != null) {
      try {
        final list = jsonDecode(stored) as List<dynamic>;
        items.value = list
            .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        items.value = [];
      }
    }
    _cartLoaded = true;
    update();
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cartPrefKey,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CART — OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Adds an item to the cart.  If the same [productSizeId] already exists
  /// its quantity is incremented instead of creating a duplicate row.
  void addItem(CartItemModel item) {
    final idx = items.indexWhere(
      (e) => e.productSizeId == item.productSizeId && e.colorId == item.colorId,
    );
    if (idx >= 0) {
      items[idx] = items[idx].copyWith(
        quantity: items[idx].quantity + item.quantity,
      );
    } else {
      items.add(item);
    }
    _saveCart();
  }

  void removeItem(int productSizeId, int colorId) {
    items.removeWhere(
      (e) => e.productSizeId == productSizeId && e.colorId == colorId,
    );
    _saveCart();
  }

  void updateQuantity(int productSizeId, int colorId, int qty) {
    if (qty <= 0) {
      removeItem(productSizeId, colorId);
      return;
    }
    final idx = items.indexWhere(
      (e) => e.productSizeId == productSizeId && e.colorId == colorId,
    );
    if (idx >= 0) {
      items[idx] = items[idx].copyWith(quantity: qty);
      _saveCart();
    }
  }

  void clearCart() {
    items.clear();
    appliedOffer.value = null;
    checkoutStep.value = 0;
    selectedAddressId.value = null;
    _saveCart();
  }

  // ── Totals ──────────────────────────────────────────────────────────────────
  double get subtotal =>
      items.fold(0.0, (s, i) => s + (i.unitPrice * i.quantity));

  double get discountTotal => appliedOffer.value?.discountAmount ?? 0.0;

  double get grandTotal =>
      (subtotal - discountTotal).clamp(0.0, double.infinity);

  int get itemCount => items.fold(0, (s, i) => s + i.quantity);

  bool get isEmpty => items.isEmpty;

  // ═══════════════════════════════════════════════════════════════════════════
  // COUPON / OFFER VALIDATION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Validates a coupon code against the apply_coupon RPC and stores the
  /// result in [appliedOffer].
  Future<AppliedOffer> applyCoupon(String couponCode, {int? storeId}) async {
    try {
      final result = await _client.rpc(
        SupabaseConstants.rpcApplyOfferToCart,
        params: {
          'p_coupon_code': couponCode,
          'p_cart_total': subtotal,
          'p_store_id': storeId,
          'p_product_ids': items.map((e) => e.productId).toList(),
        },
      );
      final map = result as Map<String, dynamic>;
      final offer = AppliedOffer(
        offerId: map['offer_id'] as int,
        offerName: map['offer_name'] as String,
        discountAmount: (map['discount_amount'] as num).toDouble(),
        message: map['message'] as String? ?? '',
      );
      appliedOffer.value = offer;
      return offer;
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  void removeCoupon() => appliedOffer.value = null;

  // ═══════════════════════════════════════════════════════════════════════════
  // CHECKOUT — NAVIGATION HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  void nextStep() => checkoutStep.value = (checkoutStep.value + 1).clamp(0, 3);
  void prevStep() => checkoutStep.value = (checkoutStep.value - 1).clamp(0, 3);
  void goToStep(int s) => checkoutStep.value = s.clamp(0, 3);

  // ═══════════════════════════════════════════════════════════════════════════
  // ORDERS — CREATE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Places an online order via the create_order_with_items RPC.
  /// Returns the new sale id.
  Future<int> createOrder({
    required String channel,
    required int storeId,
    required String customerId,
    required int shippingAddressId,
    required double subtotalAmt,
    required double discountTotalAmt,
    required double taxTotalAmt,
    required double shippingCostAmt,
    int? offerId,
    required List<CartItemModel> cartItems,
  }) async {
    isPlacingOrder.value = true;
    try {
      final response = await _client.rpc(
        SupabaseConstants.rpcCreateOrderWithItems,
        params: {
          'p_channel': channel,
          'p_store_id': storeId,
          'p_customer_id': customerId,
          'p_shipping_address_id': shippingAddressId,
          'p_subtotal': subtotalAmt,
          'p_discount_total': discountTotalAmt,
          'p_tax_total': taxTotalAmt,
          'p_shipping_cost': shippingCostAmt,
          'p_offer_id': offerId,
          'p_items': CartItemModel.encodeForRpc(cartItems),
        },
      );
      final row = (response as List<dynamic>).first as Map<String, dynamic>;
      final saleId = row['sale_id'] as int;

      // If an offer was used, bump its usage counter.
      if (offerId != null) {
        await _incrementOfferUsage(offerId);
      }
      clearCart();
      return saleId;
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    } finally {
      isPlacingOrder.value = false;
    }
  }

  /// Processes a POS sale via the process_pos_sale RPC.
  /// Returns the new sale id.
  Future<int> processPosSale({
    required String staffId,
    required int storeId,
    required double taxTotalAmt,
    String? customerId,
    int? offerId,
    required List<CartItemModel> cartItems,
  }) async {
    isPlacingOrder.value = true;
    try {
      final response = await _client.rpc(
        SupabaseConstants.rpcProcessPosSale,
        params: {
          'p_staff_id': staffId,
          'p_store_id': storeId,
          'p_tax_total': taxTotalAmt,
          'p_customer_id': customerId,
          'p_offer_id': offerId,
          'p_items': CartItemModel.encodeForRpc(cartItems),
        },
      );
      final row = (response as List<dynamic>).first as Map<String, dynamic>;
      final saleId = row['sale_id'] as int;
      if (offerId != null) await _incrementOfferUsage(offerId);
      clearCart();
      return saleId;
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    } finally {
      isPlacingOrder.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ORDERS — READ
  // ═══════════════════════════════════════════════════════════════════════════

  /// Paginated order list.  Populates [orders] and [totalOrders] when
  /// [updateState] is true (default).
  Future<(List<SaleModel>, int)> fetchOrders({
    int page = 0,
    int pageSize = SupabaseConstants.defaultPageSize,
    String? customerId,
    String? status,
    int? storeId,
    String? channel,
    DateTime? fromDate,
    DateTime? toDate,
    bool updateState = true,
  }) async {
    if (updateState) isLoadingOrders.value = true;
    try {
      var q = _client.from(SupabaseConstants.sales).select(_saleFields);

      if (customerId != null) q = q.eq('customer_id', customerId);
      if (status != null) q = q.eq('status', status);
      if (storeId != null) q = q.eq('store_id', storeId);
      if (channel != null) q = q.eq('channel', channel);
      if (fromDate != null) q = q.gte('created_at', fromDate.toIso8601String());
      if (toDate != null) q = q.lte('created_at', toDate.toIso8601String());

      final from = page * pageSize;
      final res = await q
          .order('created_at', ascending: false)
          .range(from, from + pageSize - 1)
          .count(sb.CountOption.exact);

      final items = (res.data as List<dynamic>)
          .map((e) => SaleModel.fromJson(e as Map<String, dynamic>))
          .toList();

      if (updateState) {
        orders.assignAll(items);
        totalOrders.value = res.count;
      }
      return (items, res.count);
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    } finally {
      if (updateState) isLoadingOrders.value = false;
    }
  }

  Future<SaleModel> fetchOrderById(int saleId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.sales)
          .select(_saleFields)
          .eq('id', saleId)
          .single();
      final order = SaleModel.fromJson(data);
      selectedOrder.value = order;
      return order;
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  Future<List<SaleItemModel>> fetchOrderItems(int saleId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.saleItems)
          .select(_saleItemFields)
          .eq('sale_id', saleId);
      final items = (data as List<dynamic>)
          .map((e) => SaleItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
      selectedOrderItems.assignAll(items);
      return items;
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  /// Loads full order detail (order row + line items) in one batch.
  Future<void> loadOrderDetail(int saleId) async {
    isLoadingOrders.value = true;
    try {
      await Future.wait([
        fetchOrderById(saleId),
        fetchOrderItems(saleId),
      ]);
    } finally {
      isLoadingOrders.value = false;
    }
  }

  // ─── Admin: order mutations ──────────────────────────────────────────────────

  /// Updates the order status and appends a status-history record.
  Future<void> updateOrderStatus(
    int saleId,
    String newStatus, {
    String? changedBy,
    String? note,
  }) async {
    try {
      await _client
          .from(SupabaseConstants.sales)
          .update({'status': newStatus}).eq('id', saleId);
      await _client.from(SupabaseConstants.saleStatusHistory).insert({
        'sale_id': saleId,
        'new_status': newStatus,
        if (changedBy != null) 'changed_by': changedBy,
        if (note != null) 'note': note,
      });
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // RETURNS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Paginated returns list.
  Future<void> fetchReturns({
    int page = 0,
    int pageSize = SupabaseConstants.defaultPageSize,
    String? status,
    String? customerId,
  }) async {
    isLoadingReturns.value = true;
    try {
      var q = _client.from(SupabaseConstants.returns).select(_returnFields);
      if (status != null) q = q.eq('status', status);
      if (customerId != null) q = q.eq('customer_id', customerId);

      final from = page * pageSize;
      final res = await q
          .order('id', ascending: false)
          .range(from, from + pageSize - 1)
          .count(sb.CountOption.exact);

      returns.assignAll(
        (res.data as List<dynamic>)
            .map((e) => ReturnModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      totalReturns.value = res.count;
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    } finally {
      isLoadingReturns.value = false;
    }
  }

  /// Submits a return request for a customer.  Returns the new return id.
  Future<int> createReturn({
    required int saleId,
    required String customerId,
    required String reason,
    required List<Map<String, dynamic>> returnItems,
  }) async {
    try {
      final result = await _client
          .from(SupabaseConstants.returns)
          .insert({
            'sale_id': saleId,
            'customer_id': customerId,
            'reason': reason,
            'status': 'requested',
            'refund_amount': 0,
          })
          .select('id')
          .single();
      final returnId = result['id'] as int;

      // Insert each return line item separately.
      for (final item in returnItems) {
        await _client.from(SupabaseConstants.returnItems).insert({
          ...item,
          'return_id': returnId,
        });
      }
      return returnId;
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  /// Admin: update return status (requested → approved → received → refunded).
  Future<void> updateReturnStatus(int returnId, String newStatus) async {
    try {
      await _client
          .from(SupabaseConstants.returns)
          .update({'status': newStatus}).eq('id', returnId);
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  Future<List<Map<String, dynamic>>> fetchReturnItems(int returnId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.returnItems)
          .select('id, return_id, sale_item_id, quantity_returned, reason')
          .eq('return_id', returnId);
      return (data as List<dynamic>).cast<Map<String, dynamic>>();
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _incrementOfferUsage(int offerId) async {
    try {
      await _client.rpc(
        SupabaseConstants.rpcIncrementOfferUsage,
        params: {'p_offer_id': offerId},
      );
    } catch (_) {
      // Non-fatal — offer usage counter is cosmetic, not transactional.
    }
  }
}
