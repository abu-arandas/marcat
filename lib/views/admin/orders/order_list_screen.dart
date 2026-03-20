// lib/views/admin/orders/order_list_screen.dart
//
// Lists all orders with real-time status filtering, pull-to-refresh,
// and [SaleStatusBadge] on every row (previously a TODO comment).

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/cart_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/currency_extensions.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../models/enums.dart';
import '../../../models/sale_model.dart';
import '../shared/admin_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdminOrderListScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Paginated, filterable order list for admin / store-manager roles.
///
/// Filter chips allow one-tap status filtering without a full network
/// round-trip — the full first page is cached and client-filtered for
/// instant response.
class AdminOrderListScreen extends StatefulWidget {
  const AdminOrderListScreen({super.key});

  @override
  State<AdminOrderListScreen> createState() => _AdminOrderListScreenState();
}

class _AdminOrderListScreenState extends State<AdminOrderListScreen> {
  // ── State ─────────────────────────────────────────────────────────────────
  List<SaleModel> _allOrders = [];
  bool _isLoading = true;
  String? _error;
  SaleStatus? _statusFilter; // null → show all

  CartController get _cartCtrl => Get.find<CartController>();

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  // ── Data ──────────────────────────────────────────────────────────────────

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

  // ── Helpers ───────────────────────────────────────────────────────────────

  List<SaleModel> get _filtered => _statusFilter == null
      ? _allOrders
      : _allOrders.where((o) => o.status == _statusFilter).toList();

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        title: const Text('Orders'),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        color: AppColors.marcatGold,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const AdminListSkeleton();

    if (_error != null) {
      return AdminErrorRetry(message: _error!, onRetry: _loadOrders);
    }

    final filtered = _filtered;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // ── Status filter chips ─────────────────────────────────────────
        SliverToBoxAdapter(
          child: _StatusFilterBar(
            selected: _statusFilter,
            onChanged: (s) => setState(() => _statusFilter = s),
          ),
        ),

        // ── Count ───────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.pagePaddingH,
              AppDimensions.space4,
              AppDimensions.pagePaddingH,
              0,
            ),
            child: Text(
              '${filtered.length} order${filtered.length == 1 ? '' : 's'}',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
        ),

        // ── Empty ───────────────────────────────────────────────────────
        if (filtered.isEmpty)
          SliverFillRemaining(
            child: AdminEmptyState(
              icon: Icons.receipt_long_outlined,
              title: _statusFilter == null
                  ? 'No Orders Yet'
                  : 'No ${_statusFilter!.dbValue.capitalizeFirst} Orders',
              subtitle: _statusFilter != null
                  ? 'Try selecting a different status filter.'
                  : 'Orders will appear here when customers place them.',
            ),
          )
        else
          // ── Order rows ──────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.pagePaddingH,
              AppDimensions.space8,
              AppDimensions.pagePaddingH,
              AppDimensions.space64,
            ),
            sliver: SliverList.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppDimensions.space8),
              itemBuilder: (_, i) => _OrderCard(order: filtered[i]),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _StatusFilterBar
// ─────────────────────────────────────────────────────────────────────────────

class _StatusFilterBar extends StatelessWidget {
  const _StatusFilterBar({
    required this.selected,
    required this.onChanged,
  });

  final SaleStatus? selected;
  final ValueChanged<SaleStatus?> onChanged;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 48,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pagePaddingH,
            vertical: AppDimensions.space8,
          ),
          scrollDirection: Axis.horizontal,
          children: [
            _Chip(
              label: 'All',
              selected: selected == null,
              onTap: () => onChanged(null),
            ),
            ...SaleStatus.values.map(
              (s) => _Chip(
                label: s.dbValue.capitalizeFirst ?? s.dbValue,
                selected: selected == s,
                onTap: () => onChanged(s),
              ),
            ),
          ],
        ),
      );
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: AppDimensions.space8),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => onTap(),
          selectedColor: AppColors.marcatNavy,
          labelStyle: AppTextStyles.labelSmall.copyWith(
            color: selected ? AppColors.textOnDark : AppColors.textSecondary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
            side: BorderSide(
              color: selected ? AppColors.marcatNavy : AppColors.borderMedium,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space8),
          visualDensity: VisualDensity.compact,
        ),
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
                // ── Ref + Status ──────────────────────────────────────────
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

                // ── Date + Total ──────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order.createdAt.toDeviceShortDate(),
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    Text(
                      order.grandTotal.toJOD(),
                      style: AppTextStyles.titleSmall,
                    ),
                  ],
                ),

                const Divider(
                  height: AppDimensions.space24,
                  color: AppColors.borderLight,
                ),

                // ── Channel ───────────────────────────────────────────────
                Row(
                  children: [
                    Icon(
                      order.channel == SaleChannel.online
                          ? Icons.public_rounded
                          : Icons.point_of_sale_rounded,
                      size: AppDimensions.iconS,
                      color: AppColors.textDisabled,
                    ),
                    const SizedBox(width: AppDimensions.space4),
                    Text(
                      (order.channel.dbValue).toUpperCase(),
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const Spacer(),
                    Text(
                      'View Details →',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.marcatNavy,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}
