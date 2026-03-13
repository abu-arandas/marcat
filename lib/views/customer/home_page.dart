// lib/views/customer/home_page.dart

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:marcat/core/constants/app_colors.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';

import 'scaffold/app_scaffold.dart';
import 'package:marcat/core/router/app_router.dart';
import 'package:marcat/controllers/auth_controller.dart';
import 'package:marcat/controllers/product_controller.dart';
import 'package:marcat/models/product_model.dart';
import 'package:marcat/models/category_model.dart';
import 'package:marcat/models/offer_model.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//  Brand tokens
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final newArrivals = <ProductModel>[];
  final bestSellers = <ProductModel>[];
  final categories = <CategoryModel>[];
  final offers = <OfferModel>[];
  final wishlistedIds = <int>{};

  bool isLoadingArrivals = true;
  bool isLoadingBestSellers = true;
  bool isLoadingCategories = true;
  bool isLoadingOffers = true;

  String? arrivalsError;
  String? bestSellersError;
  String? categoriesError;
  String? offersError;

  ProductController get _productCtrl => Get.find<ProductController>();
  AuthController get _auth => Get.find<AuthController>();

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

  Future<void> _loadNewArrivals() async {
    if (mounted) setState(() => isLoadingArrivals = true);
    arrivalsError = null;
    try {
      final products = await _productCtrl.fetchNewArrivals(limit: 8);
      if (mounted) {
        setState(() {
          newArrivals.clear();
          newArrivals.addAll(products);
        });
      }
    } catch (_) {
      arrivalsError = 'Could not load new arrivals.';
    } finally {
      if (mounted) setState(() => isLoadingArrivals = false);
    }
  }

  Future<void> _loadBestSellers() async {
    if (mounted) setState(() => isLoadingBestSellers = true);
    bestSellersError = null;
    try {
      final products = await _productCtrl.fetchTopProducts(limit: 4);
      if (mounted) {
        setState(() {
          bestSellers.clear();
          bestSellers.addAll(products);
        });
      }
    } catch (_) {
      bestSellersError = 'Could not load best sellers.';
    } finally {
      if (mounted) setState(() => isLoadingBestSellers = false);
    }
  }

  Future<void> _loadCategories() async {
    if (mounted) setState(() => isLoadingCategories = true);
    categoriesError = null;
    try {
      final all = _productCtrl.categories;
      if (mounted) {
        setState(() {
          categories.clear();
          categories.addAll(
            all.where((c) => c.parentId == null).take(4).toList(),
          );
        });
      }
    } catch (_) {
      categoriesError = 'Could not load categories.';
    } finally {
      if (mounted) setState(() => isLoadingCategories = false);
    }
  }

  Future<void> _loadWishlist() async {
    final userId = _auth.user?.id;
    if (userId == null) return;
    try {
      await _productCtrl.loadWishlist(userId);
      if (mounted) {
        setState(() {
          wishlistedIds.clear();
          wishlistedIds.addAll(
            _productCtrl.wishlistItems.map((w) => w.productId).toSet(),
          );
        });
      }
    } catch (_) {}
  }

  Future<void> _loadOffers() async {
    if (mounted) setState(() => isLoadingOffers = true);
    offersError = null;
    try {
      final result = await _productCtrl.fetchActiveOffers(limit: 5);
      if (mounted) {
        setState(() {
          offers.clear();
          offers.addAll(result);
        });
      }
    } catch (_) {
      offersError = 'Could not load offers.';
    } finally {
      if (mounted) setState(() => isLoadingOffers = false);
    }
  }

  Future<void> toggleWishlist(int productId) async {
    final userId = _auth.user?.id;
    if (userId == null) {
      Get.toNamed(AppRoutes.login);
      return;
    }
    final wasWishlisted = wishlistedIds.contains(productId);
    setState(() {
      if (wasWishlisted) {
        wishlistedIds.remove(productId);
      } else {
        wishlistedIds.add(productId);
      }
    });
    try {
      if (wasWishlisted) {
        await _productCtrl.removeFromWishlist(userId, productId);
      } else {
        await _productCtrl.addToWishlist(userId, productId);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          if (wasWishlisted) {
            wishlistedIds.add(productId);
          } else {
            wishlistedIds.remove(productId);
          }
        });
      }
      Get.snackbar(
        'Oops',
        'Could not update wishlist. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.marcatNavy,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    }
  }

  bool isWishlisted(int productId) => wishlistedIds.contains(productId);

  @override
  Widget build(BuildContext context) {
    return CustomerScaffold(
      page: 'home',
      body: Column(
        children: [
          HomeHero(
            categories: categories,
            offers: offers,
            isLoadingOffers: isLoadingOffers,
          ),
          const SizedBox(height: 72),
          CategoryGrid(
            categories: categories,
            isLoading: isLoadingCategories,
            error: categoriesError,
            onRefresh: _loadAll,
          ),
          const SizedBox(height: 80),
          NewArrivals(
            products: newArrivals,
            isLoading: isLoadingArrivals,
            error: arrivalsError,
            onRefresh: _loadAll,
            isWishlisted: isWishlisted,
            onToggleWishlist: toggleWishlist,
          ),
          const SizedBox(height: 80),
          const EditorialBanner(),
          const SizedBox(height: 80),
          const BrandValues(),
          const SizedBox(height: 80),
          BestSellers(
            products: bestSellers,
            isLoading: isLoadingBestSellers,
            error: bestSellersError,
            onRefresh: _loadAll,
            isWishlisted: isWishlisted,
            onToggleWishlist: toggleWishlist,
          ),
          const SizedBox(height: 80),
          const Testimonials(),
        ],
      ),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  SECTION 1 â€” HomeHero  (DB-driven offer slides + DB-driven quick strip)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class _HeroSlide {
  final String eyebrow, headline, subline, ctaLabel, ctaRoute;
  const _HeroSlide({
    required this.eyebrow,
    required this.headline,
    required this.subline,
    required this.ctaLabel,
    required this.ctaRoute,
  });
}

/// Converts an [OfferModel] into a hero slide with auto-generated copy.
_HeroSlide _offerToSlide(OfferModel offer) {
  // Eyebrow
  final eyebrow =
      offer.discountType == 'percentage' ? 'SPECIAL OFFER' : 'LIMITED TIME';

  // Headline â€” use description if available, otherwise format the code
  final headline = offer.description != null && offer.description!.isNotEmpty
      ? offer.description!
      : offer.code.replaceAll('_', ' ');

  // Subline â€” discount details
  final discountStr = offer.discountType == 'percentage'
      ? '${offer.discountValue.toStringAsFixed(0)}% OFF'
      : 'JOD ${offer.discountValue.toStringAsFixed(2)} OFF';
  final minOrder = offer.minOrderTotal > 0
      ? '\nOn orders over JOD ${offer.minOrderTotal.toStringAsFixed(0)}'
      : '';
  final expiry = offer.expiresAt != null
      ? '\nExpires ${offer.expiresAt!.day}/${offer.expiresAt!.month}/${offer.expiresAt!.year}'
      : '';
  final subline = '$discountStr Â· Use code: ${offer.code}$minOrder$expiry';

  return _HeroSlide(
    eyebrow: eyebrow,
    headline: headline,
    subline: subline,
    ctaLabel: 'Shop Now',
    ctaRoute: AppRoutes.shop,
  );
}

/// Fallback slide when no offers are available in the DB.
const _kFallbackSlide = _HeroSlide(
  eyebrow: 'Welcome',
  headline: 'Discover\nYour Style',
  subline: 'Curated fashion for\nevery occasion.',
  ctaLabel: 'Shop Now',
  ctaRoute: AppRoutes.shop,
);

class HomeHero extends StatefulWidget {
  final List<CategoryModel> categories;
  final List<OfferModel> offers;
  final bool isLoadingOffers;

  const HomeHero({
    super.key,
    required this.categories,
    required this.offers,
    required this.isLoadingOffers,
  });

  @override
  State<HomeHero> createState() => _HomeHeroState();
}

class _HomeHeroState extends State<HomeHero> with TickerProviderStateMixin {
  int _current = 0;
  late PageController _pageCtrl;
  Timer? _timer;

  late AnimationController _textCtrl;
  late AnimationController _progressCtrl;
  late Animation<double> _eyebrowAnim, _headlineAnim, _sublineAnim, _ctaAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _progressCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 6));

    _eyebrowAnim = _interval(0.0, 0.4);
    _headlineAnim = _interval(0.2, 0.7);
    _sublineAnim = _interval(0.4, 0.85);
    _ctaAnim = _interval(0.6, 1.0);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));

    _startSlide();
  }

  Animation<double> _interval(double begin, double end) => CurvedAnimation(
        parent: _textCtrl,
        curve: Interval(
          begin,
          end,
          curve: Curves.easeOut,
        ),
      );

  void _startSlide() {
    _textCtrl.forward(from: 0);
    _progressCtrl.forward(from: 0);
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 6), _next);
  }

  void _goto(int i) {
    _timer?.cancel();
    _textCtrl.reset();
    _pageCtrl.animateToPage(i,
        duration: const Duration(milliseconds: 700), curve: Curves.easeInOut);
    setState(() => _current = i);
    _startSlide();
  }

  void _next() {
    final count = _slideCount;
    if (count <= 1) return;
    _goto((_current + 1) % count);
  }

  int get _slideCount {
    final offerLen = widget.offers.length;
    return offerLen > 0 ? offerLen : 1; // at least 1 for fallback
  }

  List<_HeroSlide> get _slides {
    if (widget.offers.isEmpty) return [_kFallbackSlide];
    return widget.offers.map(_offerToSlide).toList();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageCtrl.dispose();
    _textCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sz = MediaQuery.sizeOf(context);
    final isDesktop = sz.width > 900;

    final slides = _slides;
    final slideCount = slides.length;

    return Column(
      children: [
        SizedBox(
          height: sz.height,
          child: Stack(children: [
            // Slide backgrounds
            PageView.builder(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: slideCount,
              itemBuilder: (_, i) => DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: const [0.0, 0.40, 0.75, 1.0],
                    colors: const [
                      Color(0x001A1A2E),
                      Color(0x881A1A2E),
                      Color(0xCC0D0D1A),
                      Color(0xEE0D0D1A),
                    ],
                  ),
                ),
              ),
            ),

            // Animated text overlay
            SlideTransition(
              position: _slideAnim,
              child: _HeroText(
                slide: slides[_current.clamp(0, slideCount - 1)],
                isDesktop: isDesktop,
                e: _eyebrowAnim,
                h: _headlineAnim,
                s: _sublineAnim,
                c: _ctaAnim,
              ),
            ),

            // Top progress bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _progressCtrl,
                builder: (_, __) => LinearProgressIndicator(
                  value: _progressCtrl.value,
                  minHeight: 2,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.marcatGoldVibrant),
                ),
              ),
            ),

            // Slide dots
            if (slideCount > 1)
              Positioned(
                bottom: isDesktop ? 40 : 24,
                right: isDesktop ? 60 : 24,
                child: Row(
                  children: List.generate(
                    slideCount,
                    (i) => GestureDetector(
                      onTap: () => _goto(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _current ? 24 : 8,
                        height: 3,
                        decoration: BoxDecoration(
                          color: i == _current
                              ? AppColors.marcatGoldVibrant
                              : Colors.white.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Desktop prev/next arrows
            if (isDesktop && slideCount > 1) ...[
              _Arrow(
                  left: true,
                  onTap: () => _goto((_current - 1 + slideCount) % slideCount)),
              _Arrow(left: false, onTap: _next),
            ],

            // Scroll hint
            if (isDesktop)
              const Positioned(
                  bottom: 28,
                  left: 0,
                  right: 0,
                  child: Center(child: _ScrollHint())),
          ]),
        ),

        // Quick-category strip â€” live DB categories, graceful loading state
        _QuickStrip(
          isDesktop: isDesktop,
          categories: widget.categories,
        ),
      ],
    );
  }
}

