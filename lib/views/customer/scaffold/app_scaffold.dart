// lib/views/customer/scaffold/app_scaffold.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/router/app_router.dart';
import 'widgets/appbar.dart';
import 'widgets/body.dart';
import 'widgets/drawer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CustomerScaffold
// ─────────────────────────────────────────────────────────────────────────────

class CustomerScaffold extends StatefulWidget {
  const CustomerScaffold({
    super.key,
    required this.page,
    required this.body,
    this.filterDrawer,
    this.pageImage,
  });

  final String page;
  final Widget body;

  /// Optional filter/sort drawer shown on the left side (e.g. ShopPage).
  final Widget? filterDrawer;

  /// Optional hero/banner image URL shown at the top of the page.
  final String? pageImage;

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
        if (didScroll != _scrolled) {
          setState(() => _scrolled = didScroll);
        }
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isHome = Get.currentRoute == AppRoutes.home;

    return Scaffold(
      extendBodyBehindAppBar: isHome,
      backgroundColor: const Color(0xFFF8F5F0),

      // ── App bar ───────────────────────────────────────────────────────────
      appBar: CustomerAppBar(
        pageName: widget.page,
        scrolled: _scrolled,
        hasFilterDrawer: widget.filterDrawer != null,
      ),

      // ── Right end-drawer: main navigation ─────────────────────────────────
      endDrawer: const CustomerDrawer(),

      // ── Left drawer: filter / sort ─────────────────────────────────────────
      drawer: widget.filterDrawer != null
          ? Drawer(
              child: SafeArea(child: widget.filterDrawer!),
            )
          : null,

      // ── Body ──────────────────────────────────────────────────────────────
      body: ClientBody(
        pageName: widget.page,
        pageImage: widget.pageImage,
        body: widget.body,
        scrollController: _scrollController,
      ),
    );
  }
}
