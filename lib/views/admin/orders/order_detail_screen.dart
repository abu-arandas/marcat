// lib/views/admin/orders/order_detail_screen.dart
//
// Full order detail view for admin and store-manager roles.
//
// ✅ REFACTORED: uses brand.dart color aliases, consistent with customer side.

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/cart_controller.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/currency_extensions.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../models/enums.dart';
import '../../../models/sale_item_model.dart';
import '../../../models/sale_model.dart';
import '../shared/admin_widgets.dart';
import '../shared/brand.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdminOrderDetailScreen
// ─────────────────────────────────────────────────────────────────────────────

class AdminOrderDetailScreen extends StatefulWidget {
  const AdminOrderDetailScreen({super.key, required this.orderId});

  final int orderId;

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  SaleModel? _order;
  List<SaleItemModel> _items = [];
  bool _isLoading = true;
  String? _error;
  bool _isUpdating = false;

  CartController get _cartCtrl => Get.find<CartController>();

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final order = await _cartCtrl.fetchOrderById(widget.orderId);
      final items = await _cartCtrl.fetchOrderItems(widget.orderId);
      if (mounted) {
        setState(() {
          _order = order;
          _items = items;
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

  Future<void> _updateStatus(String newStatus) async {
    if (_order == null || _isUpdating) return;
    setState(() => _isUpdating = true);
    try {
      await _cartCtrl.updateOrderStatus(widget.orderId, newStatus);
      await _fetchOrderDetails();
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          e.toString(),
          snackPosition: SnackPosition.TOP,
          backgroundColor: kRed.withAlpha(26),
          colorText: kRed,
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
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
                  color: kGold,
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
                                size: AppDimensions.iconS, color: kGreen),
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
        child: CircularProgressIndicator(color: kGold),
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
              _OrderHeaderCard(order: _order!),
              const SizedBox(height: AppDimensions.space16),
              _LineItemsCard(items: _items),
              const SizedBox(height: AppDimensions.space16),
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
              const Divider(height: 1, color: kBorder),
              const SizedBox(height: AppDimensions.space12),
              AdminInfoRow(label: 'Placed', value: order.createdAt.shortDate()),
              const SizedBox(height: AppDimensions.space8),
              AdminInfoRow(
                label: 'Channel',
                value: order.channel.dbValue.toUpperCase(),
              ),
              if (order.storeId != null) ...[
                const SizedBox(height: AppDimensions.space8),
                AdminInfoRow(label: 'Store ID', value: '${order.storeId}'),
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
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Line Items', style: AppTextStyles.titleMedium),
              const SizedBox(height: AppDimensions.space12),
              if (items.isEmpty)
                Text(
                  'No items found.',
                  style:
                      AppTextStyles.bodyMedium.copyWith(color: kTextSecondary),
                )
              else
                ...items.map((item) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppDimensions.space8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Product #${item.productSizeId} × ${item.quantity}',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                          Text(
                            item.totalPrice.toJOD(),
                            style: AppTextStyles.priceSmall,
                          ),
                        ],
                      ),
                    )),
            ],
          ),
        ),
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
              Text('Financial Summary', style: AppTextStyles.titleMedium),
              const SizedBox(height: AppDimensions.space12),
              AdminInfoRow(label: 'Subtotal', value: order.subtotal.toJOD()),
              const SizedBox(height: AppDimensions.space4),
              AdminInfoRow(
                  label: 'Discount', value: '-${order.discountTotal.toJOD()}'),
              const SizedBox(height: AppDimensions.space4),
              AdminInfoRow(label: 'Tax', value: order.taxTotal.toJOD()),
              const SizedBox(height: AppDimensions.space4),
              AdminInfoRow(
                  label: 'Shipping', value: order.shippingCost.toJOD()),
              const Divider(height: AppDimensions.space24, color: kBorder),
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
