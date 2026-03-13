// lib/views/customer/scaffold/widgets/body.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';

import '../../../../core/extensions/string_extensions.dart';
import 'package:marcat/core/router/app_router.dart';

// -----------------------------------------------------------------------------
//  Brand constants
// -----------------------------------------------------------------------------

const _kNavy = Color(0xFF1A1A2E);
const _kGold = Color(0xFFC9A84C);

// -----------------------------------------------------------------------------
//  ClientBody
// -----------------------------------------------------------------------------

/// Body content wrapper for client (customer-facing) pages.
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
            // -- Hero / page banner -------------------------------------
            if (_showBanner)
              _PageBanner(pageName: pageName, imageUrl: pageImage!),

            // -- Page content -------------------------------------------
            body,

            // -- Newsletter strip ---------------------------------------
            const _NewsletterStrip(),

            // -- Site footer --------------------------------------------
            const _SiteFooter(),
          ],
        ),
      );
}

// -----------------------------------------------------------------------------
//  Page banner / hero
// -----------------------------------------------------------------------------

class _PageBanner extends StatelessWidget {
  final String pageName;
  final String imageUrl;

  const _PageBanner({required this.pageName, required this.imageUrl});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 260,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: _kNavy),
              errorWidget: (_, __, ___) => Container(color: _kNavy),
            ),

            // Gradient overlay
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x551A1A2E), Color(0xDD1A1A2E)],
                ),
              ),
            ),

            // Page title + gold accent
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Small eyebrow label
                  Text(
                    'MARCAT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _kGold,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Page name
                  Text(
                    pageName.titleCase,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Gold accent bar
                  Container(
                    width: 48,
                    height: 2,
                    decoration: BoxDecoration(
                      color: _kGold,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Breadcrumb
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.home),
                        child: Text(
                          'Home',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 14,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                      Text(
                        pageName.titleCase,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

// -----------------------------------------------------------------------------
//  Newsletter strip
// -----------------------------------------------------------------------------

class _NewsletterStrip extends StatefulWidget {
  const _NewsletterStrip();

  @override
  State<_NewsletterStrip> createState() => _NewsletterStripState();
}

class _NewsletterStripState extends State<_NewsletterStrip> {
  final _emailController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _subscribe() {
    if (_emailController.text.trim().isNotEmpty) {
      setState(() => _submitted = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 768;

    return Container(
      width: double.maxFinite,
      color: _kNavy,
      padding: EdgeInsets.symmetric(
        vertical: 56,
        horizontal: isDesktop ? 32 : 24,
      ),
      child: FB5Container(
        child: _submitted
            ? Column(
                children: [
                  const Icon(Icons.check_circle_outline_rounded,
                      color: _kGold, size: 40),
                  const SizedBox(height: 12),
                  const Text(
                    'You\'re on the list!',
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Expect style drops and exclusive offers in your inbox.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              )
            : isDesktop
                ? Row(
                    children: [
                      Expanded(child: _newsletterText()),
                      const SizedBox(width: 48),
                      Expanded(child: _newsletterField()),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _newsletterText(),
                      const SizedBox(height: 24),
                      _newsletterField(),
                    ],
                  ),
      ),
    );
  }

  Widget _newsletterText() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'JOIN THE INNER CIRCLE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _kGold,
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'First Access to\nNew Collections',
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Subscribe for exclusive early access, style edits, '
            'and members-only discounts.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
              height: 1.6,
            ),
          ),
        ],
      );

  Widget _newsletterField() => Row(
        children: [
          Expanded(
            child: TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _subscribe(),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Your email address',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.08),
                border: OutlineInputBorder(
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(10)),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(10)),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(10)),
                  borderSide: const BorderSide(color: _kGold),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          GestureDetector(
            onTap: _subscribe,
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                color: _kGold,
                borderRadius:
                    BorderRadius.horizontal(right: Radius.circular(10)),
              ),
              child: const Center(
                child: Text(
                  'Subscribe',
                  style: TextStyle(
                    color: _kNavy,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
}

// -----------------------------------------------------------------------------
//  Site footer
// -----------------------------------------------------------------------------

class _SiteFooter extends StatelessWidget {
  const _SiteFooter();

  @override
  Widget build(BuildContext context) => Column(
        children: [
          // -- Main footer -------------------------------------------------
          Container(
            width: double.maxFinite,
            color: const Color(0xFF111827),
            padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 32),
            child: FB5Container(
              child: FB5Row(
                classNames: 'justify-content-between',
                children: [
                  // Brand column
                  FB5Col(
                    classNames: 'col-lg-3 col-md-6 col-sm-12',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo text
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'MARCAT',
                                style: TextStyle(
                                  fontFamily: 'Playfair Display',
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 3,
                                ),
                              ),
                              WidgetSpan(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 4, bottom: 8),
                                  child: CircleAvatar(
                                    radius: 3,
                                    backgroundColor: _kGold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Curated fashion for every style story. '
                          'Quality pieces, timeless design.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 14,
                            height: 1.7,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Social icons
                        Row(
                          children: [
                            _SocialIcon(
                              icon: Icons.camera_alt_outlined,
                              label: 'Instagram',
                              url: 'https://www.instagram.com/abu_arandas/',
                            ),
                            const SizedBox(width: 8),
                            _SocialIcon(
                              icon: Icons.facebook_outlined,
                              label: 'Facebook',
                              url: 'https://web.facebook.com/abu00arandas/',
                            ),
                            const SizedBox(width: 8),
                            _SocialIcon(
                              icon: Icons.chat_outlined,
                              label: 'WhatsApp',
                              url: 'https://wa.me/0791568798',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Shop links
                  FB5Col(
                    classNames: 'col-lg-3 col-md-6 col-sm-12',
                    child: _FooterColumn(
                      heading: 'Shop',
                      links: [
                        _FooterLink(
                            label: 'Women',
                            onTap: () => Get.toNamed(AppRoutes.shop)),
                        _FooterLink(
                            label: 'Men',
                            onTap: () => Get.toNamed(AppRoutes.shop)),
                        _FooterLink(
                            label: 'Kids',
                            onTap: () => Get.toNamed(AppRoutes.shop)),
                        _FooterLink(
                            label: 'Sale',
                            onTap: () => Get.toNamed(AppRoutes.shop)),
                        _FooterLink(
                            label: 'New Arrivals',
                            onTap: () => Get.toNamed(AppRoutes.shop)),
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
                            onTap: () => Get.toNamed(AppRoutes.orders)),
                        _FooterLink(
                            label: 'Wishlist',
                            onTap: () => Get.toNamed(AppRoutes.wishlist)),
                        _FooterLink(
                            label: 'Edit Profile',
                            onTap: () => Get.toNamed(AppRoutes.profile)),
                        _FooterLink(
                            label: 'Sign In',
                            onTap: () => Get.toNamed(AppRoutes.login)),
                      ],
                    ),
                  ),

                  // Company links
                  FB5Col(
                    classNames: 'col-lg-3 col-md-6 col-sm-12',
                    child: _FooterColumn(
                      heading: 'Company',
                      links: [
                        _FooterLink(
                            label: 'About Us',
                            onTap: () => Get.toNamed(AppRoutes.about)),
                        _FooterLink(
                            label: 'Contact Us',
                            onTap: () => Get.toNamed(AppRoutes.contact)),
                        _FooterLink(
                            label: 'Size Guide',
                            onTap: () => Get.toNamed('/app/size-guide')),
                        _FooterLink(
                            label: 'Return Policy',
                            onTap: () => Get.toNamed('/app/returns')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // -- Payment & trust strip ----------------------------------------
          Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            color: const Color(0xFF0D1117),
            child: FB5Container(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 10,
                children: [
                  // Copyright
                  Wrap(
                    spacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '© ${DateTime.now().year} MARCAT. Designed with love by',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 13,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Ehab Arandas',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _kGold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Trust badges / payment icons row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _TrustBadge(
                          icon: Icons.lock_outline_rounded, label: 'Secure'),
                      const SizedBox(width: 16),
                      _TrustBadge(
                          icon: Icons.local_shipping_outlined,
                          label: 'Free Shipping'),
                      const SizedBox(width: 16),
                      _TrustBadge(
                          icon: Icons.replay_outlined, label: 'Easy Returns'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );
}

// -----------------------------------------------------------------------------
//  Footer helpers
// -----------------------------------------------------------------------------

class _FooterLink {
  final String label;
  final VoidCallback onTap;
  const _FooterLink({required this.label, required this.onTap});
}

class _FooterColumn extends StatelessWidget {
  final String heading;
  final List<_FooterLink> links;

  const _FooterColumn({required this.heading, required this.links});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading
          Row(
            children: [
              Container(
                width: 16,
                height: 2,
                color: _kGold,
                margin: const EdgeInsets.only(right: 8),
              ),
              Text(
                heading.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...links.map(
            (link) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: link.onTap,
                child: Text(
                  link.label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;

  const _SocialIcon({
    required this.icon,
    required this.label,
    required this.url,
  });

  @override
  Widget build(BuildContext context) => Tooltip(
        message: label,
        child: InkWell(
          onTap: () {}, // TODO: launch URL
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
              ),
            ),
            child: Icon(icon, size: 18, color: Colors.white.withOpacity(0.7)),
          ),
        ),
      );
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white.withOpacity(0.35)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.35),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
}
