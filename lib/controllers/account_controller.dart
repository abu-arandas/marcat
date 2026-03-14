// lib/controllers/account_controller.dart

import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants/supabase_constants.dart';
import '../core/error_handler.dart';
import '../models/customer_address_model.dart';
import '../models/customer_model.dart';
import '../models/loyalty_transaction_model.dart';
import '../models/user_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AccountController
// ─────────────────────────────────────────────────────────────────────────────

class AccountController extends GetxController {
  SupabaseClient get _client => Supabase.instance.client;

  // ── Profile ─────────────────────────────────────────────────────────────────
  final profile = Rxn<UserModel>();
  final customer = Rxn<CustomerModel>();
  final isLoadingProfile = false.obs;

  // ── Addresses ───────────────────────────────────────────────────────────────
  final addresses = <CustomerAddressModel>[].obs;
  final isLoadingAddresses = false.obs;

  // ── Loyalty ─────────────────────────────────────────────────────────────────
  final loyaltyTransactions = <LoyaltyTransactionModel>[].obs;
  final totalLoyaltyTransactions = 0.obs;
  final isLoadingLoyalty = false.obs;

  // ── Admin: customer summaries ────────────────────────────────────────────────
  final customerSummaries = <Map<String, dynamic>>[].obs;
  final totalCustomers = 0.obs;
  final isLoadingCustomers = false.obs;

  // ═══════════════════════════════════════════════════════════════════════════
  // PROFILE
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> loadProfile(String userId) async {
    isLoadingProfile.value = true;
    try {
      await Future.wait([
        fetchUserProfile(userId),
        fetchCustomer(userId),
      ]);
    } catch (e) {
      rethrow;
    } finally {
      isLoadingProfile.value = false;
    }
  }

