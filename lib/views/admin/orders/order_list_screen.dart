// lib/views/admin/orders/order_list_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/cart_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/currency_extensions.dart';
import 'package:marcat/models/sale_model.dart';
import 'package:marcat/models/enums.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../shared/widgets/marcat_app_bar.dart';
import '../../shared/widgets/marcat_badge.dart';

class AdminOrderListScreen extends StatefulWidget {
  const AdminOrderListScreen({super.key});

  @override
  State<AdminOrderListScreen> createState() => _AdminOrderListScreenState();
}

class _AdminOrderListScreenState extends State<AdminOrderListScreen> {
  List<SaleModel>? orders;
  bool isLoading = true;
  String? errorMessage;

  CartController get _cartCtrl => Get.find<CartController>();

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final (fetchedOrders, _) = await _cartCtrl.fetchOrders(page: 0, pageSize: 50);
      if (mounted) {
        setState(() {
          orders = fetchedOrders;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: MarcatAppBar(
        title: context.l10n.adminOrders,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchOrders,
        color: AppColors.marcatGold,
        child: _buildBody(),
      ),
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

    if (orders == null || orders!.isEmpty) {
      return const Center(child: Text("No orders found"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      itemCount: orders!.length,
      itemBuilder: (context, index) {
        final o = orders![index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: AppDimensions.space12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            side: const BorderSide(color: AppColors.borderLight),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      o.referenceNumber,
                      style: AppTextStyles.titleMedium,
                    ),
                    MarcatStatusBadge.forSaleStatus(o.status, context),
                  ],
                ),
                const SizedBox(height: AppDimensions.space8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      o.createdAt.toDeviceShortDate(),
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    Text(
                      o.grandTotal.toJOD(),
                      style: AppTextStyles.titleMedium,
                    ),
                  ],
                ),
                const Divider(height: AppDimensions.space24),
                Row(
                  children: [
                    Icon(
                      o.channel == SaleChannel.online
                          ? Icons.public
                          : Icons.point_of_sale,
                      size: 16,
                      color: AppColors.textDisabled,
                    ),
                    const SizedBox(width: AppDimensions.space8),
                    Text(
                      o.channel.name.toUpperCase(),
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Get.toNamed('/app/admin/orders/${o.id}');
                      },
                      child: const Text('View Details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
