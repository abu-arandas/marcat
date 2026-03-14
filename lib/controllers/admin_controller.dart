// lib/controllers/admin_controller.dart
//
// Merges: admin_staff_controller  (staff list + create staff member)
//         staff_repository        (fetchStaff, createStaffMember, verifyPosPin)
//         commission_repository   (fetchCommissions, approveCommission)
//         store_repository        (CRUD stores, assign/remove products)
//         inventory_repository    (fetchInventory, update quantities)

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'package:marcat/controllers/auth_controller.dart';
import 'package:marcat/core/constants/supabase_constants.dart';
import 'package:marcat/core/error_handler.dart';
import 'package:marcat/models/commission_model.dart';
import 'package:marcat/models/enums.dart';
import 'package:marcat/models/inventory_model.dart';
import 'package:marcat/models/staff_model.dart';
import 'package:marcat/models/store_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdminController
// ─────────────────────────────────────────────────────────────────────────────

class AdminController extends GetxController {
  sb.SupabaseClient get _client => sb.Supabase.instance.client;

  // ── Staff ───────────────────────────────────────────────────────────────────
  final staffList = <StaffModel>[].obs;
  final totalStaff = 0.obs;
  final isLoadingStaff = false.obs;

  // ── Commissions ─────────────────────────────────────────────────────────────
  final commissions = <CommissionModel>[].obs;
  final totalCommissions = 0.obs;
  final isLoadingCommissions = false.obs;

  // ── Stores ──────────────────────────────────────────────────────────────────
  final stores = <StoreModel>[].obs;
  final isLoadingStores = false.obs;

  // ── Inventory ───────────────────────────────────────────────────────────────
  final inventory = <InventoryModel>[].obs;
  final totalInventory = 0.obs;
  final isLoadingInventory = false.obs;

  // ── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    // FIX: onInit was calling fetchStaff() and fetchStores() unconditionally
    // for every user including customers. Since AdminController is lazy-put
    // with fenix:true it only instantiates when first accessed, but once it
    // is accessed (e.g. by the POS PIN screen checking isAdmin) it would fire
    // two expensive Supabase queries for non-admin users who have no RLS
    // permission, causing PostgrestExceptions in the log.
    //
    // Guard: only prefetch if the current user actually has admin/store_manager
    // or salesperson rights.
    final auth = Get.find<AuthController>().state.value;
    if (auth.isAdmin || auth.isStoreManager) {
      fetchStaff();
      fetchStores();
    } else if (auth.isSalesperson) {
      // Salesperson only needs the store list for context.
      fetchStores();
    }
    // Customers and drivers never use AdminController data — no prefetch.
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STAFF
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> fetchStaff({
    int page = 0,
    int pageSize = SupabaseConstants.defaultPageSize,
  }) async {
    isLoadingStaff.value = true;
    try {
      final from = page * pageSize;
      final res = await _client
          .from(SupabaseConstants.staff)
          .select()
          .range(from, from + pageSize - 1)
          .count(sb.CountOption.exact);

      staffList.assignAll(
        (res.data as List<dynamic>)
            .map((e) => StaffModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      totalStaff.value = res.count;
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    } finally {
      isLoadingStaff.value = false;
    }
  }

  /// Creates a staff member via the `create-staff` Edge Function.
  ///
  /// The Edge Function runs with the service_role key so it can call
  /// auth.admin.createUser and insert into public.staff atomically on the
  /// server side — the Flutter client never touches the service_role key.
  Future<bool> createStaffMember({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required int storeId,
    required UserRole role,
  }) async {
    try {
      final res = await _client.functions.invoke(
        'create-staff',
        body: {
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          'store_id': storeId,
          'role': role.dbValue,
        },
      );
      final staff = StaffModel.fromJson(res.data as Map<String, dynamic>);
      staffList.add(staff);
      totalStaff.value++;
      return true;
    } on sb.FunctionException catch (e, s) {
      throw ErrorHandler.handle(
        AppException(message: 'Edge Function error: ${e.reasonPhrase}'),
        s,
      );
    } catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  /// Verifies a 4-digit POS PIN via the verify_pos_pin RPC.
  Future<bool> verifyPosPin(String staffId, String pin) async {
    try {
      final result = await _client.rpc(
        SupabaseConstants.rpcVerifyPosPin,
        params: {'p_staff_id': staffId, 'p_pin': pin},
      );
      return result as bool;
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  /// Sets a new POS PIN for a staff member via the set_pos_pin RPC.
  Future<void> setPosPin(String staffId, String pin) async {
    try {
      await _client.rpc(
        SupabaseConstants.rpcSetPosPin,
        params: {'p_staff_id': staffId, 'p_pin': pin},
      );
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // COMMISSIONS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> fetchCommissions({
    int page = 0,
    int pageSize = SupabaseConstants.defaultPageSize,
    String? status,
    String? salespersonId,
  }) async {
    isLoadingCommissions.value = true;
    try {
      var q = _client.from(SupabaseConstants.vCommissionReport).select('*');
      if (status != null) q = q.eq('status', status);
      if (salespersonId != null) q = q.eq('staff_id', salespersonId);

      final from = page * pageSize;
      final res = await q
          .order('id', ascending: false)
          .range(from, from + pageSize - 1)
          .count(sb.CountOption.exact);

      commissions.assignAll(
        (res.data as List<dynamic>)
            .map((e) => CommissionModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      totalCommissions.value = res.count;
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    } finally {
      isLoadingCommissions.value = false;
    }
  }

  /// Approves (and optionally marks as paid) a commission record via RPC.
  Future<void> approveCommission(
    int commissionId,
    String approvedBy, {
    bool markPaid = false,
  }) async {
    try {
      await _client.rpc(
        SupabaseConstants.rpcApproveCommission,
        params: {
          'p_commission_id': commissionId,
          'p_approved_by': approvedBy,
          'p_mark_paid': markPaid,
        },
      );
      // Reflect the change locally without a round-trip.
      final idx = commissions.indexWhere((c) => c.id == commissionId);
      if (idx >= 0) {
        commissions[idx] = commissions[idx].copyWith(
          status: markPaid ? CommissionStatus.paid : CommissionStatus.pending,
          paidAt: markPaid ? DateTime.now() : null,
        );
      }
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STORES
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> fetchStores({bool activeOnly = false}) async {
    isLoadingStores.value = true;
    try {
      var q = _client.from(SupabaseConstants.stores).select(
          'id, name, location, phone, is_active, created_at, updated_at');
      if (activeOnly) q = q.eq('is_active', true);
      final data = await q.order('name');
      stores.assignAll(
        (data as List<dynamic>)
            .map((e) => StoreModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    } finally {
      isLoadingStores.value = false;
    }
  }

  Future<StoreModel> fetchStoreById(int storeId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.stores)
          .select(
              'id, name, location, phone, is_active, created_at, updated_at')
          .eq('id', storeId)
          .single();
      return StoreModel.fromJson(data);
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  Future<StoreModel> createStore(Map<String, dynamic> data) async {
    try {
      final result = await _client
          .from(SupabaseConstants.stores)
          .insert(data)
          .select()
          .single();
      final store = StoreModel.fromJson(result);
      stores.add(store);
      return store;
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  Future<void> updateStore(int id, Map<String, dynamic> data) async {
    try {
      await _client.from(SupabaseConstants.stores).update(data).eq('id', id);
      // Reload to get server-updated timestamps.
      await fetchStores();
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  /// Assigns a product to a store (upsert to store_products join table).
  Future<void> assignProductToStore(
    int storeId,
    int productId, {
    double? overridePrice,
  }) async {
    try {
      await _client.from(SupabaseConstants.storeProducts).upsert({
        'store_id': storeId,
        'product_id': productId,
        if (overridePrice != null) 'override_price': overridePrice,
      });
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  Future<void> removeProductFromStore(int storeId, int productId) async {
    try {
      await _client
          .from(SupabaseConstants.storeProducts)
          .delete()
          .eq('store_id', storeId)
          .eq('product_id', productId);
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INVENTORY
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> fetchInventory({
    int page = 0,
    int pageSize = SupabaseConstants.defaultPageSize,
    int? storeId,
    int? productId,
    bool lowStockOnly = false,
  }) async {
    isLoadingInventory.value = true;
    try {
      final viewName = lowStockOnly
          ? SupabaseConstants.vLowStockAlert
          : SupabaseConstants.vStoreInventory;

      var q = _client.from(viewName).select('*');
      if (storeId != null) q = q.eq('store_id', storeId);
      if (productId != null) q = q.eq('product_id', productId);

      final from = page * pageSize;
      final res =
          await q.range(from, from + pageSize - 1).count(sb.CountOption.exact);

      inventory.assignAll(
        (res.data as List<dynamic>)
            .map((e) => InventoryModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      totalInventory.value = res.count;
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    } finally {
      isLoadingInventory.value = false;
    }
  }

  /// Updates the available quantity for a single inventory record.
  Future<void> updateInventoryQuantity(
      int inventoryId, int newAvailable) async {
    try {
      await _client
          .from(SupabaseConstants.inventory)
          .update({'available': newAvailable}).eq('id', inventoryId);
      final idx = inventory.indexWhere((i) => i.id == inventoryId);
      if (idx >= 0) {
        inventory[idx] = inventory[idx].copyWith(available: newAvailable);
      }
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  /// Bulk-updates available quantities in parallel.
  ///
  /// Each map must have `id` (int) and `available` (int) keys.
  Future<void> bulkUpdateInventory(List<Map<String, int>> updates) async {
    try {
      await Future.wait(
        updates.map((u) => updateInventoryQuantity(u['id']!, u['available']!)),
      );
    } catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }
}
