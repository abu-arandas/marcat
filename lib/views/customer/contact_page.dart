// lib/views/customer/contact_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';

import 'scaffold/app_scaffold.dart';
import 'shared/brand.dart';
import 'shared/buttons.dart';
import 'shared/section_header.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ContactPage
// ─────────────────────────────────────────────────────────────────────────────

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) => CustomerScaffold(
        page: 'Contact Us',
        pageImage:
            'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=1600&q=80',
        body: const _ContactBody(),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _ContactBody
// ─────────────────────────────────────────────────────────────────────────────

class _ContactBody extends StatelessWidget {
  const _ContactBody();

  @override
  Widget build(BuildContext context) => const Column(
        children: [
          _ContactMain(),
          SizedBox(height: 80),
          _StoreLocations(),
          SizedBox(height: 80),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _ContactMain
// ─────────────────────────────────────────────────────────────────────────────

class _ContactMain extends StatelessWidget {
  const _ContactMain();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 900;

    return FB5Container(
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(flex: 5, child: _ContactForm()),
                const SizedBox(width: 72),
                Expanded(flex: 3, child: _ContactInfo()),
              ],
            )
          : Column(
              children: [
                _ContactInfo(),
                const SizedBox(height: 40),
                const _ContactForm(),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ContactInfo — address / hours / social panel
// ─────────────────────────────────────────────────────────────────────────────

class _ContactInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            eyebrow: 'Get In Touch',
            title: "We'd Love\nTo Hear\nFrom You",
          ),
          const SizedBox(height: 32),
          _InfoTile(
            icon: Icons.phone_outlined,
            title: 'Phone',
            value: '+962 79 156 8798',
          ),
          _InfoTile(
            icon: Icons.email_outlined,
            title: 'Email',
            value: 'hello@marcat.jo',
          ),
          _InfoTile(
            icon: Icons.location_on_outlined,
            title: 'Flagship Store',
            value: 'Abdali Boulevard,\nAmman, Jordan',
          ),
          _InfoTile(
            icon: Icons.schedule_outlined,
            title: 'Working Hours',
            value: 'Sat–Thu  10:00 – 22:00\nFri  14:00 – 22:00',
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _SocialChip(icon: Icons.language, label: 'Website'),
              const SizedBox(width: 10),
              _SocialChip(icon: Icons.camera_alt_outlined, label: 'Instagram'),
              const SizedBox(width: 10),
              _SocialChip(icon: Icons.facebook, label: 'Facebook'),
            ],
          ),
        ],
      );
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: kCream,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kBorderColor),
              ),
              child: Icon(icon, size: 18, color: kNavy),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: kSlate,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kNavy,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _SocialChip extends StatelessWidget {
  const _SocialChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: label,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: kCream,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: kBorderColor),
          ),
          child: Icon(icon, size: 18, color: kNavy),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _ContactForm — stateful form with submit / success states
// ─────────────────────────────────────────────────────────────────────────────

class _ContactForm extends StatefulWidget {
  const _ContactForm();

  @override
  State<_ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<_ContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _loading = false;
  bool _submitted = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (mounted) setState(() => _loading = true);
    // Simulate a network call — replace with real Supabase insert.
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) {
      setState(() {
        _loading = false;
        _submitted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) =>
      _submitted ? _successBody() : _formBody();

  Widget _successBody() => Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFD8F3DC),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 36,
              color: Color(0xFF2D6A4F),
            ),
          ),
          const SizedBox(height: 24),
          // ✅ FIXED: was 'Playfair Display' (with space) — Flutter
          //    could not resolve this family → fell back to system font.
          //    Correct name matches pubspec.yaml declaration: 'PlayfairDisplay'.
          const Text(
            'Message Sent!',
            style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: kNavy,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Thank you for reaching out. Our team will get back to you within 24 hours.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 14,
              color: kSlate,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
        ],
      );

  Widget _formBody() => Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ FIXED: 'Playfair Display' → 'PlayfairDisplay'
            const Text(
              'Send Us a Message',
              style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: kNavy,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'We typically respond within one business day.',
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 13,
                color: kSlate,
              ),
            ),
            const SizedBox(height: 28),
            _Field(
              controller: _nameCtrl,
              label: 'Full Name',
              hint: 'Your full name',
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Please enter your name'
                  : null,
            ),
            const SizedBox(height: 16),
            _Field(
              controller: _emailCtrl,
              label: 'Email Address',
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _Field(
              controller: _subjectCtrl,
              label: 'Subject',
              hint: 'How can we help?',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            _Field(
              controller: _messageCtrl,
              label: 'Message',
              hint: 'Write your message here…',
              maxLines: 5,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'Send Message',
              onPressed: _submit,
              loading: _loading,
              icon: Icons.send_outlined,
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _Field — shared form input
// ─────────────────────────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(
          fontFamily: 'IBMPlexSansArabic',
          fontSize: 14,
          color: kNavy,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 13,
            color: kSlate,
          ),
          hintStyle: const TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 13,
            color: kSlate,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kNavy, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kRed),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _StoreLocations — static store cards strip
// ─────────────────────────────────────────────────────────────────────────────

class _StoreLocations extends StatelessWidget {
  const _StoreLocations();

  static const _stores = [
    _StoreData(
      name: 'Abdali',
      address: 'Abdali Boulevard, Floor 2\nAmman, Jordan',
      hours: 'Sat–Thu 10:00–22:00\nFri 14:00–22:00',
      phone: '+962 6 560 1234',
    ),
    _StoreData(
      name: 'Mecca Mall',
      address: 'Mecca Mall, West Amman\nAmman, Jordan',
      hours: 'Daily 10:00–22:00',
      phone: '+962 6 551 9876',
    ),
    _StoreData(
      name: 'City Mall',
      address: 'City Mall, Khalda\nAmman, Jordan',
      hours: 'Daily 10:00–22:00',
      phone: '+962 6 541 3210',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 768;

    return FB5Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            eyebrow: 'Our Stores',
            title: 'Visit Us In Person',
            subtitle:
                'Three locations across Amman — each with the full MARCAT experience.',
          ),
          const SizedBox(height: 40),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _stores
                  .map((s) => Expanded(child: _StoreCard(store: s)))
                  .toList(),
            )
          else
            Column(
              children: _stores
                  .map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _StoreCard(store: s),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _StoreData {
  const _StoreData({
    required this.name,
    required this.address,
    required this.hours,
    required this.phone,
  });

  final String name;
  final String address;
  final String hours;
  final String phone;
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({required this.store});

  final _StoreData store;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              store.name,
              style: const TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: kNavy,
              ),
            ),
            const SizedBox(height: 16),
            _Detail(Icons.location_on_outlined, store.address),
            const SizedBox(height: 10),
            _Detail(Icons.schedule_outlined, store.hours),
            const SizedBox(height: 10),
            _Detail(Icons.phone_outlined, store.phone),
          ],
        ),
      );
}

class _Detail extends StatelessWidget {
  const _Detail(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: kSlate),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 13,
                color: kSlate,
                height: 1.5,
              ),
            ),
          ),
        ],
      );
}
