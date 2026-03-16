// lib/views/customer/shared/search_sheet.dart

import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';

import '../../../controllers/search_controller.dart';
import '../../../models/product_model.dart';

class SearchSheet extends StatelessWidget {
  const SearchSheet({super.key});

  static void show(BuildContext context) =>
      showDialog(context: context, builder: (_) => SearchSheet());

  @override
  Widget build(BuildContext context) => GetBuilder<MarcatSearchController>(
        init: MarcatSearchController(),
        builder: (ctrl) => AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Search',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Get.back(),
                color: const Color(0xFF9E9E9E),
                tooltip: 'Close',
              ),
            ],
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search field
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: _SearchField(ctrl: ctrl),
                ),

                // Scrollable body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: ctrl.textController.text.trim().isEmpty
                        ? _SuggestionsSection(ctrl: ctrl)
                        : _ResultsSection(ctrl: ctrl),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _SearchField extends StatelessWidget {
  const _SearchField({required this.ctrl});

  final MarcatSearchController ctrl;

  @override
  Widget build(BuildContext context) => TextField(
        controller: ctrl.textController,
        autofocus: true,
        textInputAction: TextInputAction.search,
        onSubmitted: ctrl.submitQuery,
        decoration: InputDecoration(
          hintText: 'Search clothing, brandsâ€¦',
          hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 15),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          suffixIcon: Obx(
            () => ctrl.isLoading.value
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : ValueListenableBuilder(
                    valueListenable: ctrl.textController,
                    builder: (_, value, __) => value.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: ctrl.textController.clear,
                            color: const Color(0xFF9E9E9E),
                          )
                        : const SizedBox.shrink(),
                  ),
          ),
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
}

class _SuggestionsSection extends StatelessWidget {
  const _SuggestionsSection({required this.ctrl});

  final SearchController ctrl;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('TRENDING CATEGORIES'),
          const SizedBox(height: 10),
          Obx(
            () => ctrl.isLoadingSuggestions.value
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : ctrl.suggestions.isEmpty
                    ? const SizedBox.shrink()
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ctrl.suggestions
                            .map((cat) => _CategoryChip(
                                  label: cat.name,
                                  onTap: () => ctrl.submitCategory(cat),
                                  context: context,
                                ))
                            .toList(),
                      ),
          ),
        ],
      );
}

class _ResultsSection extends StatelessWidget {
  const _ResultsSection({required this.ctrl});

  final SearchController ctrl;

  @override
  Widget build(BuildContext context) => Obx(
        () {
          if (ctrl.isSearching.value && ctrl.results.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          if (ctrl.results.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'No results for "${ctrl.textController.text.trim()}"',
                  style: const TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel('${ctrl.results.length} RESULTS'),
              const SizedBox(height: 10),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ctrl.results.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) => _ProductTile(
                  product: ctrl.results[i],
                  onTap: () => ctrl.submitProduct(ctrl.results[i]),
                ),
              ),
            ],
          );
        },
      );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF9E9E9E),
          letterSpacing: 1.5,
        ),
      );
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.onTap,
    required this.context,
  });

  final String label;
  final VoidCallback onTap;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) => ActionChip(
        label: Text(label),
        onPressed: onTap,
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFFEEE8E0)),
        labelStyle: TextStyle(
          fontSize: 13,
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      );
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product, required this.onTap});

  final ProductModel product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
        leading: product.primaryImageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.primaryImageUrl!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
                ),
              )
            : const _ImagePlaceholder(),
        title: Text(
          product.name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '\$${product.basePrice.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            size: 14, color: Color(0xFFCCCCCC)),
        onTap: onTap,
      );
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) => Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.image_outlined,
            size: 20, color: Color(0xFFCCCCCC)),
      );
}