// â”€â”€ Hero sub-widgets â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _HeroText extends StatelessWidget {
  final _HeroSlide slide;
  final bool isDesktop;
  final Animation<double> e, h, s, c;

  const _HeroText({
    required this.slide,
    required this.isDesktop,
    required this.e,
    required this.h,
    required this.s,
    required this.c,
  });

  @override
  Widget build(BuildContext context) => Align(
        alignment: isDesktop ? Alignment.centerLeft : Alignment.bottomLeft,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isDesktop ? 80 : 28,
            0,
            isDesktop ? 0 : 28,
            isDesktop ? 80 : 60,
          ),
          child: SizedBox(
            width: isDesktop
                ? MediaQuery.sizeOf(context).width * 0.42
                : double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeTransition(
                  opacity: e,
                  child: Row(children: [
                    Container(
                        width: 28,
                        height: 2,
                        color: AppColors.marcatGoldVibrant,
                        margin: const EdgeInsets.only(right: 10)),
                    Text(slide.eyebrow.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.marcatGoldVibrant,
                          letterSpacing: 2.5,
                        )),
                  ]),
                ),
                const SizedBox(height: 14),
                FadeTransition(
                  opacity: h,
                  child: Text(
                    slide.headline,
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: isDesktop ? 72 : 48,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.05,
                      letterSpacing: isDesktop ? 1.5 : 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                FadeTransition(
                  opacity: s,
                  child: Text(
                    slide.subline,
                    style: TextStyle(
                      fontSize: isDesktop ? 18 : 15,
                      color: Colors.white.withOpacity(0.75),
                      height: 1.6,
                    ),
                  ),
                ),
                SizedBox(height: isDesktop ? 36 : 28),
                FadeTransition(
                  opacity: c,
                  child: _HeroBtn(
                    label: slide.ctaLabel,
                    onTap: () => Get.toNamed(slide.ctaRoute),
                    large: isDesktop,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _HeroBtn extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool large;
  const _HeroBtn({required this.label, required this.onTap, this.large = true});

  @override
  State<_HeroBtn> createState() => _HeroBtnState();
}

class _HeroBtnState extends State<_HeroBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<Color?> _bg, _fg;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _bg = ColorTween(begin: Colors.transparent, end: Colors.white).animate(_c);
    _fg =
        ColorTween(begin: Colors.white, end: AppColors.marcatNavy).animate(_c);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => _c.forward(),
        onExit: (_) => _c.reverse(),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, __) => Container(
              height: widget.large ? 54 : 46,
              padding: EdgeInsets.symmetric(horizontal: widget.large ? 36 : 28),
              decoration: BoxDecoration(
                color: _bg.value,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Center(
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    widget.label.toUpperCase(),
                    style: TextStyle(
                      fontSize: widget.large ? 13 : 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.5,
                      color: _fg.value,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.arrow_forward_rounded, size: 16, color: _fg.value),
                ]),
              ),
            ),
          ),
        ),
      );
}