  Future<UserModel> fetchUserProfile(String userId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.profiles)
          .select()
          .eq('id', userId)
          .single();
      final user = UserModel.fromJson(data);
      profile.value = user;
      return user;
    } on PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    try {
      await _client
          .from(SupabaseConstants.profiles)
          .update(data)
          .eq('id', userId);
      // Refresh local state after update.
      await fetchUserProfile(userId);
    } on PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  /// Uploads a JPEG avatar to Supabase Storage (avatars bucket) and updates
  /// the avatar_url column in profiles.
  Future<String> uploadAvatar(String userId, Uint8List imageBytes) async {
    try {
      final fileName = '$userId/avatar.jpg';
      await _client.storage.from(SupabaseConstants.avatarsBucket).uploadBinary(
            fileName,
            imageBytes,
            fileOptions:
                const FileOptions(contentType: 'image/jpeg', upsert: true),
          );
      final url = _client.storage
          .from(SupabaseConstants.avatarsBucket)
          .getPublicUrl(fileName);

      await _client
          .from(SupabaseConstants.profiles)
          .update({'avatar_url': url}).eq('id', userId);

      // Update local profile observable immediately.
      if (profile.value != null) {
        profile.value = profile.value!.copyWith(avatarUrl: url);
      }
      return url;
    } catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CUSTOMER
  // ═══════════════════════════════════════════════════════════════════════════

  Future<CustomerModel?> fetchCustomer(String userId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.customers)
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (data == null) return null;
      final c = CustomerModel.fromJson(data);
      customer.value = c;
      return c;
    } on PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  Future<void> updateCustomerNotes(String userId, String notes) async {
    try {
      await _client
          .from(SupabaseConstants.customers)
          .update({'notes': notes}).eq('id', userId);
      if (customer.value != null) {
        customer.value = customer.value!.copyWith(notes: notes);
      }
    } on PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  // ─── Admin: customer list ───────────────────────────────────────────────────

  /// Fetches a paginated list of customer summaries from v_customer_summary.
  Future<void> fetchCustomerSummaries({
    int page = 0,
    int pageSize = SupabaseConstants.defaultPageSize,
    String? query,
  }) async {
    isLoadingCustomers.value = true;
    try {
      var q = _client.from(SupabaseConstants.vCustomerSummary).select();
      if (query != null && query.isNotEmpty) {
        q = q.or(
          'first_name.ilike.%$query%,'
          'last_name.ilike.%$query%,'
          'phone.ilike.%$query%',
        );
      }
      final from = page * pageSize;
      final res = await q
          .order('total_spent', ascending: false)
          .range(from, from + pageSize - 1)
          .count(CountOption.exact);

      customerSummaries.assignAll(
        (res.data as List<dynamic>).cast<Map<String, dynamic>>(),
      );
      totalCustomers.value = res.count;
    } on PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    } finally {
      isLoadingCustomers.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ADDRESSES
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> fetchAddresses(String customerId) async {
    isLoadingAddresses.value = true;
    try {
      // FIX: removed QA mock bypass that short-circuited the real Supabase
      // query when customerId == '123e4567-...'. Real customers with that UUID
      // would receive fake addresses and real address operations would silently
      // fail. Removed entirely — the real query always runs now.
      final data = await _client
          .from(SupabaseConstants.customerAddresses)
          .select()
          .eq('customer_id', customerId)
          .order('is_default', ascending: false);
      addresses.assignAll(
        (data as List<dynamic>)
            .map(
                (e) => CustomerAddressModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    } finally {
      isLoadingAddresses.value = false;
    }
  }

  Future<CustomerAddressModel> addAddress(
      String customerId, Map<String, dynamic> data) async {
    try {
      final result = await _client
          .from(SupabaseConstants.customerAddresses)
          .insert({...data, 'customer_id': customerId})
          .select()
          .single();
      final address = CustomerAddressModel.fromJson(result);
      addresses.add(address);
      return address;
    } on PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  Future<void> deleteAddress(int addressId) async {
    try {
      await _client
          .from(SupabaseConstants.customerAddresses)
          .delete()
          .eq('id', addressId);
      addresses.removeWhere((a) => a.id == addressId);
    } on PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  /// Uses the set_default_address RPC — never a direct UPDATE.
  /// The RPC clears the old default and sets the new one atomically.
  Future<void> setDefaultAddress(String customerId, int addressId) async {
    try {
      await _client.rpc(
        SupabaseConstants.rpcSetDefaultAddress,
        params: {
          'p_customer_id': customerId,
          'p_address_id': addressId,
        },
      );
      // Reflect change in local state without a round-trip.
      for (var i = 0; i < addresses.length; i++) {
        addresses[i] =
            addresses[i].copyWith(isDefault: addresses[i].id == addressId);
      }
    } on PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOYALTY
  // ═══════════════════════════════════════════════════════════════════════════

  /// Fetches paginated loyalty transactions and stores them in
  /// [loyaltyTransactions].
  ///
  /// FIX: was previously typed as `Future<void>` but callers were assigning
  /// its return value to a local variable and then trying to use it.  The
  /// result is already stored in [loyaltyTransactions] so callers can just
  /// read that observable directly after awaiting this method.
  Future<void> fetchLoyaltyTransactions({
    required String customerId,
    int page = 0,
    int pageSize = SupabaseConstants.defaultPageSize,
  }) async {
    isLoadingLoyalty.value = true;
    try {
      final from = page * pageSize;
      final res = await _client
          .from(SupabaseConstants.loyaltyTransactions)
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false)
          .range(from, from + pageSize - 1)
          .count(CountOption.exact);

      loyaltyTransactions.assignAll(
        (res.data as List<dynamic>)
            .map((e) =>
                LoyaltyTransactionModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      totalLoyaltyTransactions.value = res.count;
    } on PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    } finally {
      isLoadingLoyalty.value = false;
    }
  }

  /// Admin: manually adjust loyalty points for a customer.
  ///
  /// [points] may be positive (earn) or negative (redeem/deduction).
  /// The DB CHECK enforces points <> 0.
  Future<void> adjustLoyaltyPoints({
    required String customerId,
    required int points,
    required String description,
  }) async {
    try {
      await _client.from(SupabaseConstants.loyaltyTransactions).insert({
        'customer_id': customerId,
        'points': points,
        'description': description,
      });
      // Reload to reflect change and get the server-assigned id.
      await fetchLoyaltyTransactions(customerId: customerId);
    } on PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }
}
