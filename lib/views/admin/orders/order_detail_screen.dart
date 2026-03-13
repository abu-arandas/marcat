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
import '../../shared/widgets/marcat_app_bar.dart';

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
      await _cartCtrl.updateOrderStatus(widget.orderId, newStatusStr,
          changedBy: 'Admin'); 
      Get.snackbar('Success', 'Order status updated');
      _fetchOrderDetails(); // Reload to get fresh state
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: const MarcatAppBar(
        title: 'Order Details',
        backgroundColor: AppColors.marcatCream,
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
      return Center(child: Text(errorMessage!));
    }

    if (order == null || items == null) {
      return const Center(child: Text("Order not found"));
    }

    final o = order!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Status', style: AppTextStyles.titleMedium),
                    DropdownButton<String>(
                      value: o.status.name,
                      items: SaleStatus.values.map((s) {
                        return DropdownMenuItem(
                          value: s.name,
                          child: Text(s.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          _updateStatus(val);
                        }
                      },
                    ),
                  ],
                ),
                const Divider(height: AppDimensions.space32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: AppTextStyles.bodyMedium),
                    Text(o.grandTotal.toJOD(),
                        style: AppTextStyles.titleLarge),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space16),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Items', style: AppTextStyles.titleMedium),
                const SizedBox(height: AppDimensions.space16),
                ...items!.map((i) {
                  return Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppDimensions.space12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceGrey,
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusXS),
                          ),
                          child: const Icon(Icons.checkroom),
                        ),
                        const SizedBox(width: AppDimensions.space12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Item #${i.productId}',
                                  style: AppTextStyles.bodyMedium),
                              Text('Size #${i.productSizeId}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Text('${i.quantity}x ${i.unitPrice.toJOD()}',
                            style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space24),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: child,
    );
  }
}
