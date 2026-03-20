// lib/views/customer/order_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';

import 'package:marcat/controllers/cart_controller.dart';
import 'package:marcat/core/constants/app_colors.dart';
import 'package:marcat/core/constants/app_text_styles.dart';
import 'package:marcat/core/extensions/currency_extensions.dart';
import 'package:marcat/core/extensions/date_extensions.dart';
import 'package:marcat/models/enums.dart';
import 'package:marcat/models/sale_item_model.dart';
import 'package:marcat/models/sale_model.dart';

import 'scaffold/app_scaffold.dart';
import 'shared/brand.dart';
import 'shared/empty_state.dart';
import 'shared/section_header.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CustomerOrderDetailPage
// ─────────────────────────────────────────────────────────────────────────────

class CustomerOrderDetailPage extends StatefulWidget {
  const CustomerOrderDetailPage({super.key, required this.orderId});

  final int orderId;

  @override
  State<CustomerOrderDetailPage> createState() =>
      _CustomerOrderDetailPageState();
}

class _CustomerOrderDetailPageState
    extends State<CustomerOrderDetailPage> {
  SaleModel? _order;
  List<SaleItemModel>? _items;
  bool _isLoading = true;
  String? _error;

  CartController get _repo => Get.find<CartController>();

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final order = await _repo.fetchOrderById(widget.orderId);
      final items = await _repo.fetchOrderItems(widget.orderId);
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.marcatGold,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_error != null || _order == null) {
      return CustomerScaffold(
        page: 'Order Detail',
        body: EmptyState(
          icon: Icons.error_outline,
          title: 'Order Not Found',
          subtitle: _error ?? 'Could not load order details.',
          actionLabel: 'Go Back',
          onAction: () => Get.back(),
        ),
      );
    }

    return CustomerScaffold(
      page: 'Order #${_order!.id}',
      pageImage:
          'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=1600&q=80',
      body: _OrderDetailBody(
        order: _order!,
        items: _items ?? [],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _OrderDetailBody
// ─────────────────────────────────────────────────────────────────────────────

class _OrderDetailBody extends StatelessWidget {
  const _OrderDetailBody({required this.order, required this.items});

  final SaleModel order;
  final List<SaleItemModel> items;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 900;

    return FB5Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              eyebrow: 'Order',
              title: 'Order #${order.id}',
              subtitle:
                  // ✅ FIX: replaced manual month-array _formatDate() with shortDate()
                  'Placed on ${order.createdAt.shortDate()}',
            ),
            const SizedBox(height: 32),
            isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _OrderItems(items: items),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 2,
                        child: _OrderSummary(order: order),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _OrderItems(items: items),
                      const SizedBox(height: 24),
                      _OrderSummary(order: order),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _OrderSummary
// ─────────────────────────────────────────────────────────────────────────────

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.order});

  final SaleModel order;

  @override
  Widget build(BuildContext context) {
    final status = order.status;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Summary', style: AppTextStyles.titleMedium),
          const SizedBox(height: 16),
          const Divider(color: AppColors.borderLight),
          const SizedBox(height: 8),

          // Status
          _DetailRow(
            label: 'Status',
            value: _statusLabel(status),
            valueColor: _statusColor(status),
          ),
          const SizedBox(height: 8),

          // Date
          _DetailRow(
            label: 'Order Date',
            // ✅ FIX: using shortDate() extension
            value: order.createdAt.shortDate(),
          ),
          const SizedBox(height: 8),

          _DetailRow(
            label: 'Subtotal',
            value: order.subtotal.toJOD(),
          ),
          if (order.shippingCost > 0) ...[
            const SizedBox(height: 8),
            _DetailRow(
              label: 'Delivery',
              value: order.shippingCost.toJOD(),
            ),
          ],
          if (order.discountTotal > 0) ...[
            const SizedBox(height: 8),
            _DetailRow(
              label: 'Discount',
              value: '− ${order.discountTotal.toJOD()}',
              valueColor: AppColors.statusGreen,
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: AppColors.borderLight),
          ),
          _DetailRow(
            label: 'Total',
            value: order.grandTotal.toJOD(),
            bold: true,
          ),
        ],
      ),
    );
  }

  String _statusLabel(SaleStatus status) => switch (status) {
        SaleStatus.pending => 'Pending',
        SaleStatus.paid => 'Paid',
        SaleStatus.shipped => 'Shipped',
        SaleStatus.delivered => 'Delivered',
        SaleStatus.cancelled => 'Cancelled',
      };

  Color _statusColor(SaleStatus status) => switch (status) {
        SaleStatus.pending => AppColors.statusAmber,
        SaleStatus.paid => AppColors.statusBlue,
        SaleStatus.shipped => AppColors.statusBlue,
        SaleStatus.delivered => AppColors.statusGreen,
        SaleStatus.cancelled => AppColors.statusRed,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// _DetailRow
// ─────────────────────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: kSlate),
          ),
          Text(
            value,
            style: bold
                ? AppTextStyles.priceMedium
                : AppTextStyles.bodyMedium.copyWith(
                    color: valueColor ?? AppColors.marcatBlack,
                  ),
          ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _OrderItems
// ─────────────────────────────────────────────────────────────────────────────

class _OrderItems extends StatelessWidget {
  const _OrderItems({required this.items});

  final List<SaleItemModel> items;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Items (${items.length})',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.borderLight),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No items found.',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      color: kSlate,
                    ),
                  ),
                ),
              )
            else
              ...items.map((item) => _ItemRow(item: item)),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _ItemRow
// ─────────────────────────────────────────────────────────────────────────────

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final SaleItemModel item;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Product details ───────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName ?? 'Product',
                    style: AppTextStyles.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // ── Qty × price ───────────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.totalPrice.toJOD(),
                  style: AppTextStyles.priceMedium,
                ),
                Text(
                  '${item.quantity} × ${item.unitPrice.toJOD()}',
                  style: AppTextStyles.bodySmall.copyWith(color: kSlate),
                ),
              ],
            ),
          ],
        ),
      );
}