class _Arrow extends StatefulWidget {
  final bool left;
  final VoidCallback onTap;
  const _Arrow({required this.left, required this.onTap});

  @override
  State<_Arrow> createState() => _ArrowState();
}

class _ArrowState extends State<_Arrow> {
  bool _h = false;

  @override
  Widget build(BuildContext context) => Positioned(
        left: widget.left ? 24 : null,
        right: widget.left ? null : 24,
        top: 0,
        bottom: 0,
        child: Center(
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _h = true),
            onExit: (_) => setState(() => _h = false),
            child: GestureDetector(
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _h
                      ? Colors.white.withOpacity(0.18)
                      : Colors.white.withOpacity(0.08),
                  border: Border.all(color: Colors.white.withOpacity(0.25)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  widget.left
                      ? Icons.arrow_back_rounded
                      : Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      );
}

class _ScrollHint extends StatefulWidget {
  const _ScrollHint();

  @override
  State<_ScrollHint> createState() => _ScrollHintState();
}

class _ScrollHintState extends State<_ScrollHint>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _b;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _b = Tween<double>(begin: 0, end: 8)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _b,
        builder: (_, child) =>
            Transform.translate(offset: Offset(0, _b.value), child: child),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('SCROLL',
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.45),
                  letterSpacing: 2)),
          const SizedBox(height: 4),
          Icon(Icons.keyboard_arrow_down_rounded,
              size: 18, color: Colors.white.withOpacity(0.45)),
        ]),
      );
}

