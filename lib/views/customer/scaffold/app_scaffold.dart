// lib/views/customer/scaffold/app_scaffold.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/router/app_router.dart';
import 'widgets/appbar.dart';
import 'widgets/body.dart';
import 'widgets/drawer.dart';

class CustomerScaffold extends StatefulWidget {
  final String page;
  final Widget body;
  final Widget? filterDrawer;

  /// Optional hero/banner image URL shown at the top of the page.
  final String? pageImage;

  const CustomerScaffold({
    super.key,
    required this.page,
    required this.body,
    this.filterDrawer,
    this.pageImage,
  });

  @override
  State<CustomerScaffold> createState() => _CustomerScaffoldState();
}

class _CustomerScaffoldState extends State<CustomerScaffold> {
  late final ScrollController _scrollController;
  bool _scrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        final didScroll = _scrollController.offset >= 10;
        if (didScroll != _scrolled) setState(() => _scrolled = didScroll);
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: Get.currentRoute == AppRoutes.home,
      backgroundColor: const Color(0xFFF8F5F0), // warm off-white base

      // ── Top app bar ───────────────────────────────────────────────────────
      appBar: CustomerAppBar(
        pageName: widget.page,
        scrolled: _scrolled,
        hasFilterDrawer: widget.filterDrawer != null,
      ),

      // ── Right end-drawer: main navigation ─────────────────────────────────
      endDrawer: const CustomerDrawer(),

      // ── Left drawer: filter / sort (optional) ─────────────────────────────
      drawer: widget.filterDrawer != null
          ? Drawer(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              backgroundColor: Colors.white,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 16, 0),
                      child: Row(
                        children: [
                          const Text(
                            'Filter & Sort',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                              letterSpacing: 0.3,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Get.back(),
                            icon: const Icon(Icons.close_rounded, size: 20),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFFF1EDE7),
                              foregroundColor: const Color(0xFF6B6B7B),
                              padding: const EdgeInsets.all(8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Color(0xFFEEE8E0), height: 1),

                    // Scrollable filter content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: widget.filterDrawer!,
                      ),
                    ),

                    // Apply button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => Get.back(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A1A2E),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                          child: const Text('Apply Filters'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,

      // ── Page body ─────────────────────────────────────────────────────────
      body: ClientBody(
        pageName: widget.page,
        pageImage: widget.pageImage ?? '',
        body: widget.body,
        scrollController: _scrollController,
      ),

      // ── Scroll-to-top FAB ─────────────────────────────────────────────────
      floatingActionButton: _scrolled
          ? FloatingActionButton(
              heroTag: 'scroll_to_top_${widget.page}',
              onPressed: () => _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutCubic,
              ),
              backgroundColor: const Color(0xFF1A1A2E),
              foregroundColor: Colors.white,
              elevation: 6,
              mini: true,
              child: const Icon(Icons.keyboard_arrow_up_rounded, size: 22),
            )
          : null,
    );
  }
}
