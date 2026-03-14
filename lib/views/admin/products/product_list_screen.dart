// lib/views/admin/products/product_list_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/product_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import 'package:marcat/models/product_model.dart';
import 'package:marcat/models/enums.dart';
import '../../shared/widgets/marcat_app_bar.dart';
import '../../shared/widgets/marcat_badge.dart';

class AdminProductListScreen extends StatefulWidget {
  const AdminProductListScreen({super.key});

  @override
  State<AdminProductListScreen> createState() => _AdminProductListScreenState();
}

class _AdminProductListScreenState extends State<AdminProductListScreen> {
  List<ProductModel>? products;
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
      final (fetchedProducts, _) =
          await _productCtrl.fetchProducts(page: 0, pageSize: 50);
      if (mounted) {
        setState(() {
          products = fetchedProducts;
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
        title: 'Admin Products',
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed('/app/admin/products/add'),
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
      return Center(child: Text(errorMessage!));
    }

    if (products == null || products!.isEmpty) {
      return const Center(child: Text("No products found"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      itemCount: products!.length,
      itemBuilder: (context, index) {
        final p = products![index];
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
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
                    child: Image.network(p.primaryImageUrl!,
                        width: 50, height: 70, fit: BoxFit.cover),
                  )
                : Container(
                    width: 50,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceGrey,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusXS),
                    ),
                    child: const Icon(Icons.image_not_supported),
                  ),
            title: Text(p.name, style: AppTextStyles.titleMedium),
            subtitle: Text(
              p.sku,
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.textSecondary),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MarcatStatusBadge.custom(
                  label: p.status.name.toUpperCase(),
                  color: p.status == ProductStatus.active
                      ? AppColors.statusGreen
                      : AppColors.statusAmber,
                ),
                const SizedBox(width: AppDimensions.space8),
                const Icon(Icons.chevron_right, color: AppColors.textDisabled),
              ],
            ),
            onTap: () {
              Get.toNamed('/app/admin/products/edit/${p.id}');
            },
          ),
        );
      },
    );
  }
}
