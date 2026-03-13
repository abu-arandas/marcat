// lib/views/customer/order_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';
import 'package:marcat/models/sale_model.dart';
import 'package:marcat/models/sale_item_model.dart';
import 'package:marcat/core/constants/app_colors.dart';
import 'package:marcat/core/extensions/currency_extensions.dart';

import '../../controllers/cart_controller.dart';
import 'scaffold/app_scaffold.dart';
import 'shared/section_header.dart';

class CustomerOrderDetailPage extends StatefulWidget {
  final int orderId;
  const CustomerOrderDetailPage({super.key, required this.orderId});

  @override
  State<CustomerOrderDetailPage> createState() =>
      _CustomerOrderDetailPageState();
}

class _CustomerOrderDetailPageState extends State<CustomerOrderDetailPage> {
  SaleModel? order;
  List<SaleItemModel>? items;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    if (mounted) setState(() => isLoading = true);
    try {
      final repo = Get.find<CartController>();
      final orderData = await repo.fetchOrderById(widget.orderId);
      final itemsData = await repo.fetchOrderItems(widget.orderId);
      if (mounted) {
        setState(() {
          order = orderData;
          items = itemsData;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomerScaffold(
      page: 'Order Details',
      body: FB5Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(color: AppColors.marcatGold),
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Text('Error: $error'),
        ),
      );
    }

    if (order == null) return const SizedBox.shrink();

    final o = order!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          eyebrow: 'Order #${o.id}',
          title: 'Order Details',
          subtitle: 'Reference: ${o.referenceNumber}',
        ),
        const SizedBox(height: 28),
        _OrderSummaryCard(order: o),
        const SizedBox(height: 24),
        const Text('Items in your order',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.marcatBlack)),
        const SizedBox(height: 16),
        ...items!.map((item) => _OrderItemCard(item: item)),
      ],
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  final SaleModel order;
  const _OrderSummaryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          _Row(
              'Status', order.status.name.capitalizeFirst ?? order.status.name),
          const SizedBox(height: 12),
          _Row('Subtotal', order.subtotal.toJOD()),
          const SizedBox(height: 12),
          _Row('Discount', '-${order.discountTotal.toJOD()}',
              color: Colors.green),
          const SizedBox(height: 12),
          _Row('Shipping', order.shippingCost.toJOD()),
          const SizedBox(height: 16),
          const Divider(color: AppColors.borderLight),
          const SizedBox(height: 16),
          _Row('Grand Total', order.grandTotal.toJOD(), bold: true),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  final bool bold;
  final Color? color;
  const _Row(this.label, this.value, {this.bold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
        Text(value,
            style: TextStyle(
                fontSize: bold ? 16 : 14,
                color: color ?? AppColors.marcatBlack,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
      ],
    );
  }
}

class _OrderItemCard extends StatelessWidget {
  final SaleItemModel item;
  const _OrderItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.marcatCream.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.checkroom, color: AppColors.marcatBlack),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Product ID: ${item.productId}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.marcatBlack)),
                const SizedBox(height: 4),
                Text('Qty: ${item.quantity}',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(item.totalPrice.toJOD(),
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: AppColors.marcatBlack)),
        ],
      ),
    );
  }
}
