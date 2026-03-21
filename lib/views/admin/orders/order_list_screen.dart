// lib/views/admin/orders/order_list_screen.dart
//
// Lists all orders with real-time status filtering, pull-to-refresh,
// and [SaleStatusBadge] on every row.
//
// ✅ REFACTORED: uses brand.dart color aliases.
// ✅ REFACTORED: removed direct AppColors imports in favor of aliases.

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/cart_controller.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/currency_extensions.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../models/enums.dart';
import '../../../models/sale_model.dart';
import '../shared/admin_widgets.dart';
import '../shared/brand.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdminOrderListScreen
// ─────────────────────────────────────────────────────────────────────────────

class AdminOrderListScreen extends StatefulWidget {
  const AdminOrderListScreen({super.key});

  @override
  State<AdminOrderListScreen> createState() => _AdminOrderListScreenState();
}

class _AdminOrderListScreenState extends State<AdminOrderListScreen> {
  List<SaleModel> _allOrders = [];
  bool _isLoading = true;
  String? _error;
  SaleStatus? _statusFilter;

  CartController get _cartCtrl => Get.find<CartController>();

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final (orders, _) = await _cartCtrl.fetchOrders(
        page: 0,
        pageSize: 100,
        updateState: false,
      );
      if (mounted) {
        setState(() {
          _allOrders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<SaleModel> get _filtered => _statusFilter == null
      ? _allOrders
      : _allOrders.where((o) => o.status == _statusFilter).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        title: const Text('Orders'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // ── Filter chips ────────────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.pagePaddingH,
              vertical: AppDimensions.space8,
            ),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _statusFilter == null,
                  onTap: () => setState(() => _statusFilter = null),
                ),
                const SizedBox(width: AppDimensions.space8),
                ...SaleStatus.values.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(right: AppDimensions.space8),
                    child: _FilterChip(
                      label:
                          s.dbValue[0].toUpperCase() + s.dbValue.substring(1),
                      selected: _statusFilter == s,
                      onTap: () => setState(() => _statusFilter = s),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Body ────────────────────────────────────────────────────────
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const AdminListSkeleton();

    if (_error != null) {
      return AdminErrorRetry(message: _error!, onRetry: _loadOrders);
    }

    final orders = _filtered;

    if (orders.isEmpty) {
      return const AdminEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No Orders',
        subtitle: 'Orders matching the current filter will appear here.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: kGold,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        itemCount: orders.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppDimensions.space12),
        itemBuilder: (_, i) => _OrderCard(order: orders[i]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _FilterChip
// ─────────────────────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ActionChip(
        label: Text(label),
        onPressed: onTap,
        backgroundColor: selected ? kNavy : kSurfaceWhite,
        labelStyle: AppTextStyles.chipLabel.copyWith(
          color: selected ? kTextOnDark : kTextSecondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          side: BorderSide(
            color: selected ? kNavy : kBorderMedium,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space8),
        visualDensity: VisualDensity.compact,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _OrderCard
// ─────────────────────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final SaleModel order;

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          onTap: () => Get.toNamed(AppRoutes.adminOrderOf(order.id)),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order.referenceNumber,
                      style: AppTextStyles.titleSmall,
                    ),
                    SaleStatusBadge(status: order.status),
                  ],
                ),
                const SizedBox(height: AppDimensions.space8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order.createdAt.toDeviceShortDate(),
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: kTextSecondary),
                    ),
                    Text(
                      order.grandTotal.toJOD(),
                      style: AppTextStyles.titleSmall,
                    ),
                  ],
                ),
                const Divider(
                  height: AppDimensions.space24,
                  color: kBorder,
                ),
                Row(
                  children: [
                    Icon(
                      order.channel == SaleChannel.online
                          ? Icons.language_rounded
                          : Icons.storefront_rounded,
                      size: AppDimensions.iconS,
                      color: kTextSecondary,
                    ),
                    const SizedBox(width: AppDimensions.space4),
                    Text(
                      order.channel.dbValue.toUpperCase(),
                      style: AppTextStyles.labelSmall
                          .copyWith(color: kTextSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}
