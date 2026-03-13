// lib/presentation/admin/products/product_form_screen.dart

import 'package:flutter/material.dart';
import '../../../controllers/product_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../shared/widgets/marcat_app_bar.dart';
import '../../shared/widgets/marcat_button.dart';
import '../../shared/widgets/marcat_text_field.dart';
import 'package:get/get.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.productId});

  final int? productId;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final sku = _skuController.text.trim();
    final priceStr = _priceController.text.trim();
    final price = double.tryParse(priceStr) ?? 0.0;

    if (name.isEmpty || price <= 0) {
      Get.snackbar('Error', 'Please fill name and a valid price');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = Get.find<ProductController>();
      final data = {
        'name': name,
        'sku': sku,
        'base_price': price,
        'status': 'active', // default
        'brand_id': null, // default
        'category_id': null, // default
      };

      if (widget.productId == null) {
        await repo.createProduct(data);
        Get.snackbar('Success', 'Product created');
      } else {
        await repo.updateProduct(widget.productId!, data);
        Get.snackbar('Success', 'Product updated');
      }
      Get.back();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: MarcatAppBar(
        title: widget.productId == null ? 'Add Product' : 'Edit Product',
        backgroundColor: AppColors.marcatCream,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.space24),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Basic Information', style: AppTextStyles.titleMedium),
                  const SizedBox(height: AppDimensions.space24),
                  MarcatTextField(
                    controller: _nameController,
                    label: 'Product Name',
                  ),
                  const SizedBox(height: AppDimensions.space16),
                  Row(
                    children: [
                      Expanded(
                        child: MarcatTextField(
                          controller: _skuController,
                          label: 'SKU',
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space16),
                      Expanded(
                        child: MarcatTextField(
                          controller: _priceController,
                          label: 'Base Price (JOD)',
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space16),
                  const MarcatTextArea(
                    label: 'Description',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space24),
            MarcatButton(
              label:
                  widget.productId == null ? 'Create Product' : 'Save Changes',
              isLoading: _isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
