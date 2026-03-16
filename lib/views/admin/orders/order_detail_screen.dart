// lib/views/admin/orders/order_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/cart_controller.dart';
import '../../../core/extensions/currency_extensions.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import 'package:marcat/models/sale_model.dart';
import 'package:marcat/models/sale_item_model.dart';
import 'package:marcat/models/enums.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  const AdminOrderDetailScreen({super.key, required this.orderId});

  final int orderId;

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  SaleModel? order;
  List<SaleItemModel>? items;
  bool isLoading = true;
  String? errorMessage;

  CartController get _cartCtrl => Get.find<CartController>();

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fetchedOrder = await _cartCtrl.fetchOrderById(widget.orderId);
      final fetchedItems = await _cartCtrl.fetchOrderItems(widget.orderId);

      if (mounted) {
        setState(() {
          order = fetchedOrder;
          items = fetchedItems;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  Future<void> _updateStatus(String newStatusStr) async {
    if (order == null) return;

    try {
      await _cartCtrl.updateOrderStatus(
        widget.orderId,
        newStatusStr,
        changedBy: 'Admin',
      );

      await _fetchOrderDetails();

      if (mounted) {
        Get.snackbar(
          'Success',
          'Order status updated to $newStatusStr',
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: AppColors.marcatCream,
        actions: [
          if (order != null)
            PopupMenuButton<String>(
              tooltip: 'Change Status',
              onSelected: _updateStatus,
              itemBuilder: (_) => SaleStatus.values
                  .map((s) => PopupMenuItem(
                        value: s.dbValue,
                        child: Text(s.dbValue),
                      ))
                  .toList(),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.marcatGold),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.statusRed, size: 48),
              const SizedBox(height: AppDimensions.space16),
              Text(errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: AppDimensions.space24),
              OutlinedButton.icon(
                onPressed: _fetchOrderDetails,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (order == null || items == null) {
      return const Center(child: Text('Order not found.'));
    }

    final o = order!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Order header ────────────────────────────────────────────
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Order #${o.referenceNumber}',
                              style: AppTextStyles.titleLarge),
                          _StatusBadge(status: o.status),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.space8),
                      Text('Channel: ${o.channel.dbValue}',
                          style: AppTextStyles.bodyMedium),
                      Text(
                        'Placed: ${o.createdAt.toLocal()}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.space16),

              // ── Line items ──────────────────────────────────────────────
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppDimensions.space16),
                      child: Text('Items', style: AppTextStyles.titleMedium),
                    ),
                    const Divider(height: 1),
                    ...items!.map((item) => ListTile(
                          title: Text(
                              item.productName ?? 'Product #${item.productId}',
                              style: AppTextStyles.labelMedium),
                          subtitle: Text('Qty: ${item.quantity}',
                              style: AppTextStyles.bodySmall),
                          trailing: Text(item.totalPrice.toJOD(),
                              style: AppTextStyles.priceSmall),
                        )),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.space16),

              // ── Totals ──────────────────────────────────────────────────
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  child: Column(
                    children: [
                      _TotalRow(label: 'Subtotal', value: o.subtotal.toJOD()),
                      _TotalRow(
                          label: 'Discount',
                          value: '-${o.discountTotal.toJOD()}'),
                      _TotalRow(
                          label: 'Shipping',
                          value: o.shippingCost.toJODOrFree()),
                      _TotalRow(label: 'Tax', value: o.taxTotal.toJOD()),
                      const Divider(),
                      _TotalRow(
                        label: 'Grand Total',
                        value: o.grandTotal.toJOD(),
                        bold: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final SaleStatus status;

  Color get _color {
    return switch (status) {
      SaleStatus.pending => AppColors.statusAmber,
      SaleStatus.paid => AppColors.statusBlue,
      SaleStatus.shipped => AppColors.marcatSlate,
      SaleStatus.delivered => AppColors.statusGreen,
      SaleStatus.cancelled => AppColors.statusRed,
    };
  }

  Color get _bg {
    return switch (status) {
      SaleStatus.pending => AppColors.statusAmberLight,
      SaleStatus.paid => AppColors.statusBlueLight,
      SaleStatus.shipped => AppColors.surfaceGrey,
      SaleStatus.delivered => AppColors.statusGreenLight,
      SaleStatus.cancelled => AppColors.statusRedLight,
    };
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status.dbValue,
          style: AppTextStyles.labelSmall.copyWith(color: _color),
        ),
      );
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style:
                    bold ? AppTextStyles.titleSmall : AppTextStyles.bodyMedium),
            Text(value,
                style: bold
                    ? AppTextStyles.priceMedium
                    : AppTextStyles.priceSmall),
          ],
        ),
      );
}
