// lib/views/admin/products/product_form_screen.dart
//
// Create / Edit product form.
//
// Mode is determined by the presence of [productId]:
//   null    → Create mode — blank form, "Create Product" CTA.
//   non-null → Edit mode   — prefills via [ProductController.fetchProductById].
//
// Categories and brands are loaded from [ProductController]; status is a
// segmented picker; store assignment is handled separately in inventory.
//
// ✅ REFACTORED: replaced local _FormSection with shared AdminFormSection.
// ✅ REFACTORED: all AppColors → brand.dart aliases.

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/product_controller.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/enums.dart';
import '../shared/admin_form_section.dart';
import '../shared/admin_widgets.dart';
import '../shared/brand.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ProductFormScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Form screen for creating or editing a product.
///
/// Accessible via:
///  - [AppRoutes.adminProductsCreate]   (productId == null)
///  - [AppRoutes.adminProductsEdit]     (productId != null)
class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.productId});

  /// Null → create mode.  Non-null → edit mode.
  final int? productId;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  // ── Form ──────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _skuCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  // ── State ─────────────────────────────────────────────────────────────────
  bool _isPrefilling = false;
  bool _isSubmitting = false;
  ProductStatus _status = ProductStatus.active;
  int? _selectedCategoryId;
  int? _selectedBrandId;

  bool get _isEditMode => widget.productId != null;

  ProductController get _productCtrl => Get.find<ProductController>();

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadMeta();
    if (_isEditMode) _prefillForm();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _skuCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // ── Data ──────────────────────────────────────────────────────────────────

  /// Ensures categories + brands are available for dropdowns.
  Future<void> _loadMeta() async {
    if (_productCtrl.categories.isEmpty || _productCtrl.brands.isEmpty) {
      await _productCtrl.loadCatalogMeta();
    }
  }

  /// Populates form fields when editing an existing product.
  Future<void> _prefillForm() async {
    setState(() => _isPrefilling = true);
    try {
      final product = await _productCtrl.fetchProductById(widget.productId!);
      if (!mounted) return;
      _nameCtrl.text = product.name;
      _skuCtrl.text = product.sku;
      _priceCtrl.text = product.basePrice.toStringAsFixed(2);
      _descCtrl.text = product.description ?? '';
      setState(() {
        _status = ProductStatusX.fromDb(product.status.toString());
        _selectedCategoryId = product.categoryId;
        _selectedBrandId = product.brandId;
        _isPrefilling = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isPrefilling = false);
        Get.snackbar(
          'Error',
          'Could not load product: $e',
          snackPosition: SnackPosition.TOP,
          backgroundColor: kRedLight,
          colorText: kRed,
        );
      }
    }
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceCtrl.text.trim());
    if (price == null || price <= 0) {
      Get.snackbar('Validation Error', 'Please enter a valid price.');
      return;
    }

    if (!mounted) return;
    setState(() => _isSubmitting = true);

    try {
      final data = <String, dynamic>{
        'name': _nameCtrl.text.trim(),
        'sku': _skuCtrl.text.trim(),
        'base_price': price,
        'status': _status.dbValue,
        if (_descCtrl.text.trim().isNotEmpty)
          'description': _descCtrl.text.trim(),
        if (_selectedCategoryId != null) 'category_id': _selectedCategoryId,
        if (_selectedBrandId != null) 'brand_id': _selectedBrandId,
      };

      if (!_isEditMode) {
        await _productCtrl.createProduct(data);
        _showSuccess('Product created successfully.');
      } else {
        await _productCtrl.updateProduct(widget.productId!, data);
        _showSuccess('Product updated successfully.');
      }

      if (mounted) Get.back();
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          e.toString(),
          snackPosition: SnackPosition.TOP,
          backgroundColor: kRedLight,
          colorText: kRed,
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccess(String message) => Get.snackbar(
        'Success',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: kSuccessGreenLight,
        colorText: kGreen,
      );

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Product' : 'New Product'),
        centerTitle: false,
      ),
      body: _isPrefilling ? const AdminFormSkeleton() : _buildForm(context),
    );
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      child: Center(
        child: ConstrainedBox(
          // Cap form width on wide screens for readability.
          constraints: const BoxConstraints(maxWidth: 720),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Basic information ──────────────────────────────────────
                // ✅ Uses shared AdminFormSection instead of local _FormSection
                AdminFormSection(
                  title: 'Basic Information',
                  icon: Icons.info_outline_rounded,
                  children: [
                    // Product name
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Product Name *',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Product name is required.'
                          : null,
                    ),
                    const SizedBox(height: AppDimensions.space16),

                    // SKU + Price row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _skuCtrl,
                            decoration: const InputDecoration(
                              labelText: 'SKU *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'SKU is required.'
                                : null,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space16),
                        Expanded(
                          child: TextFormField(
                            controller: _priceCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Price (JOD) *',
                              border: OutlineInputBorder(),
                              prefixText: 'JD ',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Price is required.';
                              }
                              final p = double.tryParse(v.trim());
                              return (p == null || p <= 0)
                                  ? 'Enter a price greater than 0.'
                                  : null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space16),

                    // Description
                    TextFormField(
                      controller: _descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.space24),

                // ── Classification ─────────────────────────────────────────
                AdminFormSection(
                  title: 'Classification',
                  icon: Icons.label_outline_rounded,
                  children: [
                    // Category dropdown
                    Obx(() {
                      final cats = _productCtrl.categories;
                      return DropdownButtonFormField<int?>(
                        value: _selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('— None —'),
                          ),
                          ...cats.map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedCategoryId = v),
                      );
                    }),
                    const SizedBox(height: AppDimensions.space16),

                    // Brand dropdown
                    Obx(() {
                      final brands = _productCtrl.brands;
                      return DropdownButtonFormField<int?>(
                        value: _selectedBrandId,
                        decoration: const InputDecoration(
                          labelText: 'Brand',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('— None —'),
                          ),
                          ...brands.map(
                            (b) => DropdownMenuItem(
                              value: b.id,
                              child: Text(b.name),
                            ),
                          ),
                        ],
                        onChanged: (v) => setState(() => _selectedBrandId = v),
                      );
                    }),
                  ],
                ),

                const SizedBox(height: AppDimensions.space24),

                // ── Status ────────────────────────────────────────────────
                AdminFormSection(
                  title: 'Visibility',
                  icon: Icons.visibility_outlined,
                  children: [
                    Text(
                      'Product Status',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: kTextSecondary),
                    ),
                    const SizedBox(height: AppDimensions.space8),
                    _StatusSelector(
                      selected: _status,
                      onChanged: (s) => setState(() => _status = s),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.space32),

                // ── Submit ────────────────────────────────────────────────
                FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: kNavy,
                    foregroundColor: kTextOnDark,
                    minimumSize: const Size.fromHeight(
                        AppDimensions.buttonHeightPrimary),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusS),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isEditMode ? 'Save Changes' : 'Create Product',
                          style: AppTextStyles.labelLarge
                              .copyWith(color: kTextOnDark),
                        ),
                ),

                const SizedBox(height: AppDimensions.space64),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _StatusSelector
// ─────────────────────────────────────────────────────────────────────────────

/// Segmented button row to pick Active / Draft / Archived.
class _StatusSelector extends StatelessWidget {
  const _StatusSelector({
    required this.selected,
    required this.onChanged,
  });

  final ProductStatus selected;
  final ValueChanged<ProductStatus> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedButton<ProductStatus>(
        segments: const [
          ButtonSegment(
            value: ProductStatus.active,
            icon: Icon(Icons.check_circle_outline_rounded, size: 16),
            label: Text('Active'),
          ),
          ButtonSegment(
            value: ProductStatus.draft,
            icon: Icon(Icons.edit_note_rounded, size: 16),
            label: Text('Draft'),
          ),
          ButtonSegment(
            value: ProductStatus.archived,
            icon: Icon(Icons.archive_outlined, size: 16),
            label: Text('Archived'),
          ),
        ],
        selected: {selected},
        onSelectionChanged: (Set<ProductStatus> s) => onChanged(s.first),
        style: ButtonStyle(
          side: WidgetStateProperty.all(
              const BorderSide(color: kBorderMedium)),
        ),
      );
}
