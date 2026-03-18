// lib/views/customer/about_page.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';

import 'scaffold/app_scaffold.dart';
import 'shared/brand.dart';
import 'shared/buttons.dart';
import 'shared/section_header.dart';
import 'package:marcat/core/router/app_router.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) => CustomerScaffold(
        page: 'About Us',
        pageImage:
            'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?w=1600&q=80',
        body: const _AboutBody(),
      );
}

class _AboutBody extends StatelessWidget {
  const _AboutBody();

  @override
  Widget build(BuildContext context) => const Column(
        children: [
          _OurStory(),
          SizedBox(height: 80),
          _MissionValues(),
          SizedBox(height: 80),
          _TeamSection(),
          SizedBox(height: 80),
          _StatsStrip(),
          SizedBox(height: 80),
        ],
      );
}

// â”€â”€â”€ Our Story â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _OurStory extends StatelessWidget {
  const _OurStory();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 900;

    return FB5Container(
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _storyText()),
                const SizedBox(width: 72),
                Expanded(child: _storyImage()),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _storyImage(),
                const SizedBox(height: 40),
                _storyText(),
              ],
            ),
    );
  }

  Widget _storyText() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            eyebrow: 'Our Story',
            title: 'Born From a Passion\nFor Fashion',
          ),
          const SizedBox(height: 24),
          const Text(
            'MARCAT was founded in 2018 in the heart of Amman, Jordan, '
            'with a single belief: that beautiful clothing should be '
            'accessible to everyone without compromising on quality.',
            style: TextStyle(
              fontSize: 15,
              color: kSlate,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'What started as a small boutique in Abdali has grown into '
            'a multi-store brand serving customers across Jordan and the '
            'wider region. Every piece we carry is hand-selected by our '
            'team for its craftsmanship, sustainability, and timeless appeal.',
            style: TextStyle(
              fontSize: 15,
              color: kSlate,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            child: OutlineButton(
              label: 'Shop the Collection',
              onPressed: () => Get.toNamed(AppRoutes.shop),
              height: 48,
              icon: Icons.arrow_forward_rounded,
            ),
          ),
        ],
      );

  Widget _storyImage() => ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: CachedNetworkImage(
            imageUrl:
                'https://images.unsplash.com/photo-1441984904996-e0b6ba687e04?w=800&q=80',
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: kCream),
          ),
        ),
      );
}

// â”€â”€â”€ Mission & Values â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _MissionValues extends StatelessWidget {
  const _MissionValues();

  static const _values = [
    _Value(
      Icons.eco_outlined,
      'Sustainability',
      'We source fabrics responsibly and minimise waste at every step of our supply chain.',
    ),
    _Value(
      Icons.verified_outlined,
      'Authentic Quality',
      'Every item passes rigorous quality checks before it reaches your wardrobe.',
    ),
    _Value(
      Icons.diversity_1_outlined,
      'Inclusive Fashion',
      'Style has no size, age, or background. Our collections celebrate every body.',
    ),
    _Value(
      Icons.handshake_outlined,
      'Community First',
      'Rooted in Amman, we reinvest in the local creative economy.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 700;

    return Container(
      color: kNavy,
      padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 24),
      child: FB5Container(
        child: Column(
          children: [
            const SectionHeader(
              eyebrow: 'What We Stand For',
              title: 'Our Values',
              subtitle: 'The principles that guide every decision we make.',
              dark: true,
            ),
            const SizedBox(height: 56),
            isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _values
                        .map((v) => Expanded(child: _ValueCard(v)))
                        .toList(),
                  )
                : Column(
                    children: _values.map((v) => _ValueCard(v)).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}

class _Value {
  final IconData icon;
  final String title, desc;
  const _Value(this.icon, this.title, this.desc);
}

class _ValueCard extends StatelessWidget {
  final _Value v;
  const _ValueCard(this.v);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                border: Border.all(color: kGold.withOpacity(0.45)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(v.icon, size: 22, color: kGold),
            ),
            const SizedBox(height: 20),
            Text(
              v.title,
              style: const TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              v.desc,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
                height: 1.7,
              ),
            ),
          ],
        ),
      );
}

