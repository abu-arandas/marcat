// lib/views/customer/scaffold/widgets/body.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';

import 'package:marcat/core/constants/app_colors.dart';
import 'package:marcat/core/router/app_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ClientBody
// ─────────────────────────────────────────────────────────────────────────────

/// Body wrapper for customer-facing pages.
/// Renders an optional hero banner, the page content, and the site footer.
class ClientBody extends StatelessWidget {
  const ClientBody({
    super.key,
    required this.pageName,
    this.pageImage,
    required this.body,
    required this.scrollController,
  });

  final String pageName;
  final String? pageImage;
  final Widget body;
  final ScrollController scrollController;

  bool get _showBanner => pageImage != null && pageImage!.isNotEmpty;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            if (_showBanner)
              _PageBanner(pageName: pageName, imageUrl: pageImage!),
            body,
            const _SiteFooter(),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _PageBanner
// ─────────────────────────────────────────────────────────────────────────────

class _PageBanner extends StatelessWidget {
  const _PageBanner({required this.pageName, required this.imageUrl});

  final String pageName;
  final String imageUrl;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 220,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  const ColoredBox(color: AppColors.marcatNavy),
              errorWidget: (_, __, ___) =>
                  const ColoredBox(color: AppColors.marcatNavy),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    // withAlpha(64) ≈ 25 % opacity
                    Colors.black.withAlpha(64),
                    // withAlpha(140) ≈ 55 % opacity
                    Colors.black.withAlpha(140),
                  ],
                ),
              ),
            ),
            Center(
              child: Text(
                pageName.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4,
                ),
              ),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _SiteFooter
// ─────────────────────────────────────────────────────────────────────────────

class _SiteFooter extends StatelessWidget {
  const _SiteFooter();

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: AppColors.footerBg,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
          child: FB5Container(
            child: Column(
              children: [
                FB5Row(
                  children: [
                    // ── Brand column ──────────────────────────────────────
                    FB5Col(
                      classNames: 'col-lg-3 col-md-6 col-12',
                      child: _FooterColumn(
                        heading: 'MARCAT',
                        isLogo: true,
                        links: [
                          _FooterLink(
                            label: 'About Us',
                            onTap: () => Get.toNamed(AppRoutes.about),
                          ),
                          _FooterLink(
                            label: 'Contact',
                            onTap: () => Get.toNamed(AppRoutes.contact),
                          ),
                        ],
                      ),
                    ),

                    // ── Shop column ────────────────────────────────────────
                    FB5Col(
                      classNames: 'col-lg-3 col-md-6 col-12',
                      child: _FooterColumn(
                        heading: 'Shop',
                        links: [
                          _FooterLink(
                            label: 'All Products',
                            onTap: () => Get.toNamed(AppRoutes.shop),
                          ),
                          _FooterLink(
                            label: 'New Arrivals',
                            onTap: () => Get.toNamed(AppRoutes.shopNew),
                          ),
                          _FooterLink(
                            label: 'Sale',
                            onTap: () => Get.toNamed(AppRoutes.shopSale),
                          ),
                        ],
                      ),
                    ),

                    // ── Account column ─────────────────────────────────────
                    FB5Col(
                      classNames: 'col-lg-3 col-md-6 col-12',
                      child: _FooterColumn(
                        heading: 'Account',
                        links: [
                          _FooterLink(
                            label: 'My Orders',
                            onTap: () => Get.toNamed(AppRoutes.orders),
                          ),
                          _FooterLink(
                            label: 'Wishlist',
                            onTap: () => Get.toNamed(AppRoutes.wishlist),
                          ),
                          _FooterLink(
                            label: 'Profile',
                            onTap: () => Get.toNamed(AppRoutes.profile),
                          ),
                        ],
                      ),
                    ),

                    // ── Help column ────────────────────────────────────────
                    FB5Col(
                      classNames: 'col-lg-3 col-md-6 col-12',
                      child: _FooterColumn(
                        heading: 'Help',
                        links: [
                          _FooterLink(
                            label: 'Size Guide',
                            onTap: () => Get.toNamed(AppRoutes.sizeGuide),
                          ),
                          _FooterLink(
                            label: 'Returns & Exchanges',
                            onTap: () => Get.toNamed(AppRoutes.returns),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
                const Divider(color: Color(0xFF2C2C3E), height: 1),
                const SizedBox(height: 24),

                // ── Copyright ─────────────────────────────────────────────
                Text(
                  '© ${DateTime.now().year} MARCAT. All rights reserved.',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 12,
                    // withAlpha(102) ≈ 40 % opacity
                    color: Colors.white.withAlpha(102),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _FooterColumn & _FooterLink
// ─────────────────────────────────────────────────────────────────────────────

class _FooterColumn extends StatelessWidget {
  const _FooterColumn({
    required this.heading,
    required this.links,
    this.isLogo = false,
  });

  final String heading;
  final List<_FooterLink> links;
  final bool isLogo;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading
            isLogo
                ? Text(
                    heading,
                    style: const TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      color: AppColors.marcatGold,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3,
                    ),
                  )
                : Text(
                    heading.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                    ),
                  ),
            const SizedBox(height: 16),
            ...links,
          ],
        ),
      );
}

class _FooterLink extends StatefulWidget {
  const _FooterLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 160),
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                // withAlpha(153) ≈ 60 % opacity
                color: _hovered ? Colors.white : Colors.white.withAlpha(153),
              ),
              child: Text(widget.label),
            ),
          ),
        ),
      );
}
