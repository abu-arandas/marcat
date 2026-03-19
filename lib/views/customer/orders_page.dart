// lib/views/customer/orders_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';

import 'package:marcat/controllers/auth_controller.dart';
import 'package:marcat/controllers/cart_controller.dart';
import 'package:marcat/core/constants/app_colors.dart';
import 'package:marcat/core/constants/app_text_styles.dart';
import 'package:marcat/core/extensions/currency_extensions.dart';
import 'package:marcat/core/extensions/date_extensions.dart';
import 'package:marcat/core/router/app_router.dart';
import 'package:marcat/models/enums.dart';
import 'package:marcat/models/sale_model.dart';

import 'scaffold/app_scaffold.dart';
import 'shared/brand.dart';
import 'shared/empty_state.dart';
import 'shared/section_header.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OrdersPage
// ─────────────────────────────────────────────────────────────────────────────

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final _orders = <SaleModel>[];
  bool _isLoading = true;
  bool _hasMore = true;
  String? _filterStatus;
  int _page = 0;

  CartController get _repo => Get.find<CartController>();
  AuthController get _auth => Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _fetchOrders(reset: true);
  }

  Future<void> _fetchOrders({bool reset = false}) async {
    final user = _auth.state.value.user;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    if (reset) {
      _page = 0;
      _orders.clear();
      _hasMore = true;
    }
    if (!_hasMore) return;
    if (mounted) setState(() => _isLoading = true);

    try {
      final (items, total) = await _repo.fetchOrders(
        page: _page,
        customerId: user.id,
        status: _filterStatus,
      );
      if (mounted) {
        setState(() {
          _orders.addAll(items);
          _page++;
          _hasMore = _orders.length < total;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        Get.snackbar(
          'Error',
          e.toString(),
          backgroundColor: kNavy,
          colorText: Colors.white,
        );
      }
    }
  }

  void _setFilter(String? status) {
    if (_filterStatus == status) return;
    setState(() => _filterStatus = status);
    _fetchOrders(reset: true);
  }

  @override
  Widget build(BuildContext context) => CustomerScaffold(
        page: 'My Orders',
        pageImage:
            'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=1600&q=80',
        body: FB5Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  eyebrow: 'Account',
                  title: 'Order History',
                  subtitle: 'Track and manage your purchases.',
                ),
                const SizedBox(height: 28),
                _FilterChips(
                  current: _filterStatus,
                  onChanged: _setFilter,
                ),
                const SizedBox(height: 24),
                _OrderList(
                  orders: _orders,
                  isLoading: _isLoading,
                  hasMore: _hasMore,
                  onLoadMore: () => _fetchOrders(),
                ),
              ],
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _FilterChips
// ─────────────────────────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.current, required this.onChanged});

  final String? current;
  final ValueChanged<String?> onChanged;

  static const _options = <String, String?>{
    'All': null,
    'Pending': 'pending',
    'Paid': 'paid',
    'Shipped': 'shipped',
    'Delivered': 'delivered',
    'Cancelled': 'cancelled',
  };

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _options.entries.map((e) {
            final active = current == e.value;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onChanged(e.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: active ? kNavy : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: active ? kNavy : kBorder,
                    ),
                  ),
                  child: Text(
                    e.key,
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: active ? Colors.white : kSlate,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _OrderList
// ─────────────────────────────────────────────────────────────────────────────

class _OrderList extends StatelessWidget {
  const _OrderList({
    required this.orders,
    required this.isLoading,
    required this.hasMore,
    required this.onLoadMore,
  });

  final List<SaleModel> orders;
  final bool isLoading;
  final bool hasMore;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (isLoading && orders.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 80),
          child: CircularProgressIndicator(
            color: AppColors.marcatGold,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (orders.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No Orders Yet',
        subtitle: "You haven't placed any orders yet.\nStart shopping!",
      );
    }

    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => _OrderCard(order: orders[i]),
        ),
        if (hasMore) ...[
          const SizedBox(height: 24),
          Center(
            child: isLoading
                ? const CircularProgressIndicator(
                    color: AppColors.marcatGold, strokeWidth: 2)
                : OutlinedButton(
                    onPressed: onLoadMore,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kNavy,
                      side: const BorderSide(color: kBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Load More'),
                  ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _OrderCard
// ─────────────────────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final SaleModel order;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => Get.toNamed(
          AppRoutes.orderDetailOf(order.id),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Order #${order.id}',
                      style: AppTextStyles.titleSmall,
                    ),
                  ),
                  _StatusBadge(
                    status: SaleStatusX.fromDb(order.status),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ── Meta row ───────────────────────────────────────────────
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 13,
                    color: kSlate,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    // ✅ FIX: replaced manual _formatDate() with shortDate()
                    order.createdAt.shortDate(),
                    style: AppTextStyles.bodySmall.copyWith(color: kSlate),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.receipt_outlined,
                    size: 13,
                    color: kSlate,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    order.grandTotal.toJOD(),
                    style: AppTextStyles.priceMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── View Details CTA ───────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text(
                    'View Details',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kNavy,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: kNavy,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _StatusBadge
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final SaleStatus status;

  Color get _bg => switch (status) {
        SaleStatus.pending => AppColors.statusAmberLight,
        SaleStatus.paid => AppColors.statusBlueLight,
        SaleStatus.shipped => AppColors.statusBlueLight,
        SaleStatus.delivered => AppColors.statusGreenLight,
        SaleStatus.cancelled => AppColors.statusRedLight,
      };

  Color get _fg => switch (status) {
        SaleStatus.pending => AppColors.statusAmber,
        SaleStatus.paid => AppColors.statusBlue,
        SaleStatus.shipped => AppColors.statusBlue,
        SaleStatus.delivered => AppColors.statusGreen,
        SaleStatus.cancelled => AppColors.statusRed,
      };

  String get _label => switch (status) {
        SaleStatus.pending => 'Pending',
        SaleStatus.paid => 'Paid',
        SaleStatus.shipped => 'Shipped',
        SaleStatus.delivered => 'Delivered',
        SaleStatus.cancelled => 'Cancelled',
      };

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          _label,
          style: TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _fg,
          ),
        ),
      );
}