// â”€â”€ Quick strip â€” DB-driven â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _QuickStrip extends StatelessWidget {
  final bool isDesktop;
  final List<CategoryModel> categories;

  const _QuickStrip({required this.isDesktop, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Container(
        color: Colors.white,
        height: isDesktop ? 68 : 52,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.marcatNavy.withOpacity(0.25)),
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: isDesktop
          ? IntrinsicHeight(
              child: Row(
                children: categories.asMap().entries.map((entry) {
                  final isLast = entry.key == categories.length - 1;
                  return Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: isLast
                              ? BorderSide.none
                              : const BorderSide(color: Color(0xFFEEE8E0)),
                        ),
                      ),
                      child: _QuickTile(category: entry.value),
                    ),
                  );
                }).toList(),
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: categories
                    .map((cat) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _QuickChip(category: cat),
                        ))
                    .toList(),
              ),
            ),
    );
  }
}

class _QuickTile extends StatefulWidget {
  final CategoryModel category;
  const _QuickTile({required this.category});

  @override
  State<_QuickTile> createState() => _QuickTileState();
}

class _QuickTileState extends State<_QuickTile> {
  bool _h = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _h = true),
        onExit: (_) => setState(() => _h = false),
        child: GestureDetector(
          onTap: () => Get.toNamed('/app/category/${widget.category.id}'),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            color: _h ? AppColors.marcatCream : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                widget.category.name,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color:
                        _h ? AppColors.marcatGoldVibrant : AppColors.marcatNavy,
                    letterSpacing: 0.5),
              ),
              const SizedBox(width: 6),
              AnimatedOpacity(
                opacity: _h ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.arrow_forward_rounded,
                    size: 14, color: AppColors.marcatGoldVibrant),
              ),
            ]),
          ),
        ),
      );
}

