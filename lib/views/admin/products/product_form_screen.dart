// lib/views/admin/products/product_form_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/product_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.productId});

  /// Null → create mode.  Non-null → edit mode.
  final int? productId;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;

  ProductController get _productCtrl => Get.find<ProductController>();

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      _prefillForm();
    }
  }

  /// Pre-fills the form when editing an existing product.
  Future<void> _prefillForm() async {
    setState(() => _isLoading = true);
    try {
      final product = await _productCtrl.fetchProductById(widget.productId!);
      if (mounted) {
        _nameController.text = product.name;
        _skuController.text = product.sku;
        _priceController.text = product.basePrice.toStringAsFixed(2);
        _descriptionController.text = product.description ?? '';
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not load product: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final sku = _skuController.text.trim();
    final priceStr = _priceController.text.trim();
    final price = double.tryParse(priceStr);

    if (price == null || price <= 0) {
      Get.snackbar('Validation Error', 'Please enter a valid price.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final data = {
        'name': name,
        'sku': sku,
        'base_price': price,
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'status': 'active',
      };

      if (widget.productId == null) {
        await _productCtrl.createProduct(data);
        Get.snackbar('Success', 'Product created successfully.');
      } else {
        await _productCtrl.updateProduct(widget.productId!, data);
        Get.snackbar('Success', 'Product updated successfully.');
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
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        title: widget.productId == null
            ? const Text('Add Product')
            : const Text('Edit Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Basic information card ─────────────────────────────────
              Container(
                padding: const EdgeInsets.all(AppDimensions.space24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Basic Information', style: AppTextStyles.titleMedium),
                    const SizedBox(height: AppDimensions.space24),

                    // Product name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Product name is required.'
                          : null,
                    ),
                    const SizedBox(height: AppDimensions.space16),

                    // SKU + Price row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _skuController,
                            decoration: const InputDecoration(
                              labelText: 'SKU',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'SKU is required.'
                                : null,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space16),
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(
                              labelText: 'Base Price (JOD)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Price is required.';
                              }
                              final p = double.tryParse(v.trim());
                              if (p == null || p <= 0) {
                                return 'Enter a valid price > 0.';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space16),

                    // Description (multi-line)
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.space24),

              // ── Submit button ──────────────────────────────────────────
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: Text(
                  widget.productId == null ? 'Create Product' : 'Save Changes',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
