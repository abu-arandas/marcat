// lib/views/customer/orders_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';

import 'package:marcat/controllers/auth_controller.dart';
import 'package:marcat/controllers/cart_controller.dart';
import 'package:marcat/core/constants/app_colors.dart';
import 'package:marcat/core/constants/app_text_styles.dart';
import 'package:marcat/core/extensions/currency_extensions.dart';
import 'package:marcat/core/router/app_router.dart';
import 'package:marcat/models/enums.dart';
import 'package:marcat/models/sale_model.dart';

import 'scaffold/app_scaffold.dart';
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
      if (mounted) setState(() => _isLoading = false);
      Get.snackbar('Error', e.toString(),
          backgroundColor: AppColors.marcatNavy, colorText: Colors.white);
    }
  }

  void _setFilter(String? status) {
    setState(() => _filterStatus = status);
    _fetchOrders(reset: true);
  }

  @override
  Widget build(BuildContext context) => CustomerScaffold(
        page: 'My Orders',
        pageImage:
            'https://images.unsplash.com/photo-1601598851547-4302969d0614?w=1600&q=80',
        body: _OrdersBody(
          orders: _orders,
          isLoading: _isLoading,
          hasMore: _hasMore,
          filterStatus: _filterStatus,
          onLoadMore: () => _fetchOrders(),
          onSetFilter: _setFilter,
          onRefresh: () => _fetchOrders(reset: true),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _OrdersBody
// ─────────────────────────────────────────────────────────────────────────────

class _OrdersBody extends StatelessWidget {
  const _OrdersBody({
    required this.orders,
    required this.isLoading,
    required this.hasMore,
    required this.filterStatus,
    required this.onLoadMore,
    required this.onSetFilter,
    required this.onRefresh,
  });

  final List<SaleModel> orders;
  final bool isLoading;
  final bool hasMore;
  final String? filterStatus;
  final VoidCallback onLoadMore;
  final void Function(String?) onSetFilter;
  final VoidCallback onRefresh;

  static const _statuses = [
    null, 'pending', 'paid', 'shipped', 'delivered', 'cancelled',
  ];

  @override
  Widget build(BuildContext context) => FB5Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                eyebrow: 'Account',
                title: 'My Orders',
                subtitle: 'Track and manage your purchases.',
              ),
              const SizedBox(height: 24),

              // ── Status filter chips ────────────────────────────────────
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _statuses.map((s) {
                    final isActive = filterStatus == s;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          s == null ? 'All' : _capitalize(s),
                          style: TextStyle(
                            fontFamily: 'IBMPlexSansArabic',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? Colors.white
                                : AppColors.marcatNavy,
                          ),
                        ),
                        selected: isActive,
                        onSelected: (_) => onSetFilter(s),
                        selectedColor: AppColors.marcatNavy,
                        backgroundColor: AppColors.marcatCream,
                        side: const BorderSide(color: AppColors.borderLight),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 32),

              // ── Orders list ────────────────────────────────────────────
              if (isLoading && orders.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.marcatGold),
                  ),
                )
              else if (orders.isEmpty)
                EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No Orders Yet',
                  subtitle: "You haven't placed any orders yet.\nStart shopping to see them here.",
                  actionLabel: 'Shop Now',
                  onAction: () => Get.toNamed(AppRoutes.shop),
                )
              else ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, i) => _OrderCard(order: orders[i]),
                ),
                if (hasMore) ...[
                  const SizedBox(height: 32),
                  Center(
                    child: isLoading
                        ? const CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.marcatGold)
                        : OutlinedButton(
                            onPressed: onLoadMore,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: AppColors.marcatNavy),
                              foregroundColor: AppColors.marcatNavy,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Load More',
                              style: TextStyle(
                                fontFamily: 'IBMPlexSansArabic',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ),
                ],
              ],
            ],
          ),
        ),
      );

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─────────────────────────────────────────────────────────────────────────────
// _OrderCard
// ─────────────────────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final SaleModel order;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.orderDetailOf(order.id)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '#${order.referenceNumber}',
                      style: AppTextStyles.referenceText,
                    ),
                  ),
                  _StatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(color: AppColors.borderLight, height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  _InfoItem(
                    icon: Icons.calendar_today_outlined,
                    label: _formatDate(order.createdAt),
                  ),
                  const SizedBox(width: 20),
                  _InfoItem(
                    icon: Icons.storefront_outlined,
                    label: order.channel.dbValue.toUpperCase(),
                  ),
                  const Spacer(),
                  Text(
                    order.grandTotal.toJOD(),
                    style: AppTextStyles.priceMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'View Details',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.marcatGold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded,
                      size: 14, color: AppColors.marcatGold),
                ],
              ),
            ],
          ),
        ),
      );

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${local.day} ${months[local.month - 1]} ${local.year}';
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.marcatSlate),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 12,
              color: AppColors.marcatSlate,
            ),
          ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _StatusBadge
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final SaleStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (status) {
      SaleStatus.pending => (
          AppColors.statusAmberLight,
          AppColors.statusAmber,
          'Pending'
        ),
      SaleStatus.paid => (
          AppColors.statusBlueLight,
          AppColors.statusBlue,
          'Paid'
        ),
      SaleStatus.shipped => (
          AppColors.statusBlueLight,
          AppColors.statusBlue,
          'Shipped'
        ),
      SaleStatus.delivered => (
          AppColors.statusGreenLight,
          AppColors.statusGreen,
          'Delivered'
        ),
      SaleStatus.cancelled => (
          AppColors.statusRedLight,
          AppColors.statusRed,
          'Cancelled'
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'IBMPlexSansArabic',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