// â”€â”€â”€ Team â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _TeamSection extends StatelessWidget {
  const _TeamSection();

  static const _team = [
    _Member(
      'Ehab Arandas',
      'Founder & CEO',
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80',
    ),
    _Member(
      'Sara Khalil',
      'Head of Buying',
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&q=80',
    ),
    _Member(
      'Omar Hamdan',
      'Creative Director',
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&q=80',
    ),
    _Member(
      'Lina Nassar',
      'Customer Experience',
      'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=400&q=80',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 700;

    return FB5Container(
      child: Column(
        children: [
          const SectionHeader(
            eyebrow: 'The Faces Behind MARCAT',
            title: 'Meet Our Team',
            subtitle: 'Passionate people dedicated to bringing you the best.',
          ),
          const SizedBox(height: 48),
          isDesktop
              ? Row(
                  children: _team
                      .map((m) => Expanded(child: _MemberCard(m)))
                      .toList(),
                )
              : GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 24,
                  childAspectRatio: 0.72,
                  children: _team.map((m) => _MemberCard(m)).toList(),
                ),
        ],
      ),
    );
  }
}

class _Member {
  final String name, role, imageUrl;
  const _Member(this.name, this.role, this.imageUrl);
}

class _MemberCard extends StatefulWidget {
  final _Member m;
  const _MemberCard(this.m);

  @override
  State<_MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends State<_MemberCard> {
  bool _h = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        onEnter: (_) => setState(() => _h = true),
        onExit: (_) => setState(() => _h = false),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: AspectRatio(
                  aspectRatio: 0.8,
                  child: Stack(fit: StackFit.expand, children: [
                    AnimatedScale(
                      scale: _h ? 1.06 : 1.0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      child: CachedNetworkImage(
                        imageUrl: widget.m.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: kCream),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            _h
                                ? kNavy.withOpacity(0.55)
                                : kNavy.withOpacity(0.25),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                widget.m.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: kNavy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.m.role,
                style: const TextStyle(fontSize: 13, color: kSlate),
              ),
            ],
          ),
        ),
      );
}

// â”€â”€â”€ Stats Strip â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _StatsStrip extends StatelessWidget {
  const _StatsStrip();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 600;

    return Container(
      color: kCream,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: FB5Container(
        child: isDesktop
            ? Row(
                children: const [
                  Expanded(child: _Stat('7+', 'Years in Fashion')),
                  _StatDivider(),
                  Expanded(child: _Stat('50K+', 'Happy Customers')),
                  _StatDivider(),
                  Expanded(child: _Stat('5', 'Store Locations')),
                  _StatDivider(),
                  Expanded(child: _Stat('2K+', 'Products Curated')),
                ],
              )
            : Wrap(
                spacing: 0,
                runSpacing: 32,
                children: [
                  SizedBox(
                      width: MediaQuery.sizeOf(context).width / 2 - 32,
                      child: const _Stat('7+', 'Years in Fashion')),
                  SizedBox(
                      width: MediaQuery.sizeOf(context).width / 2 - 32,
                      child: const _Stat('50K+', 'Happy Customers')),
                  SizedBox(
                      width: MediaQuery.sizeOf(context).width / 2 - 32,
                      child: const _Stat('5', 'Store Locations')),
                  SizedBox(
                      width: MediaQuery.sizeOf(context).width / 2 - 32,
                      child: const _Stat('2K+', 'Products Curated')),
                ],
              ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat(this.value, this.label);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: kNavy,
            ),
          ),
          const SizedBox(height: 6),
          Container(width: 28, height: 2, color: kGold),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kSlate,
              letterSpacing: 0.5,
            ),
          ),
        ],
      );
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 80,
        color: kBorderColor,
        margin: const EdgeInsets.symmetric(horizontal: 8),
      );
}
