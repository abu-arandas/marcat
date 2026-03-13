// lib/controllers/delivery_controller.dart
//
//

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'package:marcat/core/constants/supabase_constants.dart';
import 'package:marcat/core/error_handler.dart';
import 'package:marcat/models/delivery_model.dart';
import 'package:marcat/models/enums.dart';

const _deliveryFields =
    'id, sale_id, driver_id, status, tracking_number, proof_image_url, '
    'delivered_at, created_at, updated_at';

// ─────────────────────────────────────────────────────────────────────────────
// DeliveryController
// ─────────────────────────────────────────────────────────────────────────────

class DeliveryController extends GetxController {
  sb.SupabaseClient get _client => sb.Supabase.instance.client;

  // ── Reactive state ──────────────────────────────────────────────────────────
  final deliveries = <DeliveryModel>[].obs;
  final totalDeliveries = 0.obs;
  final activeDeliveries = <DeliveryModel>[].obs;
  final selectedDelivery = Rxn<DeliveryModel>();
  final deliveryHistory = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  // ── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    loadActiveDeliveries();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FETCH
  // ═══════════════════════════════════════════════════════════════════════════

  /// Loads all in-progress deliveries from the v_active_deliveries view.
  Future<void> loadActiveDeliveries() async {
    isLoading.value = true;
    try {
      final data =
          await _client.from(SupabaseConstants.vActiveDeliveries).select('*');
      activeDeliveries.assignAll(
        (data as List<dynamic>)
            .map((e) => DeliveryModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    } finally {
      isLoading.value = false;
    }
  }

  /// Paginated delivery list with optional filters.
  Future<void> fetchDeliveries({
    int page = 0,
    int pageSize = SupabaseConstants.defaultPageSize,
    String? status,
    String? driverId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    isLoading.value = true;
    try {
      var q =
          _client.from(SupabaseConstants.deliveries).select(_deliveryFields);
      if (status != null) q = q.eq('status', status);
      if (driverId != null) q = q.eq('driver_id', driverId);
      if (fromDate != null) q = q.gte('created_at', fromDate.toIso8601String());
      if (toDate != null) q = q.lte('created_at', toDate.toIso8601String());

      final from = page * pageSize;
      final res = await q
          .order('created_at', ascending: false)
          .range(from, from + pageSize - 1)
          .count(sb.CountOption.exact);

      deliveries.assignAll(
        (res.data as List<dynamic>)
            .map((e) => DeliveryModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      totalDeliveries.value = res.count;
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    } finally {
      isLoading.value = false;
    }
  }

  Future<DeliveryModel?> fetchDeliveryBySaleId(int saleId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.deliveries)
          .select(_deliveryFields)
          .eq('sale_id', saleId)
          .maybeSingle();
      if (data == null) return null;
      final delivery = DeliveryModel.fromJson(data);
      selectedDelivery.value = delivery;
      return delivery;
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MUTATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// General-purpose field update (e.g. assign driver, set tracking number).
  Future<void> updateDelivery(int deliveryId, Map<String, dynamic> data) async {
    try {
      await _client
          .from(SupabaseConstants.deliveries)
          .update(data)
          .eq('id', deliveryId);
      // Reflect in local state
      _patchLocal(deliveryId, data);
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  /// Updates the delivery status and appends a delivery_status_history record.
  ///
  /// If the history insert fails the status is rolled back so both tables
  /// stay consistent.  Migrate to an RPC/transaction when possible to make
  /// this truly atomic on the DB side.
  Future<void> updateDeliveryStatus(
    int deliveryId,
    DeliveryStatus newStatus, {
    String? changedBy,
    String? note,
    double? latitude,
    double? longitude,
  }) async {
    // Read current status for rollback.
    String? previousStatus;
    try {
      final row = await _client
          .from(SupabaseConstants.deliveries)
          .select('status')
          .eq('id', deliveryId)
          .single();
      previousStatus = row['status'] as String?;
    } catch (e) {
      debugPrint('[DeliveryController] Could not fetch previous status: $e');
    }

    try {
      // 1. Update status.
      await _client
          .from(SupabaseConstants.deliveries)
          .update({'status': newStatus.dbValue}).eq('id', deliveryId);

      // 2. Append history record.
      try {
        await _client.from(SupabaseConstants.deliveryStatusHistory).insert({
          'delivery_id': deliveryId,
          'old_status': previousStatus,
          'new_status': newStatus.dbValue,
          if (changedBy != null) 'changed_by': changedBy,
          if (note != null) 'note': note,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        });
      } on sb.PostgrestException catch (histErr, s) {
        // Roll back status if history insert fails.
        if (previousStatus != null) {
          await _client
              .from(SupabaseConstants.deliveries)
              .update({'status': previousStatus}).eq('id', deliveryId);
        }
        throw ErrorHandler.handle(histErr, s);
      }

      // 3. Reflect in local state.
      _patchLocal(deliveryId, {'status': newStatus.dbValue});
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  Future<void> fetchDeliveryHistory(int deliveryId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.deliveryStatusHistory)
          .select('id, delivery_id, old_status, new_status, '
              'changed_by, note, latitude, longitude, created_at')
          .eq('delivery_id', deliveryId)
          .order('created_at');
      deliveryHistory.assignAll(
        (data as List<dynamic>).cast<Map<String, dynamic>>(),
      );
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Applies a partial update to local [deliveries] and [activeDeliveries]
  /// lists so the UI reflects changes without an extra round-trip.
  void _patchLocal(int deliveryId, Map<String, dynamic> data) {
    for (final list in [deliveries, activeDeliveries]) {
      final idx = list.indexWhere((d) => d.id == deliveryId);
      if (idx < 0) continue;
      final d = list[idx];
      list[idx] = d.copyWith(
        status: data['status'] != null
            ? DeliveryStatusX.fromDb(data['status'] as String)
            : null,
        driverId: data['driver_id'] as String?,
        trackingNumber: data['tracking_number'] as String?,
        proofImageUrl: data['proof_image_url'] as String?,
      );
    }
    if (selectedDelivery.value?.id == deliveryId) {
      final d = selectedDelivery.value!;
      selectedDelivery.value = d.copyWith(
        status: data['status'] != null
            ? DeliveryStatusX.fromDb(data['status'] as String)
            : null,
        driverId: data['driver_id'] as String?,
        trackingNumber: data['tracking_number'] as String?,
        proofImageUrl: data['proof_image_url'] as String?,
      );
    }
  }
}
