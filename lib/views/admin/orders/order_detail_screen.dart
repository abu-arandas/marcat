// lib/views/admin/orders/order_detail_screen.dart
//
// Full order detail view for admin and store-manager roles.
//
// Shows the order header, line items, financial summary, and customer
// info — with an action menu to update the order status.

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/cart_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/currency_extensions.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../models/enums.dart';
import '../../../models/sale_item_model.dart';
import '../../../models/sale_model.dart';
import '../shared/admin_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdminOrderDetailScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Full detail page for a single order.
///
/// Navigated to via [AppRoutes.adminOrderOf(orderId)].
class AdminOrderDetailScreen extends StatefulWidget {
  const AdminOrderDetailScreen({super.key, required this.orderId});

  final int orderId;

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  // ── State ─────────────────────────────────────────────────────────────────
  SaleModel? _order;
  List<SaleItemModel> _items = [];
  bool _isLoading = true;
  String? _error;
  bool _isUpdating = false;

  CartController get _cartCtrl => Get.find<CartController>();

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  // ── Data ──────────────────────────────────────────────────────────────────

  Future<void> _fetchOrderDetails() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _cartCtrl.fetchOrderById(widget.orderId),
        _cartCtrl.fetchOrderItems(widget.orderId),
      ]);

      if (mounted) {
        setState(() {
          _order = results[0] as SaleModel;
          _items = results[1] as List<SaleItemModel>;
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

  Future<void> _updateStatus(String newStatusStr) async {
    if (_order == null) return;
    setState(() => _isUpdating = true);
    try {
      await _cartCtrl.updateOrderStatus(
        widget.orderId,
        newStatusStr,
        changedBy: 'Admin',
      );
      await _fetchOrderDetails();
      if (mounted) {
        Get.snackbar(
          'Status Updated',
          'Order status changed to $newStatusStr.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.successGreenLight,
          colorText: AppColors.statusGreen,
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          e.toString(),
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.statusRedLight,
          colorText: AppColors.statusRed,
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        title: Text(_order != null
            ? 'Order ${_order!.referenceNumber}'
            : 'Order Details'),
        centerTitle: false,
        actions: [
          if (_isUpdating)
            const Padding(
              padding: EdgeInsets.all(AppDimensions.space16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppColors.marcatGold,
                  strokeWidth: 2,
                ),
              ),
            )
          else if (_order != null)
            PopupMenuButton<String>(
              tooltip: 'Change Status',
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: _updateStatus,
              itemBuilder: (_) => SaleStatus.values
                  .map(
                    (s) => PopupMenuItem(
                      value: s.dbValue,
                      child: Row(
                        children: [
                          SaleStatusBadge(status: s),
                          const SizedBox(width: AppDimensions.space8),
                          if (_order!.status == s)
                            const Icon(Icons.check_rounded,
                                size: AppDimensions.iconS,
                                color: AppColors.statusGreen),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.marcatGold),
      );
    }

    if (_error != null) {
      return AdminErrorRetry(
        message: _error!,
        onRetry: _fetchOrderDetails,
      );
    }

    if (_order == null) {
      return const AdminEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Order Not Found',
        subtitle: 'This order may have been deleted.',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Order Header ───────────────────────────────────────────
              _OrderHeaderCard(order: _order!),
              const SizedBox(height: AppDimensions.space16),

              // ── Line Items ─────────────────────────────────────────────
              _LineItemsCard(items: _items),
              const SizedBox(height: AppDimensions.space16),

              // ── Financial Summary ──────────────────────────────────────
              _FinancialSummaryCard(order: _order!),

              const SizedBox(height: AppDimensions.space64),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _OrderHeaderCard
// ─────────────────────────────────────────────────────────────────────────────

class _OrderHeaderCard extends StatelessWidget {
  const _OrderHeaderCard({required this.order});

  final SaleModel order;

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.referenceNumber,
                    style: AppTextStyles.titleLarge,
                  ),
                  SaleStatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: AppDimensions.space12),
              const Divider(height: 1, color: AppColors.borderLight),
              const SizedBox(height: AppDimensions.space12),

              AdminInfoRow(
                label: 'Placed',
                value: order.createdAt.shortDate(),
              ),
              const SizedBox(height: AppDimensions.space8),
              AdminInfoRow(
                label: 'Channel',
                value: order.channel.dbValue.toUpperCase(),
              ),
              if (order.storeId != null) ...[
                const SizedBox(height: AppDimensions.space8),
                AdminInfoRow(
                  label: 'Store ID',
                  value: '${order.storeId}',
                ),
              ],
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _LineItemsCard
// ─────────────────────────────────────────────────────────────────────────────

class _LineItemsCard extends StatelessWidget {
  const _LineItemsCard({required this.items});

  final List<SaleItemModel> items;

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.space16,
                AppDimensions.space16,
                AppDimensions.space16,
                AppDimensions.space8,
              ),
              child: Text(
                'Items (${items.length})',
                style: AppTextStyles.titleSmall,
              ),
            ),
            const Divider(height: 1, color: AppColors.borderLight),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(AppDimensions.space16),
                child: Text('No items found.'),
              )
            else
              ...items.asMap().entries.map((entry) {
                final isLast = entry.key == items.length - 1;
                return _LineItemRow(
                  item: entry.value,
                  showDivider: !isLast,
                );
              }),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _LineItemRow
// ─────────────────────────────────────────────────────────────────────────────

class _LineItemRow extends StatelessWidget {
  const _LineItemRow({required this.item, this.showDivider = true});

  final SaleItemModel item;
  final bool showDivider;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space16,
              vertical: AppDimensions.space12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name + variant
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName ?? 'Unknown Product',
                        style: AppTextStyles.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppDimensions.space4),
                      Text(
                        'Qty: ${item.quantity}',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                // Unit price × qty
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      (item.unitPrice * item.quantity).toJOD(),
                      style: AppTextStyles.titleSmall,
                    ),
                    Text(
                      '${item.unitPrice.toJOD()} each',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textDisabled),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (showDivider)
            const Divider(
              height: 1,
              indent: AppDimensions.space16,
              color: AppColors.borderLight,
            ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _FinancialSummaryCard
// ─────────────────────────────────────────────────────────────────────────────

class _FinancialSummaryCard extends StatelessWidget {
  const _FinancialSummaryCard({required this.order});

  final SaleModel order;

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Financial Summary', style: AppTextStyles.titleSmall),
              const SizedBox(height: AppDimensions.space12),
              const Divider(height: 1, color: AppColors.borderLight),
              const SizedBox(height: AppDimensions.space12),
              AdminInfoRow(
                label: 'Subtotal',
                value: order.subtotal.toJOD(),
              ),
              if ((order.deliveryFee ?? 0) > 0) ...[
                const SizedBox(height: AppDimensions.space8),
                AdminInfoRow(
                  label: 'Delivery Fee',
                  value: order.deliveryFee!.toJOD(),
                ),
              ],
              if ((order.discountAmount ?? 0) > 0) ...[
                const SizedBox(height: AppDimensions.space8),
                AdminInfoRow(
                  label: 'Discount',
                  value: '− ${order.discountAmount!.toJOD()}',
                  valueColor: AppColors.statusGreen,
                ),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppDimensions.space12),
                child: Divider(height: 1, color: AppColors.borderLight),
              ),
              AdminInfoRow(
                label: 'Grand Total',
                value: order.grandTotal.toJOD(),
                bold: true,
              ),
            ],
          ),
        ),
      );
}
