// lib/views/customer/shared/search_sheet.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:marcat/controllers/search_controller.dart';
import 'package:marcat/core/constants/app_colors.dart';
import 'package:marcat/core/constants/app_text_styles.dart';
import 'package:marcat/core/extensions/currency_extensions.dart';
import 'package:marcat/models/product_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SearchSheet
// ─────────────────────────────────────────────────────────────────────────────

/// Full-height modal bottom sheet for product search.
///
/// Shows category chips before typing, then live product results.
class SearchSheet extends StatelessWidget {
  const SearchSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const SearchSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<MarcatSearchController>();
    final height = MediaQuery.sizeOf(context).height * 0.9;

    return SizedBox(
      height: height,
      child: Column(
        children: [
          // ── Drag handle ───────────────────────────────────────────────
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderMedium,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // ── Search field ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _SearchField(ctrl: ctrl),
          ),
          const SizedBox(height: 20),

          // ── Results / suggestions ─────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Obx(
                () => ctrl.query.value.isEmpty
                    ? _SuggestionsSection(ctrl: ctrl)
                    : _ResultsSection(ctrl: ctrl),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SearchField
// ─────────────────────────────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  const _SearchField({required this.ctrl});

  final MarcatSearchController ctrl;

  @override
  Widget build(BuildContext context) => TextField(
        controller: ctrl.textController,
        autofocus: true,
        textInputAction: TextInputAction.search,
        onSubmitted: ctrl.submitQuery,
        style: const TextStyle(
          fontFamily: 'IBMPlexSansArabic',
          fontSize: 15,
          color: AppColors.marcatNavy,
        ),
        decoration: InputDecoration(
          hintText: 'Search clothing, brands…',
          hintStyle: const TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            color: AppColors.marcatSlate,
            fontSize: 15,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.marcatGold,
          ),
          suffixIcon: Obx(
            () => ctrl.isLoading.value
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.marcatGold,
                      ),
                    ),
                  )
                : ValueListenableBuilder<TextEditingValue>(
                    valueListenable: ctrl.textController,
                    builder: (_, value, __) => value.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: ctrl.clear,
                            color: AppColors.marcatSlate,
                          )
                        : const SizedBox.shrink(),
                  ),
          ),
          filled: true,
          fillColor: AppColors.marcatCream,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.marcatNavy,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _SuggestionsSection  (shown before any query is typed)
// ─────────────────────────────────────────────────────────────────────────────

class _SuggestionsSection extends StatelessWidget {
  const _SuggestionsSection({required this.ctrl});

  final MarcatSearchController ctrl;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('BROWSE CATEGORIES'),
          const SizedBox(height: 12),
          Obx(
            () => ctrl.isLoadingSuggestions.value
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.marcatGold,
                      ),
                    ),
                  )
                : ctrl.suggestions.isEmpty
                    ? const _EmptyHint('Start typing to search for products.')
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ctrl.suggestions
                            .map(
                              (cat) => _CategoryChip(
                                label: cat.name,
                                onTap: () => ctrl.submitCategory(cat),
                              ),
                            )
                            .toList(),
                      ),
          ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _ResultsSection  (shown after query is typed)
// ─────────────────────────────────────────────────────────────────────────────

class _ResultsSection extends StatelessWidget {
  const _ResultsSection({required this.ctrl});

  final MarcatSearchController ctrl;

  @override
  Widget build(BuildContext context) => Obx(() {
        if (ctrl.isSearching.value && ctrl.results.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.marcatGold,
              ),
            ),
          );
        }

        if (ctrl.results.isEmpty && ctrl.hasSearched.value) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.search_off_rounded,
                    size: 40,
                    color: AppColors.marcatSlate,
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => Text(
                      'No results for "${ctrl.query.value}"',
                      style: const TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        color: AppColors.marcatSlate,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (ctrl.results.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => _SectionLabel('${ctrl.results.length} RESULTS'),
            ),
            const SizedBox(height: 12),
            Obx(
              () => ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ctrl.results.length,
                separatorBuilder: (_, __) => const Divider(
                  color: AppColors.borderLight,
                  height: 1,
                ),
                itemBuilder: (_, i) => _ProductTile(
                  product: ctrl.results[i],
                  onTap: () => ctrl.submitProduct(ctrl.results[i]),
                ),
              ),
            ),
          ],
        );
      });
}

// ─────────────────────────────────────────────────────────────────────────────
// _ProductTile
// ─────────────────────────────────────────────────────────────────────────────

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product, required this.onTap});

  final ProductModel product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            width: 52,
            height: 64,
            child: product.primaryImageUrl != null
                ? CachedNetworkImage(
                    imageUrl: product.primaryImageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        const ColoredBox(color: AppColors.marcatCream),
                    errorWidget: (_, __, ___) =>
                        const ColoredBox(color: AppColors.marcatCream),
                  )
                : const ColoredBox(color: AppColors.marcatCream),
          ),
        ),
        title: Text(
          product.name,
          style: AppTextStyles.titleSmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          product.basePrice.toJOD(),
          style: AppTextStyles.priceSmall,
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.marcatSlate,
          size: 20,
        ),
        onTap: onTap,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _CategoryChip
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.marcatCream,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.marcatNavy,
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontFamily: 'IBMPlexSansArabic',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.8,
          color: AppColors.marcatSlate,
        ),
      );
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 14,
            color: AppColors.marcatSlate,
          ),
        ),
      );
}
