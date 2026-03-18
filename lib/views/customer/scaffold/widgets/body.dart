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

/// Body content wrapper for customer-facing pages.
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
                    Colors.black.withOpacity(0.25),
                    Colors.black.withOpacity(0.55),
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
                    // ── Brand ──────────────────────────────────────────────
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

                    // ── Shop ───────────────────────────────────────────────
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

                    // ── Account ────────────────────────────────────────────
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

                    // ── Contact ────────────────────────────────────────────
                    FB5Col(
                      classNames: 'col-lg-3 col-md-6 col-12',
                      child: _FooterColumn(
                        heading: 'Contact',
                        links: [
                          _FooterLink(
                            label: '+962 79 156 8798',
                            onTap: null,
                          ),
                          _FooterLink(
                            label: 'hello@marcat.jo',
                            onTap: null,
                          ),
                          _FooterLink(
                            label: 'Abdali Blvd, Amman',
                            onTap: null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                const Divider(color: Colors.white12),
                const SizedBox(height: 20),
                const Text(
                  '© 2024 MARCAT. All rights reserved.',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 12,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _FooterColumn
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
            if (isLogo)
              Text(
                heading,
                style: const TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.marcatGold,
                  letterSpacing: 2,
                ),
              )
            else
              Text(
                heading.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white60,
                  letterSpacing: 2,
                ),
              ),
            const SizedBox(height: 16),
            ...links,
          ],
        ),
      );
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GestureDetector(
          onTap: onTap,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 14,
              color: onTap != null ? Colors.white70 : Colors.white38,
              height: 1.4,
            ),
          ),
        ),
      );
}
