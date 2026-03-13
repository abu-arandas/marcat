// lib/views/customer/contact_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';

import 'scaffold/app_scaffold.dart';
import 'shared/brand.dart';
import 'shared/marcat_buttons.dart';
import 'shared/section_header.dart';

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

// â”€â”€â”€ Main contact section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
                SizedBox(height: 40),
                _ContactForm(),
              ],
            ),
    );
  }
}

// â”€â”€â”€ Contact info panel â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ContactInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            eyebrow: 'Get In Touch',
            title: 'We\'d Love\nTo Hear\nFrom You',
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
            value: 'Satâ€“Thu: 10am â€“ 10pm\nFri: 2pm â€“ 10pm',
          ),
          const SizedBox(height: 28),

          // Social quick links
          const Text(
            'FOLLOW US',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: kSlate,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _SocialChip(
                icon: Icons.camera_alt_outlined,
                label: 'Instagram',
              ),
              const SizedBox(width: 8),
              _SocialChip(
                icon: Icons.facebook_outlined,
                label: 'Facebook',
              ),
              const SizedBox(width: 8),
              _SocialChip(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'WhatsApp',
              ),
            ],
          ),
        ],
      );
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title, value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
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
                    title,
                    style: const TextStyle(
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
  final IconData icon;
  final String label;
  const _SocialChip({required this.icon, required this.label});

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

// â”€â”€â”€ Contact form â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
  bool _sent = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulate network
    setState(() {
      _loading = false;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: _sent ? _sentState() : _formBody(),
      );

  Widget _sentState() => Column(
        children: [
          const SizedBox(height: 24),
          const Icon(Icons.check_circle_outline_rounded,
              color: kGold, size: 52),
          const SizedBox(height: 20),
          const Text(
            'Message Sent!',
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: kNavy,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Thank you for reaching out. Our team will get back to you within 24 hours.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: kSlate, height: 1.6),
          ),
          const SizedBox(height: 24),
        ],
      );

  Widget _formBody() => Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Send Us a Message',
              style: TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: kNavy,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'We typically respond within one business day.',
              style: TextStyle(fontSize: 13, color: kSlate),
            ),
            const SizedBox(height: 28),
            _Field(
              controller: _nameCtrl,
              label: 'Full Name',
              hint: 'Your full name',
              validator: (v) => v == null || v.trim().isEmpty
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
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            _Field(
              controller: _messageCtrl,
              label: 'Message',
              hint: 'Write your message hereâ€¦',
              maxLines: 5,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
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

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: kNavy,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(fontSize: 14, color: kNavy),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: kSlate, fontSize: 14),
              filled: true,
              fillColor: kCream,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kBorderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kBorderColor),
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
          ),
        ],
      );
}

// â”€â”€â”€ Store Locations â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _StoreLocations extends StatelessWidget {
  const _StoreLocations();

  static const _stores = [
    _Store(
        'Abdali Flagship', 'Abdali Boulevard, Amman', 'Satâ€“Thu 10amâ€“10pm'),
    _Store('Mecca Mall', 'Mecca Street, Amman', 'Daily 10amâ€“11pm'),
    _Store('City Mall', 'Tla\'a Al Ali, Amman', 'Daily 10amâ€“11pm'),
    _Store(
        'Aqaba Branch', 'Al Hammamat Al Tunisiyya, Aqaba', 'Daily 9amâ€“10pm'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 700;

    return Container(
      color: kCream,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: FB5Container(
        child: Column(
          children: [
            const SectionHeader(
              eyebrow: 'Find Us',
              title: 'Our Stores',
              subtitle: 'Visit us at any of our locations across Jordan.',
            ),
            const SizedBox(height: 48),
            isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _stores
                        .map((s) => Expanded(child: _StoreCard(s)))
                        .toList(),
                  )
                : Column(
                    children: _stores.map((s) => _StoreCard(s)).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}

class _Store {
  final String name, address, hours;
  const _Store(this.name, this.address, this.hours);
}

class _StoreCard extends StatelessWidget {
  final _Store s;
  const _StoreCard(this.s);

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(8, 0, 8, 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kBorderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: kNavy,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.store_outlined,
                  size: 18, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              s.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: kNavy,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              s.address,
              style: const TextStyle(fontSize: 13, color: kSlate, height: 1.5),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.schedule_outlined, size: 13, color: kGold),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    s.hours,
                    style: const TextStyle(
                        fontSize: 12,
                        color: kSlate,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}