class _QuickChip extends StatelessWidget {
  final CategoryModel category;
  const _QuickChip({required this.category});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => Get.toNamed('/app/category/${category.id}'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.marcatCream,
            border: const Border.fromBorderSide(
                BorderSide(color: Color(0xFFEEE8E0))),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            category.name,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.marcatNavy,
                letterSpacing: 0.3),
          ),
        ),
      );
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  SECTION 2 â€” CategoryGrid  (live DB categories)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class CategoryGrid extends StatelessWidget {
  final List<CategoryModel> categories;
  final bool isLoading;
  final String? error;
  final VoidCallback onRefresh;

  const CategoryGrid({
    super.key,
    required this.categories,
    required this.isLoading,
    this.error,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 768;
    return FB5Container(
      child: Column(
        children: [
          const _SectionHeader(
            eyebrow: 'Collections',
            title: 'Shop by Category',
            subtitle: 'Find exactly what you\'re looking for.',
          ),
          const SizedBox(height: 40),
          if (isLoading) ...{_CategoryGridSkeleton(isDesktop: isDesktop)},
          if (error != null) ...{
            _ErrorRetry(message: error!, onRetry: onRefresh)
          },
          if (categories.isEmpty && !isLoading && error == null) ...{
            const _EmptyState(message: 'No categories found.')
          },
          if (categories.isNotEmpty) ...{
            isDesktop ? _desktopGrid(categories) : _mobileGrid(categories)
          }
        ],
      ),
    );
  }

  Widget _desktopGrid(List<CategoryModel> cats) {
    final shown = cats.take(4).toList();
    return SizedBox(
      height: 480,
      child: Row(children: [
        Expanded(flex: 5, child: _CategoryCard(category: shown[0], tall: true)),
        if (shown.length > 1) ...[
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Column(children: [
              for (int i = 1; i < shown.length; i++) ...[
                if (i > 1) const SizedBox(height: 12),
                Expanded(child: _CategoryCard(category: shown[i])),
              ],
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _mobileGrid(List<CategoryModel> cats) {
    final shown = cats.take(4).toList();
    return Column(children: [
      SizedBox(
          height: 260, child: _CategoryCard(category: shown[0], tall: true)),
      if (shown.length > 1) ...[
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: SizedBox(
                  height: 160, child: _CategoryCard(category: shown[1]))),
          if (shown.length > 2) ...[
            const SizedBox(width: 12),
            Expanded(
                child: SizedBox(
                    height: 160, child: _CategoryCard(category: shown[2]))),
          ],
        ]),
        if (shown.length > 3) ...[
          const SizedBox(height: 12),
          SizedBox(height: 160, child: _CategoryCard(category: shown[3])),
        ],
      ],
    ]);
  }
}

class _CategoryCard extends StatefulWidget {
  final CategoryModel category;
  final bool tall;
  const _CategoryCard({required this.category, this.tall = false});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _h = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _h = true),
        onExit: (_) => setState(() => _h = false),
        child: GestureDetector(
          onTap: () => Get.toNamed('/app/category/${widget.category.id}'),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(fit: StackFit.expand, children: [
              // Image from DB, graceful fallback when null
              widget.category.imageUrl != null
                  ? AnimatedScale(
                      scale: _h ? 1.06 : 1.0,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      child: CachedNetworkImage(
                        imageUrl: widget.category.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                            color: AppColors.marcatNavy.withOpacity(0.5)),
                        errorWidget: (_, __, ___) =>
                            _CategoryFallback(name: widget.category.name),
                      ),
                    )
                  : _CategoryFallback(name: widget.category.name),

              // Gradient overlay
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      _h
                          ? AppColors.marcatNavy.withOpacity(0.75)
                          : AppColors.marcatNavy.withOpacity(0.45),
                    ],
                  ),
                ),
              ),

              // Label + hover CTA
              Positioned(
                left: 20,
                bottom: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        widget.category.name,
                        style: TextStyle(
                          fontFamily: 'Playfair Display',
                          fontSize: widget.tall ? 32 : 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: _h ? 1 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: AppColors.marcatGoldVibrant,
                            borderRadius: BorderRadius.circular(2)),
                        child: const Text('SHOP',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.marcatNavy,
                                letterSpacing: 1.5)),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      );
}

/// Gradient placeholder for categories with no imageUrl in the DB.
class _CategoryFallback extends StatelessWidget {
  final String name;
  const _CategoryFallback({required this.name});

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF2E2E4E)],
          ),
        ),
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: 64,
                fontWeight: FontWeight.w700,
                color: AppColors.marcatGoldVibrant),
          ),
        ),
      );
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  SECTION 3 â€” NewArrivals  (live DB products)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class NewArrivals extends StatelessWidget {
  final List<ProductModel> products;
  final bool isLoading;
  final String? error;
  final VoidCallback onRefresh;
  final bool Function(int) isWishlisted;
  final Function(int) onToggleWishlist;

  const NewArrivals({
    super.key,
    required this.products,
    required this.isLoading,
    this.error,
    required this.onRefresh,
    required this.isWishlisted,
    required this.onToggleWishlist,
  });

  @override
  Widget build(BuildContext context) => Column(
        children: [
          FB5Container(
            child: _SectionHeader(
              eyebrow: 'Just In',
              title: 'New Arrivals',
              subtitle: 'Fresh styles, added weekly.',
              action: _TextAction(
                label: 'View All',
                onTap: () => Get.toNamed(AppRoutes.shopNew),
              ),
            ),
          ),
          const SizedBox(height: 36),
          Builder(builder: (context) {
            if (isLoading) {
              return _HorizontalProductSkeleton();
            }
            if (error != null) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _ErrorRetry(message: error!, onRetry: onRefresh),
              );
            }
            if (products.isEmpty) {
              return const _EmptyState(message: 'No new arrivals yet.');
            }
            return SizedBox(
              height: 380,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                clipBehavior: Clip.none,
                itemCount: products.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 240,
                    child: _ProductCard(
                      product: products[i],
                      isWishlisted: isWishlisted(products[i].id),
                      onToggleWishlist: () =>
                          onToggleWishlist(products[i].id),
                      isNew: true,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      );
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  SECTION 4 â€” EditorialBanner  (static marketing content)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class EditorialBanner extends StatelessWidget {
  const EditorialBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 768;
    return Container(
      color: AppColors.marcatNavy,
      child: isDesktop ? _desktopLayout() : _mobileLayout(),
    );
  }

  Widget _desktopLayout() => SizedBox(
        height: 520,
        child: Row(children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl:
                  'https://images.unsplash.com/photo-1554412933-514a83d2f3c8?w=900&q=80',
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: _content(large: true),
              ),
            ),
          ),
        ]),
      );

  Widget _mobileLayout() => Column(children: [
        SizedBox(
          height: 280,
          width: double.infinity,
          child: CachedNetworkImage(
            imageUrl:
                'https://images.unsplash.com/photo-1554412933-514a83d2f3c8?w=900&q=80',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _content(large: false)),
        ),
      ]);

  List<Widget> _content({required bool large}) => [
        Row(children: [
          Container(
              width: 28,
              height: 2,
              color: AppColors.marcatGoldVibrant,
              margin: const EdgeInsets.only(right: 10)),
          const Text('THE EDIT',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.marcatGoldVibrant,
                  letterSpacing: 2.5)),
        ]),
        const SizedBox(height: 16),
        Text(
          'Crafted for the\nConscious Woman',
          style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: large ? 44 : 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.1),
        ),
        const SizedBox(height: 20),
        Text(
          'Sustainably sourced fabrics, timeless silhouettes, '
          'and pieces that outlast every trend cycle.',
          style: TextStyle(
              fontSize: large ? 16 : 14,
              color: Colors.white.withOpacity(0.65),
              height: 1.7),
        ),
        const SizedBox(height: 32),
        _OutlineBtn(
            label: 'Discover The Edit',
            onTap: () => Get.toNamed(AppRoutes.shopWomen)),
      ];
}

