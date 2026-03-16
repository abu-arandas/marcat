// lib/controllers/admin_controller.dart

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
    final auth = Get.find<AuthController>().state.value;
    if (auth.isAdmin || auth.isStoreManager) {
      fetchStaff();
      fetchStores();
    } else if (auth.isSalesperson) {
      fetchStores();
    }
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
  Future<void> createStaffMember({
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
  Future<bool> verifyPosPin({
    required String staffId,
    required String pin,
  }) async {
    try {
      final result = await _client.rpc(
        'verify_pos_pin',
        params: {'p_staff_id': staffId, 'p_pin': pin},
      );
      return result as bool? ?? false;
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
  }) async {
    isLoadingCommissions.value = true;
    try {
      final from = page * pageSize;
      final res = await _client
          .from(SupabaseConstants.commissions)
          .select()
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

  Future<void> approveCommission(int commissionId) async {
    try {
      await _client
          .from(SupabaseConstants.commissions)
          .update({'status': 'paid'}).eq('id', commissionId);

      final idx = commissions.indexWhere((c) => c.id == commissionId);
      if (idx != -1) {
        commissions[idx] = commissions[idx].copyWith(
          status: CommissionStatus.paid,
        );
      }
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STORES
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> fetchStores() async {
    isLoadingStores.value = true;
    try {
      final data = await _client.from(SupabaseConstants.stores).select();
      stores.assignAll(
        (data as List<dynamic>)
            .map((e) => StoreModel.fromJson(e as Map<String, dynamic>))
            .where((store) => store.isActive)
            .toList(),
      );
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    } finally {
      isLoadingStores.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INVENTORY
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> fetchInventory({
    int? storeId,
    int page = 0,
    int pageSize = SupabaseConstants.defaultPageSize,
  }) async {
    isLoadingInventory.value = true;
    try {
      final from = page * pageSize;
      var query = _client
          .from(SupabaseConstants.inventory)
          .select()
          .range(from, from + pageSize - 1);

      if (storeId != null) {
        query = query.eq('store_id', storeId);
      }

      final res = await query.count(sb.CountOption.exact);

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

  Future<void> updateInventoryQuantity({
    required int inventoryId,
    required int available,
  }) async {
    try {
      await _client
          .from(SupabaseConstants.inventory)
          .update({'available': available}).eq('id', inventoryId);

      final idx = inventory.indexWhere((i) => i.id == inventoryId);
      if (idx != -1) {
        inventory[idx] = inventory[idx].copyWith(available: available);
      }
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }
}
