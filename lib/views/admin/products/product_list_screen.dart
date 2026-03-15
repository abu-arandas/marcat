// lib/views/admin/products/product_list_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/product_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import 'package:marcat/core/router/app_router.dart';

class AdminProductListScreen extends StatefulWidget {
  const AdminProductListScreen({super.key});

  @override
  State<AdminProductListScreen> createState() => _AdminProductListScreenState();
}

class _AdminProductListScreenState extends State<AdminProductListScreen> {
  bool isLoading = true;
  String? errorMessage;

  ProductController get _productCtrl => Get.find<ProductController>();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      await _productCtrl.fetchProducts(page: 0, pageSize: 50);
      if (mounted) setState(() => isLoading = false);
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
      appBar: AppBar(
        title: const Text('Products'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Product',
            onPressed: () => Get.toNamed(AppRoutes.adminProductsCreate),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchProducts,
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
                onPressed: _fetchProducts,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Obx(() {
      final products = _productCtrl.products;

      if (products.isEmpty) {
        return const Center(child: Text('No products found.'));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final p = products[index];
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: AppDimensions.space12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              side: const BorderSide(color: AppColors.borderLight),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(AppDimensions.space12),
              leading: p.primaryImageUrl != null
                  ? ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusXS),
                      child: Image.network(
                        p.primaryImageUrl!,
                        width: 50,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 50,
                          height: 70,
                          color: AppColors.surfaceGrey,
                          child: const Icon(Icons.image_not_supported,
                              size: 20, color: AppColors.textDisabled),
                        ),
                      ),
                    )
                  : Container(
                      width: 50,
                      height: 70,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceGrey,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusXS),
                      ),
                      child: const Icon(Icons.checkroom,
                          size: 20, color: AppColors.textDisabled),
                    ),
              title: Text(p.name, style: AppTextStyles.titleMedium),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.sku,
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  Text(
                    'JOD ${p.basePrice.toStringAsFixed(2)}',
                    style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.marcatGold, fontFamily: 'IBMPlexMono'),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // TODO: Add status badge
                  const SizedBox(width: AppDimensions.space8),
                  const Icon(Icons.chevron_right,
                      color: AppColors.textDisabled),
                ],
              ),
              onTap: () {
                Get.toNamed(AppRoutes.adminProductEditOf(p.id));
              },
            ),
          );
        },
      );
    });
  }
}