class _OutlineBtn extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlineBtn({required this.label, required this.onTap});

  @override
  State<_OutlineBtn> createState() => _OutlineBtnState();
}

class _OutlineBtnState extends State<_OutlineBtn> {
  bool _h = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _h = true),
        onExit: (_) => setState(() => _h = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            decoration: BoxDecoration(
              color: _h ? AppColors.marcatGoldVibrant : Colors.transparent,
              border: Border.all(
                  color: _h
                      ? AppColors.marcatGoldVibrant
                      : Colors.white.withOpacity(0.5),
                  width: 1.5),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(
                widget.label.toUpperCase(),
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: _h ? AppColors.marcatNavy : Colors.white),
              ),
              const SizedBox(width: 10),
              Icon(Icons.arrow_forward_rounded,
                  size: 14, color: _h ? AppColors.marcatNavy : Colors.white),
            ]),
          ),
        ),
      );
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  SECTION 5 â€” BrandValues  (static)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class _ValueItem {
  final IconData icon;
  final String title, desc;
  const _ValueItem(this.icon, this.title, this.desc);
}

const _kValues = [
  _ValueItem(Icons.local_shipping_outlined, 'Free Shipping',
      'On all orders above JOD 50'),
  _ValueItem(
      Icons.replay_outlined, 'Easy Returns', '30-day hassle-free returns'),
  _ValueItem(Icons.verified_outlined, 'Authentic Quality',
      'Sourced from premium suppliers'),
  _ValueItem(Icons.support_agent_outlined, '24/7 Support',
      'We\'re always here to help'),
];

