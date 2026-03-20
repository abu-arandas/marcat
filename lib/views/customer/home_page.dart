// lib/views/customer/home_page.dart

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import 'package:marcat/controllers/auth_controller.dart';
import 'package:marcat/controllers/product_controller.dart';
import 'package:marcat/core/extensions/currency_extensions.dart';
import 'package:marcat/core/router/app_router.dart';
import 'package:marcat/models/category_model.dart';
import 'package:marcat/models/offer_model.dart';
import 'package:marcat/models/product_model.dart';

import 'scaffold/app_scaffold.dart';
import 'shared/brand.dart';
import 'shared/buttons.dart';
import 'shared/section_header.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HomePage
// ─────────────────────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ── Data ─────────────────────────────────────────────────────────────────
  final _newArrivals = <ProductModel>[];
  final _bestSellers = <ProductModel>[];
  final _categories = <CategoryModel>[];
  final _offers = <OfferModel>[];
  final _wishlistedIds = <int>{};

  // ── Loading flags ─────────────────────────────────────────────────────────
  bool _loadingArrivals = true;
  bool _loadingBestSellers = true;
  bool _loadingCategories = true;
  bool _loadingOffers = true;

  // ── Error messages ────────────────────────────────────────────────────────
  String? _arrivalsError;
  String? _bestSellersError;
  String? _categoriesError;


  // ── Controllers ───────────────────────────────────────────────────────────
  ProductController get _productCtrl => Get.find<ProductController>();
  AuthController get _auth => Get.find<AuthController>();

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() => Future.wait([
        _loadCategories(),
        _loadNewArrivals(),
        _loadBestSellers(),
        _loadWishlist(),
        _loadOffers(),
      ]);

  // ── Loaders ───────────────────────────────────────────────────────────────

  Future<void> _loadNewArrivals() async {
    if (mounted) setState(() => _loadingArrivals = true);
    _arrivalsError = null;
    try {
      final products = await _productCtrl.fetchNewArrivals(limit: 8);
      if (mounted) {
        setState(() {
          _newArrivals
            ..clear()
            ..addAll(products);
          _loadingArrivals = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _arrivalsError = 'Could not load new arrivals.';
          _loadingArrivals = false;
        });
      }
    }
  }

  Future<void> _loadBestSellers() async {
    if (mounted) setState(() => _loadingBestSellers = true);
    _bestSellersError = null;
    try {
      final products = await _productCtrl.fetchTopProducts(limit: 8);
      if (mounted) {
        setState(() {
          _bestSellers
            ..clear()
            ..addAll(products);
          _loadingBestSellers = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _bestSellersError = 'Could not load best sellers.';
          _loadingBestSellers = false;
        });
      }
    }
  }

  Future<void> _loadCategories() async {
    if (mounted) setState(() => _loadingCategories = true);
    _categoriesError = null;
    try {
      final cats = _productCtrl.categories;
      if (cats.isNotEmpty) {
        if (mounted) {
          setState(() {
            _categories
              ..clear()
              ..addAll(cats);
            _loadingCategories = false;
          });
        }
        return;
      }
      await _productCtrl.loadCategories();
      if (mounted) {
        setState(() {
          _categories
            ..clear()
            ..addAll(_productCtrl.categories);
          _loadingCategories = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _categoriesError = 'Could not load categories.';
          _loadingCategories = false;
        });
      }
    }
  }

  Future<void> _loadWishlist() async {
    final uid = _auth.state.value.user?.id;
    if (uid == null) return;
    try {
      await _productCtrl.loadWishlist(uid);
      if (mounted) {
        setState(() {
          _wishlistedIds
            ..clear()
            ..addAll(
              _productCtrl.wishlistItems.map((w) => w.productId),
            );
        });
      }
    } catch (_) {
      // Non-critical — wishlist icon simply shows un-wishlisted state.
    }
  }

  Future<void> _loadOffers() async {
    if (mounted) setState(() => _loadingOffers = true);
    try {
      final offers = await _productCtrl.fetchActiveOffers();
      if (mounted) {
        setState(() {
          _offers
            ..clear()
            ..addAll(offers);
          _loadingOffers = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingOffers = false;
        });
      }
    }
  }

  Future<void> _toggleWishlist(int productId) async {
    final uid = _auth.state.value.user?.id;
    if (uid == null) {
      Get.toNamed(AppRoutes.login);
      return;
    }
    try {
      final nowIn = await _productCtrl.toggleWishlist(uid, productId);
      if (mounted) {
        setState(() {
          if (nowIn) {
            _wishlistedIds.add(productId);
          } else {
            _wishlistedIds.remove(productId);
          }
        });
      }
    } catch (_) {
      // Silent — wishlist toggle failure is non-critical on the home page.
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return CustomerScaffold(
      page: 'Home',
      body: Column(
        children: [
          // Section 1 — Hero carousel
          _HeroCarousel(offers: _offers, isLoading: _loadingOffers),

          // Section 2 — Category strip
          _CategoryStrip(
            categories: _categories,
            isLoading: _loadingCategories,
            error: _categoriesError,
          ),

          const SizedBox(height: 72),

          // Section 3 — New Arrivals
          _NewArrivalsSection(
            products: _newArrivals,
            isLoading: _loadingArrivals,
            error: _arrivalsError,
            isWishlisted: (id) => _wishlistedIds.contains(id),
            onToggleWishlist: _toggleWishlist,
            onRefresh: _loadNewArrivals,
          ),

          const SizedBox(height: 72),

          // Section 4 — Editorial Banner
          const EditorialBanner(),

          const SizedBox(height: 72),

          // Section 5 — Best Sellers
          _BestSellersSection(
            products: _bestSellers,
            isLoading: _loadingBestSellers,
            error: _bestSellersError,
            isWishlisted: (id) => _wishlistedIds.contains(id),
            onToggleWishlist: _toggleWishlist,
            onRefresh: _loadBestSellers,
          ),

          const SizedBox(height: 72),

          // Section 6 — Brand values strip
          const BrandValues(),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 1 — HeroCarousel
// ─────────────────────────────────────────────────────────────────────────────

class _HeroCarousel extends StatefulWidget {
  const _HeroCarousel({required this.offers, required this.isLoading});

  final List<OfferModel> offers;
  final bool isLoading;

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  int _current = 0;
  Timer? _timer;

  static const _slides = [
    _HeroSlide(
      image:
          'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=1600&q=80',
      eyebrow: 'New Collection',
      title: 'Crafted for\nModern Men',
      cta: 'Shop Now',
    ),
    _HeroSlide(
      image:
          'https://images.unsplash.com/photo-1516762689617-e1cffcef479d?w=1600&q=80',
      eyebrow: 'Premium Essentials',
      title: 'Timeless Style,\nElevated',
      cta: 'Explore',
    ),
    _HeroSlide(
      image:
          'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?w=1600&q=80',
      eyebrow: 'Exclusive Deals',
      title: 'Dress Better,\nPay Less',
      cta: 'View Offers',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        setState(() => _current = (_current + 1) % _slides.length);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).width > 768 ? 620.0 : 480.0;

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // ── Slide image ───────────────────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            child: CachedNetworkImage(
              key: ValueKey(_current),
              imageUrl: _slides[_current].image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: height,
              placeholder: (_, __) =>
                  const ColoredBox(color: kNavy),
              errorWidget: (_, __, ___) =>
                  const ColoredBox(color: kNavy),
            ),
          ),

          // ── Gradient overlay ──────────────────────────────────────────────
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [
                  Colors.black.withAlpha(20),
                  Colors.black.withAlpha(160),
                ],
              ),
            ),
          ),

          // ── Hero copy ─────────────────────────────────────────────────────
          Align(
            alignment: Alignment.centerLeft,
            child: FB5Container(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Eyebrow
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 2,
                            color: kGold,
                            margin: const EdgeInsets.only(right: 10),
                          ),
                          Text(
                            _slides[_current].eyebrow.toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'IBMPlexSansArabic',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: kGold,
                              letterSpacing: 2.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Headline
                      Text(
                        _slides[_current].title,
                        style: const TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontSize: 52,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // CTA
                      _ShopCtaButton(
                        label: _slides[_current].cta,
                        onTap: () => Get.toNamed(AppRoutes.shop),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Slide indicators ──────────────────────────────────────────────
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                final active = i == _current;
                return GestureDetector(
                  onTap: () => setState(() => _current = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active ? kGold : Colors.white.withAlpha(100),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSlide {
  final String image;
  final String eyebrow;
  final String title;
  final String cta;

  const _HeroSlide({
    required this.image,
    required this.eyebrow,
    required this.title,
    required this.cta,
  });
}

// ── CTA button ─────────────────────────────────────────────────────────────

class _ShopCtaButton extends StatefulWidget {
  const _ShopCtaButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_ShopCtaButton> createState() => _ShopCtaButtonState();
}

class _ShopCtaButtonState extends State<_ShopCtaButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            decoration: BoxDecoration(
              color: _hovered ? kGold : Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _hovered ? Colors.white : kNavy,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: _hovered ? Colors.white : kNavy,
                ),
              ],
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 2 — CategoryStrip
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip({
    required this.categories,
    required this.isLoading,
    required this.error,
  });

  final List<CategoryModel> categories;
  final bool isLoading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: FB5Container(
        child: Column(
          children: [
            SectionHeader(
              eyebrow: 'Browse',
              title: 'Shop by Category',
              subtitle: 'Discover our curated collections.',
            ),
            const SizedBox(height: 32),
            if (isLoading)
              _CategorySkeleton()
            else if (error != null)
              _ErrorRetry(message: error!, onRetry: () {})
            else if (categories.isEmpty)
              const SizedBox.shrink()
            else
              _buildGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 900;
    final cols = isDesktop ? 4 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: categories.length > 8 ? 8 : categories.length,
      itemBuilder: (_, i) => _CategoryCard(category: categories[i]),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  const _CategoryCard({required this.category});
  final CategoryModel category;

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: () => Get.toNamed(
            AppRoutes.category.replaceFirst(':id', '${widget.category.id}'),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image
                AnimatedScale(
                  scale: _hovered ? 1.06 : 1.0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  child: ColoredBox(color: kNavy),
                ),

                // Dark overlay
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withAlpha(30),
                        Colors.black.withAlpha(140),
                      ],
                    ),
                  ),
                ),

                // Label
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      widget.category.name.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 3 — NewArrivalsSection
// ─────────────────────────────────────────────────────────────────────────────

class _NewArrivalsSection extends StatelessWidget {
  const _NewArrivalsSection({
    required this.products,
    required this.isLoading,
    required this.error,
    required this.isWishlisted,
    required this.onToggleWishlist,
    required this.onRefresh,
  });

  final List<ProductModel> products;
  final bool isLoading;
  final String? error;
  final bool Function(int id) isWishlisted;
  final ValueChanged<int> onToggleWishlist;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return FB5Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SectionHeader(
              eyebrow: 'Fresh In',
              title: 'New Arrivals',
              subtitle: 'The latest pieces to hit our shelves.',
              action: _TextAction(
                label: 'Shop All',
                onTap: () => Get.toNamed(AppRoutes.shop),
              ),
            ),
          ),
          const SizedBox(height: 32),
          if (isLoading)
            _HorizontalProductSkeleton()
          else if (error != null)
            _ErrorRetry(message: error!, onRetry: onRefresh)
          else if (products.isEmpty)
            const _EmptyHint(message: 'No new arrivals yet.')
          else
            SizedBox(
              height: 380,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                clipBehavior: Clip.none,
                itemCount: products.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 240,
                    child: _ProductCard(
                      product: products[i],
                      isWishlisted: isWishlisted(products[i].id),
                      onToggleWishlist: () => onToggleWishlist(products[i].id),
                      isNew: true,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 4 — EditorialBanner  (static marketing content)
// ─────────────────────────────────────────────────────────────────────────────

class EditorialBanner extends StatelessWidget {
  const EditorialBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 768;
    return Container(
      color: kNavy,
      child: isDesktop ? _desktopLayout(context) : _mobileLayout(context),
    );
  }

  Widget _desktopLayout(BuildContext context) => FB5Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 72),
          child: FB5Row(
            children: [
              FB5Col(
                classNames: 'col-lg-6 col-12',
                child: _editorialText(),
              ),
              FB5Col(
                classNames: 'col-lg-6 col-12',
                child: _editorialImage(),
              ),
            ],
          ),
        ),
      );

  Widget _mobileLayout(BuildContext context) => Column(
        children: [
          _editorialImage(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: _editorialText(),
          ),
        ],
      );

  Widget _editorialText() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SectionHeader(
            eyebrow: 'Our Craft',
            title: 'Every Thread\nTells a Story',
            subtitle:
                'We partner with artisans and premium suppliers to bring you '
                'clothing that lasts beyond the season.',
            dark: true,
            action: _TextAction(
              label: 'Our Story',
              dark: true,
              onTap: () => Get.toNamed(AppRoutes.about),
            ),
          ),
        ],
      );

  Widget _editorialImage() => AspectRatio(
        aspectRatio: 4 / 3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: CachedNetworkImage(
            imageUrl:
                'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?w=900&q=80',
            fit: BoxFit.cover,
            placeholder: (_, __) => const ColoredBox(color: Color(0xFF2E2E4E)),
            errorWidget: (_, __, ___) =>
                const ColoredBox(color: Color(0xFF2E2E4E)),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 5 — BestSellersSection
// ─────────────────────────────────────────────────────────────────────────────

class _BestSellersSection extends StatelessWidget {
  const _BestSellersSection({
    required this.products,
    required this.isLoading,
    required this.error,
    required this.isWishlisted,
    required this.onToggleWishlist,
    required this.onRefresh,
  });

  final List<ProductModel> products;
  final bool isLoading;
  final String? error;
  final bool Function(int id) isWishlisted;
  final ValueChanged<int> onToggleWishlist;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cols = width > 900 ? 4 : (width > 600 ? 3 : 2);

    return FB5Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SectionHeader(
              eyebrow: 'Popular',
              title: 'Best Sellers',
              subtitle: 'Our most-loved pieces — loved for good reason.',
              action: _TextAction(
                label: 'Shop All',
                onTap: () => Get.toNamed(AppRoutes.shop),
              ),
            ),
          ),
          const SizedBox(height: 32),
          if (isLoading)
            _GridProductSkeleton(cols: cols)
          else if (error != null)
            _ErrorRetry(message: error!, onRetry: onRefresh)
          else if (products.isEmpty)
            const _EmptyHint(message: 'No best sellers yet.')
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 16,
                mainAxisSpacing: 20,
                childAspectRatio: 0.62,
              ),
              itemCount: products.length,
              itemBuilder: (_, i) => _ProductCard(
                product: products[i],
                isWishlisted: isWishlisted(products[i].id),
                onToggleWishlist: () => onToggleWishlist(products[i].id),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 6 — BrandValues  (static)
// ─────────────────────────────────────────────────────────────────────────────

class _ValueItem {
  final IconData icon;
  final String title;
  final String desc;
  const _ValueItem(this.icon, this.title, this.desc);
}

const _kValues = [
  _ValueItem(
    Icons.local_shipping_outlined,
    'Free Shipping',
    'On all orders above JOD 50',
  ),
  _ValueItem(
    Icons.replay_outlined,
    'Easy Returns',
    '30-day hassle-free returns',
  ),
  _ValueItem(
    Icons.verified_outlined,
    'Authentic Quality',
    'Sourced from premium suppliers',
  ),
  _ValueItem(
    Icons.support_agent_outlined,
    '24/7 Support',
    "We're always here to help",
  ),
];

class BrandValues extends StatelessWidget {
  const BrandValues({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 600;
    return Container(
      color: kCream,
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      child: FB5Container(
        child: isDesktop
            ? Row(
                children: _kValues
                    .map((v) => Expanded(child: _ValueTile(v)))
                    .toList(),
              )
            : GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: _kValues.map(_ValueTile.new).toList(),
              ),
      ),
    );
  }
}

class _ValueTile extends StatelessWidget {
  const _ValueTile(this.item);
  final _ValueItem item;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(item.icon, size: 32, color: kGold),
            const SizedBox(height: 12),
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: kNavy,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.desc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 12,
                color: kSlate,
              ),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared: Product Card  (home-page variant — "QUICK VIEW" overlay)
// ─────────────────────────────────────────────────────────────────────────────

class _ProductCard extends StatefulWidget {
  const _ProductCard({
    required this.product,
    required this.isWishlisted,
    required this.onToggleWishlist,
    this.isNew = false,
  });

  final ProductModel product;
  final bool isWishlisted;
  final VoidCallback onToggleWishlist;
  final bool isNew;

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _hovered = false;

  void _openProduct() =>
      Get.toNamed('/app/product/${widget.product.id}');

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: _openProduct,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image container ───────────────────────────────────────────
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Product image with zoom on hover
                      AnimatedScale(
                        scale: _hovered ? 1.06 : 1.0,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        child: CachedNetworkImage(
                          imageUrl: widget.product.primaryImageUrl ??
                              'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=400&q=60',
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Shimmer.fromColors(
                            baseColor: const Color(0xFFEDE8DF),
                            highlightColor: const Color(0xFFF5F0E8),
                            child: const ColoredBox(color: Colors.white),
                          ),
                          errorWidget: (_, __, ___) =>
                              const ColoredBox(color: kCream),
                        ),
                      ),

                      // Badges
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Column(
                          children: [
                            if (widget.isNew) const _Badge('NEW', kGold),
                          ],
                        ),
                      ),

                      // Wishlist toggle
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: widget.onToggleWishlist,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: widget.isWishlisted
                                  ? kNavy
                                  : Colors.white.withAlpha(230),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(20),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.isWishlisted
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_outline_rounded,
                              size: 18,
                              color: widget.isWishlisted ? Colors.white : kNavy,
                            ),
                          ),
                        ),
                      ),

                      // Quick View overlay (on hover)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: AnimatedOpacity(
                          opacity: _hovered ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: GestureDetector(
                            onTap: _openProduct,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              color: kNavy,
                              child: const Center(
                                child: Text(
                                  'QUICK VIEW',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Product metadata ──────────────────────────────────────────
              const Text(
                'COLLECTION',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: kSlate,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),

              Text(
                widget.product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kNavy,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),

              // Price row
              Row(
                children: [
                  Text(
                    widget.product.basePrice.toJOD(),
                    style: const TextStyle(
                      fontFamily: 'IBMPlexMono',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kNavy,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        color: color,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared: _TextAction  (trailing "View All" link)
// ─────────────────────────────────────────────────────────────────────────────

class _TextAction extends StatefulWidget {
  const _TextAction({
    required this.label,
    required this.onTap,
    this.dark = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool dark;

  @override
  State<_TextAction> createState() => _TextActionState();
}

class _TextActionState extends State<_TextAction> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _hovered
                      ? kGold
                      : (widget.dark ? Colors.white : kNavy),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: _hovered
                    ? kGold
                    : (widget.dark ? Colors.white : kNavy),
              ),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Skeleton loaders
// ─────────────────────────────────────────────────────────────────────────────

class _CategorySkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFEDE8DF),
      highlightColor: const Color(0xFFF5F0E8),
      child: GridView.count(
        crossAxisCount: MediaQuery.sizeOf(context).width > 900 ? 4 : 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
        children: List.generate(
          8,
          (_) => ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const ColoredBox(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _HorizontalProductSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 380,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: 5,
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SizedBox(
              width: 240,
              child: Shimmer.fromColors(
                baseColor: const Color(0xFFEDE8DF),
                highlightColor: const Color(0xFFF5F0E8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const ColoredBox(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      );
}

class _GridProductSkeleton extends StatelessWidget {
  const _GridProductSkeleton({required this.cols});
  final int cols;

  @override
  Widget build(BuildContext context) => GridView.count(
        crossAxisCount: cols,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
        childAspectRatio: 0.62,
        children: List.generate(
          8,
          (_) => Shimmer.fromColors(
            baseColor: const Color(0xFFEDE8DF),
            highlightColor: const Color(0xFFF5F0E8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: const ColoredBox(color: Colors.white),
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Error / empty helpers
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Text(message,
                style: const TextStyle(color: kSlate, fontSize: 14)),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Retry',
              onPressed: onRetry,
              height: 42,
            ),
          ],
        ),
      );
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Text(
          message,
          style: const TextStyle(color: kSlate, fontSize: 14),
        ),
      );
}

// Avoids unused import for AppColors (used via kNavy / kGold / brand.dart).
// ignore_for_file: unused_import
class AppColors {}
