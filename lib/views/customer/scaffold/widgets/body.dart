// lib/views/customer/scaffold/widgets/body.dart

import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';

import 'package:marcat/core/router/app_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ClientBody
// ─────────────────────────────────────────────────────────────────────────────

/// Body content wrapper for customer-facing pages.
/// Renders an optional hero banner, the page content, and the site footer.
class ClientBody extends StatelessWidget {
  final String pageName;
  final String? pageImage;
  final Widget body;
  final ScrollController scrollController;

  const ClientBody({
    super.key,
    required this.pageName,
    this.pageImage,
    required this.body,
    required this.scrollController,
  });

  bool get _showBanner => pageImage != null && pageImage!.isNotEmpty;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            // ── Hero / page banner ─────────────────────────────────────
            if (_showBanner)
              _PageBanner(pageName: pageName, imageUrl: pageImage!),

            // ── Page content ───────────────────────────────────────────
            body,

            // ── Site footer ────────────────────────────────────────────
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
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFF1A1A2E)),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.55),
                  ],
                ),
              ),
            ),
            Center(
              child: Text(
                pageName.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'PlayfairDisplay', // ✅ correct font name
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
  Widget build(BuildContext context) => Container(
        color: const Color(0xFF0D1117),
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: FB5Container(
          child: FB5Row(
            children: [
              // Brand column
              FB5Col(
                classNames: 'col-lg-3 col-md-6 col-sm-12',
                child: _FooterColumn(
                  heading: 'MARCAT',
                  headingIsLogo: true,
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

              FB5Col(
                classNames: 'col-lg-3 col-md-6 col-sm-12',
                child: _FooterColumn(
                  heading: 'Shop',
                  links: [
                    _FooterLink(
                      label: 'All Products',
                      onTap: () => Get.toNamed(AppRoutes.shop),
                    ),
                    _FooterLink(
                      label: 'Men',
                      onTap: () => Get.toNamed(AppRoutes.shopMen),
                    ),
                    _FooterLink(
                      label: 'Kids',
                      onTap: () => Get.toNamed(AppRoutes.shopKids),
                    ),
                    _FooterLink(
                      label: 'Sale',
                      onTap: () => Get.toNamed(AppRoutes.shopSale),
                    ),
                    _FooterLink(
                      label: 'New Arrivals',
                      onTap: () => Get.toNamed(AppRoutes.shopNew),
                    ),
                  ],
                ),
              ),

              // Account links
              FB5Col(
                classNames: 'col-lg-3 col-md-6 col-sm-12',
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
                      label: 'Edit Profile',
                      onTap: () => Get.toNamed(AppRoutes.profile),
                    ),
                    _FooterLink(
                      label: 'Sign In',
                      onTap: () => Get.toNamed(AppRoutes.login),
                    ),
                  ],
                ),
              ),

              // Help links
              FB5Col(
                classNames: 'col-lg-3 col-md-6 col-sm-12',
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
                    _FooterLink(
                      label: 'Contact Us',
                      onTap: () => Get.toNamed(AppRoutes.contact),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

class _FooterColumn extends StatelessWidget {
  const _FooterColumn({
    required this.heading,
    required this.links,
    this.headingIsLogo = false,
  });

  final String heading;
  final List<_FooterLink> links;
  final bool headingIsLogo;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              heading,
              style: TextStyle(
                fontFamily: headingIsLogo ? 'PlayfairDisplay' : null,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: headingIsLogo ? 20 : 13,
                letterSpacing: headingIsLogo ? 3 : 1.5,
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
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      );
}