class BrandValues extends StatelessWidget {
  const BrandValues({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 600;
    return Container(
      color: AppColors.marcatCream,
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      child: FB5Container(
        child: isDesktop
            ? Row(
                children: _kValues
                    .map((v) => Expanded(child: _ValueTile(v)))
                    .toList())
            : Wrap(
                spacing: 0,
                runSpacing: 24,
                children: _kValues
                    .map((v) => SizedBox(
                          width: MediaQuery.sizeOf(context).width / 2 - 32,
                          child: _ValueTile(v),
                        ))
                    .toList(),
              ),
      ),
    );
  }
}

class _ValueTile extends StatelessWidget {
  final _ValueItem v;
  const _ValueTile(this.v);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              border: Border.all(
                  color: AppColors.marcatGoldVibrant.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(v.icon, size: 22, color: AppColors.marcatNavy),
          ),
          const SizedBox(height: 14),
          Text(v.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.marcatNavy,
                  letterSpacing: 0.2)),
          const SizedBox(height: 5),
          Text(v.desc,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12, color: AppColors.marcatSlate, height: 1.5)),
        ]),
      );
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  SECTION 6 â€” BestSellers  (live DB products)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class BestSellers extends StatelessWidget {
  final List<ProductModel> products;
  final bool isLoading;
  final String? error;
  final VoidCallback onRefresh;
  final bool Function(int) isWishlisted;
  final Function(int) onToggleWishlist;

  const BestSellers({
    super.key,
    required this.products,
    required this.isLoading,
    this.error,
    required this.onRefresh,
    required this.isWishlisted,
    required this.onToggleWishlist,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 600;
    final cols = isDesktop ? 4 : 2;

    return FB5Container(
      child: Column(
        children: [
          _SectionHeader(
            eyebrow: 'Fan Favourites',
            title: 'Best Sellers',
            subtitle: 'The pieces our customers keep coming back for.',
            action: _TextAction(
              label: 'Shop All',
              onTap: () => Get.toNamed(AppRoutes.shop),
            ),
          ),
          const SizedBox(height: 40),
          Builder(builder: (context) {
            if (isLoading) {
              return _GridProductSkeleton(cols: cols);
            }
            if (error != null) {
              return _ErrorRetry(message: error!, onRetry: onRefresh);
            }
            if (products.isEmpty) {
              return const _EmptyState(message: 'No best sellers yet.');
            }
            return GridView.builder(
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
            );
          }),
        ],
      ),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  Shared product card  (NewArrivals + BestSellers)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class _ProductCard extends StatefulWidget {
  final ProductModel product;
  final bool isWishlisted;
  final VoidCallback onToggleWishlist;
  final bool isNew;

  const _ProductCard({
    required this.product,
    required this.isWishlisted,
    required this.onToggleWishlist,
    this.isNew = false,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _hovered = false;

  void _openProduct() => Get.toNamed('/app/product/${widget.product.id}');

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
              // â”€â”€ Image container â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(fit: StackFit.expand, children: [
                    // Product image with zoom on hover
                    AnimatedScale(
                      scale: _hovered ? 1.06 : 1.0,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      child: widget.product.primaryImageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: widget.product.primaryImageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, __) =>
                                  Container(color: AppColors.marcatCream),
                              errorWidget: (_, __, ___) =>
                                  _ProductImageFallback(
                                      name: widget.product.name),
                            )
                          : _ProductImageFallback(name: widget.product.name),
                    ),

                    // NEW badge (for new arrivals section)
                    if (widget.isNew)
                      Positioned(
                        top: 12,
                        left: 12,
                        child:
                            _Badge(label: 'NEW', color: AppColors.marcatNavy),
                      ),

                    // Wishlist toggle
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: widget.onToggleWishlist,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: widget.isWishlisted
                                ? AppColors.marcatNavy
                                : Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.isWishlisted
                                ? Icons.favorite_rounded
                                : Icons.favorite_outline_rounded,
                            size: 16,
                            color: widget.isWishlisted
                                ? Colors.white
                                : AppColors.marcatNavy,
                          ),
                        ),
                      ),
                    ),

                    // Quick View overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: AnimatedOpacity(
                        opacity: _hovered ? 1 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: GestureDetector(
                          onTap: _openProduct,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            color: AppColors.marcatNavy,
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
                  ]),
                ),
              ),

              const SizedBox(height: 12),

              // â”€â”€ Product metadata â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              if (widget.product.categoryId != null)
                Text(
                  'Category ${widget.product.categoryId}',
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.marcatSlate,
                      letterSpacing: 1.5),
                ),
              const SizedBox(height: 4),
              Text(
                widget.product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.marcatNavy,
                    height: 1.3),
              ),
              const SizedBox(height: 6),
              Text(
                'JOD ${widget.product.basePrice.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.marcatNavy),
              ),
            ],
          ),
        ),
      );
}

class _ProductImageFallback extends StatelessWidget {
  final String name;
  const _ProductImageFallback({required this.name});

  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.marcatCream,
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.image_outlined,
                size: 32, color: AppColors.marcatSlate.withOpacity(0.35)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11,
                    color: AppColors.marcatSlate.withOpacity(0.5),
                    fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),
        ),
      );
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        color: color,
        child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5)),
      );
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  SECTION 7 â€” Testimonials  (static â€” no reviews table in scope)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class _Review {
  final String name, text, location;
  final int rating;
  const _Review({
    required this.name,
    required this.text,
    required this.location,
    required this.rating,
  });
}

const _kReviews = [
  _Review(
    name: 'Sara M.',
    location: 'Amman, JO',
    rating: 5,
    text: '"The cashmere turtleneck is insanely soft. '
        'I\'ve washed it five times and it still looks brand new. '
        'Worth every dinar."',
  ),
  _Review(
    name: 'Khaled A.',
    location: 'Dubai, UAE',
    rating: 5,
    text: '"Finally a brand that gets menswear right. '
        'The tailored overcoat fits perfectly off the rack. '
        'Shipping was faster than expected too."',
  ),
  _Review(
    name: 'Lina R.',
    location: 'Beirut, LB',
    rating: 5,
    text: '"Ordered the wide-leg trousers and they\'re exactly as '
        'pictured. Elegant, comfortable, and the quality rivals '
        'brands twice the price."',
  ),
];

class Testimonials extends StatefulWidget {
  const Testimonials({super.key});

  @override
  State<Testimonials> createState() => _TestimonialsState();
}

