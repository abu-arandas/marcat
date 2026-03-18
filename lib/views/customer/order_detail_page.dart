// lib/views/customer/order_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';

import 'package:marcat/controllers/cart_controller.dart';
import 'package:marcat/core/constants/app_colors.dart';
import 'package:marcat/core/constants/app_text_styles.dart';
import 'package:marcat/core/extensions/currency_extensions.dart';
import 'package:marcat/models/enums.dart';
import 'package:marcat/models/sale_item_model.dart';
import 'package:marcat/models/sale_model.dart';

import 'scaffold/app_scaffold.dart';
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

class _CustomerOrderDetailPageState extends State<CustomerOrderDetailPage> {
  SaleModel? _order;
  List<SaleItemModel>? _items;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final repo = Get.find<CartController>();
      final order = await repo.fetchOrderById(widget.orderId);
      final items = await repo.fetchOrderItems(widget.orderId);
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
  Widget build(BuildContext context) => CustomerScaffold(
        page: 'Order Details',
        body: FB5Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: _buildContent(),
          ),
        ),
      );

  Widget _buildContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(60),
        child: Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.marcatGold),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: AppColors.marcatSlate),
              const SizedBox(height: 12),
              Text(_error!,
                  style: const TextStyle(color: AppColors.marcatSlate)),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _fetch,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry'),
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.marcatNavy),
              ),
            ],
          ),
        ),
      );
    }

    if (_order == null) return const SizedBox.shrink();

    final o = _order!;
    final items = _items ?? [];
    final isDesktop = MediaQuery.sizeOf(context).width > 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Back button ────────────────────────────────────────────────────
        TextButton.icon(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_rounded, size: 16),
          label: const Text('Back to Orders'),
          style: TextButton.styleFrom(foregroundColor: AppColors.marcatNavy),
        ),
        const SizedBox(height: 20),

        SectionHeader(
          eyebrow: 'Order',
          title: '#${o.referenceNumber}',
        ),
        const SizedBox(height: 24),

        // ── Content layout ─────────────────────────────────────────────────
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _OrderItems(items: items)),
              const SizedBox(width: 32),
              SizedBox(
                  width: 320, child: _OrderSummaryCard(order: o)),
            ],
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _OrderSummaryCard(order: o),
              const SizedBox(height: 24),
              _OrderItems(items: items),
            ],
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _OrderSummaryCard
// ─────────────────────────────────────────────────────────────────────────────

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.order});

  final SaleModel order;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order Summary', style: AppTextStyles.titleMedium),
                _StatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.borderLight),
            const SizedBox(height: 12),

            _DetailRow(
              label: 'Channel',
              value: order.channel.dbValue.toUpperCase(),
            ),
            _DetailRow(
              label: 'Date',
              value: _formatDate(order.createdAt),
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.borderLight),
            const SizedBox(height: 12),

            _DetailRow(label: 'Subtotal', value: order.subtotal.toJOD()),
            if (order.discountTotal > 0)
              _DetailRow(
                label: 'Discount',
                value: '-${order.discountTotal.toJOD()}',
                valueColor: AppColors.successGreen,
              ),
            if (order.shippingCost > 0)
              _DetailRow(
                  label: 'Shipping', value: order.shippingCost.toJOD()),
            if (order.taxTotal > 0)
              _DetailRow(label: 'Tax', value: order.taxTotal.toJOD()),
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

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${local.day} ${months[local.month - 1]} ${local.year}';
  }
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
                      color: AppColors.marcatSlate,
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

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final SaleItemModel item;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item name + meta
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
                  const SizedBox(height: 4),
                  Text(
                    'Qty: ${item.quantity}',
                    style: const TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 12,
                      color: AppColors.marcatSlate,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Line total
            Text(
              item.totalPrice.toJOD(),
              style: AppTextStyles.priceSmall,
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _DetailRow
// ─────────────────────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: bold
                  ? AppTextStyles.titleSmall
                  : AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.marcatSlate),
            ),
            Text(
              value,
              style: (bold
                      ? AppTextStyles.priceMedium
                      : AppTextStyles.bodyMedium)
                  .copyWith(color: valueColor),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _StatusBadge
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final SaleStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (status) {
      SaleStatus.pending =>
        (AppColors.statusAmberLight, AppColors.statusAmber, 'Pending'),
      SaleStatus.paid =>
        (AppColors.statusBlueLight, AppColors.statusBlue, 'Paid'),
      SaleStatus.shipped =>
        (AppColors.statusBlueLight, AppColors.statusBlue, 'Shipped'),
      SaleStatus.delivered =>
        (AppColors.statusGreenLight, AppColors.statusGreen, 'Delivered'),
      SaleStatus.cancelled =>
        (AppColors.statusRedLight, AppColors.statusRed, 'Cancelled'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'IBMPlexSansArabic',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