class _TestimonialsState extends State<Testimonials> {
  int _current = 0;
  late PageController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.marcatNavy,
        padding: const EdgeInsets.symmetric(vertical: 72),
        child: Column(children: [
          FB5Container(
            child: _SectionHeader(
              eyebrow: 'Reviews',
              title: 'What Our Customers Say',
              dark: true,
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            height: 220,
            child: PageView.builder(
              controller: _ctrl,
              itemCount: _kReviews.length,
              onPageChanged: (i) => setState(() => _current = i),
              itemBuilder: (_, i) => AnimatedOpacity(
                opacity: i == _current ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 300),
                child: _ReviewCard(review: _kReviews[i]),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _kReviews.length,
              (i) => GestureDetector(
                onTap: () {
                  _ctrl.animateToPage(i,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut);
                  setState(() => _current = i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _current ? 24 : 8,
                  height: 3,
                  decoration: BoxDecoration(
                    color: i == _current
                        ? AppColors.marcatGoldVibrant
                        : Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ]),
      );
}

class _ReviewCard extends StatelessWidget {
  final _Review review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                  children: List.generate(
                review.rating,
                (_) => const Icon(Icons.star_rounded,
                    size: 16, color: AppColors.marcatGoldVibrant),
              )),
              const SizedBox(height: 16),
              Expanded(
                child: Text(
                  review.text,
                  style: TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: Colors.white.withOpacity(0.85),
                    height: 1.6,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.marcatGoldVibrant.withOpacity(0.2),
                    border: Border.all(
                        color: AppColors.marcatGoldVibrant.withOpacity(0.4)),
                  ),
                  child: Center(
                    child: Text(review.name[0],
                        style: const TextStyle(
                            color: AppColors.marcatGoldVibrant,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.name,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    Text(review.location,
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.45))),
                  ],
                ),
              ]),
            ],
          ),
        ),
      );
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  Loading skeletons
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class _Shimmer extends StatefulWidget {
  final double width, height;
  const _Shimmer({required this.width, required this.height});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
    _a = Tween<double>(begin: 0.06, end: 0.14)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _a,
        builder: (_, __) => Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(_a.value),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );
}

class _HorizontalProductSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 380,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: 5,
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SizedBox(
              width: 240,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: _Shimmer(width: 240, height: double.infinity)),
                  const SizedBox(height: 12),
                  _Shimmer(width: 60, height: 10),
                  const SizedBox(height: 6),
                  _Shimmer(width: 180, height: 14),
                  const SizedBox(height: 6),
                  _Shimmer(width: 80, height: 14),
                ],
              ),
            ),
          ),
        ),
      );
}

class _GridProductSkeleton extends StatelessWidget {
  final int cols;
  const _GridProductSkeleton({required this.cols});

  @override
  Widget build(BuildContext context) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          crossAxisSpacing: 16,
          mainAxisSpacing: 20,
          childAspectRatio: 0.62,
        ),
        itemCount: cols * 2,
        itemBuilder: (_, __) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child:
                    _Shimmer(width: double.infinity, height: double.infinity)),
            const SizedBox(height: 10),
            _Shimmer(width: 80, height: 10),
            const SizedBox(height: 6),
            _Shimmer(width: 140, height: 14),
            const SizedBox(height: 6),
            _Shimmer(width: 70, height: 14),
          ],
        ),
      );
}

class _CategoryGridSkeleton extends StatelessWidget {
  final bool isDesktop;
  const _CategoryGridSkeleton({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return SizedBox(
        height: 480,
        child: Row(children: [
          Expanded(
              flex: 5,
              child: _Shimmer(width: double.infinity, height: double.infinity)),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Column(children: [
              for (int i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                Expanded(
                    child: _Shimmer(
                        width: double.infinity, height: double.infinity)),
              ],
            ]),
          ),
        ]),
      );
    }
    return Column(children: [
      _Shimmer(width: double.infinity, height: 260),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _Shimmer(width: double.infinity, height: 160)),
        const SizedBox(width: 12),
        Expanded(child: _Shimmer(width: double.infinity, height: 160)),
      ]),
    ]);
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  Shared helpers
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class _ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.wifi_off_rounded,
              size: 36, color: AppColors.marcatSlate.withOpacity(0.4)),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.marcatSlate)),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Try Again'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.marcatNavy,
              textStyle:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ]),
      );
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Text(message,
            style: TextStyle(fontSize: 14, color: AppColors.marcatSlate)),
      );
}

class _SectionHeader extends StatelessWidget {
  final String eyebrow, title;
  final String? subtitle;
  final Widget? action;
  final bool dark;

  const _SectionHeader({
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.action,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                      width: 24,
                      height: 2,
                      color: AppColors.marcatGoldVibrant,
                      margin: const EdgeInsets.only(right: 10)),
                  Text(
                    eyebrow.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.marcatGoldVibrant,
                        letterSpacing: 2),
                  ),
                ]),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: dark ? Colors.white : AppColors.marcatNavy,
                    height: 1.1,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 14,
                      color: dark
                          ? Colors.white.withOpacity(0.55)
                          : AppColors.marcatSlate,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 16),
            action!,
          ],
        ],
      );
}

class _TextAction extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _TextAction({required this.label, required this.onTap});

  @override
  State<_TextAction> createState() => _TextActionState();
}

class _TextActionState extends State<_TextAction> {
  bool _h = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _h = true),
        onExit: (_) => setState(() => _h = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _h ? AppColors.marcatGoldVibrant : AppColors.marcatNavy,
                letterSpacing: 0.5,
              ),
              child: Text(widget.label),
            ),
            const SizedBox(width: 6),
            Icon(Icons.arrow_forward_rounded,
                size: 14,
                color: _h ? AppColors.marcatGoldVibrant : AppColors.marcatNavy),
          ]),
        ),
      );
}
