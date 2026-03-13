// lib/views/customer/orders_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';
import 'package:marcat/controllers/auth_controller.dart';
import 'package:marcat/controllers/cart_controller.dart';
import 'package:marcat/models/sale_model.dart';

import 'scaffold/app_scaffold.dart';
import 'shared/brand.dart';
import 'shared/empty_state.dart';
import 'shared/section_header.dart';
import 'package:marcat/core/router/app_router.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final orders = <SaleModel>[];
  bool isLoading = true;
  bool hasMore = true;
  String? filterStatus;
  int _page = 0;

  CartController get _repo => Get.find<CartController>();
  AuthController get _auth => Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    fetchOrders(reset: true);
  }

  Future<void> fetchOrders({bool reset = false}) async {
    final user = _auth.state.value.user;
    if (user == null) {
      if (mounted) setState(() => isLoading = false);
      return;
    }
    if (reset) {
      _page = 0;
      orders.clear();
      hasMore = true;
    }
    if (!hasMore) return;
    if (mounted) setState(() => isLoading = true);
    try {
      final (items, total) = await _repo.fetchOrders(
        page: _page,
        customerId: user.id,
        status: filterStatus,
      );
      if (mounted) {
        setState(() {
          orders.addAll(items);
          _page++;
          hasMore = orders.length < total;
        });
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void setFilter(String? status) {
    setState(() {
      filterStatus = status;
    });
    fetchOrders(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    return CustomerScaffold(
      page: 'My Orders',
      pageImage:
          'https://images.unsplash.com/photo-1601598851547-4302969d0614?w=1600&q=80',
      body: _OrdersBody(
        orders: orders,
        isLoading: isLoading,
        hasMore: hasMore,
        filterStatus: filterStatus,
        onFetchOrders: fetchOrders,
        onSetFilter: setFilter,
      ),
    );
  }
}

class _OrdersBody extends StatelessWidget {
  final List<SaleModel> orders;
  final bool isLoading;
  final bool hasMore;
  final String? filterStatus;
  final Future<void> Function() onFetchOrders;
  final void Function(String?) onSetFilter;

  const _OrdersBody({
    required this.orders,
    required this.isLoading,
    required this.hasMore,
    required this.filterStatus,
    required this.onFetchOrders,
    required this.onSetFilter,
  });

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Obx(() {
      if (auth.state.value.user == null) {
        return EmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'Sign In to View Orders',
          subtitle: 'Track all your MARCAT orders in one place.',
          actionLabel: 'Sign In',
          onAction: () => Get.toNamed(AppRoutes.login),
        );
      }

      return FB5Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                eyebrow: 'Purchase History',
                title: 'My Orders',
                subtitle: 'Track, view, and manage all your orders.',
              ),
              const SizedBox(height: 28),

              // Status filter chips
              _StatusFilterRow(
                filterStatus: filterStatus,
                onSetFilter: onSetFilter,
              ),
              const SizedBox(height: 28),

              // Orders list
              if (isLoading && orders.isEmpty)
                const _OrdersSkeleton()
              else if (orders.isEmpty)
                EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No Orders Yet',
                  subtitle:
                      'You haven\'t placed any orders yet.\nStart shopping to see them here.',
                  actionLabel: 'Shop Now',
                  onAction: () => Get.toNamed(AppRoutes.shop),
                )
              else
                Column(
                  children: [
                    ...orders.map((o) => _OrderCard(order: o)),
                    if (hasMore) ...[
                      const SizedBox(height: 24),
                      Center(
                        child: OutlinedButton(
                          onPressed: onFetchOrders,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kNavy,
                            side: const BorderSide(color: kNavy),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Load More',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      );
    });
  }
}

// â”€â”€â”€ Status filter â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _StatusFilterRow extends StatelessWidget {
  final String? filterStatus;
  final void Function(String?) onSetFilter;

  const _StatusFilterRow({
    required this.filterStatus,
    required this.onSetFilter,
  });

  static const _statuses = [
    (label: 'All', value: null),
    (label: 'Pending', value: 'pending'),
    (label: 'Processing', value: 'processing'),
    (label: 'Shipped', value: 'shipped'),
    (label: 'Delivered', value: 'delivered'),
    (label: 'Cancelled', value: 'cancelled'),
  ];

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _statuses.map((s) {
            final selected = filterStatus == s.value;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onSetFilter(s.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: selected ? kNavy : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: selected ? kNavy : kBorderColor),
                  ),
                  child: Text(
                    s.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : kNavy,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
}

// â”€â”€â”€ Order Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _OrderCard extends StatefulWidget {
  final SaleModel order;
  const _OrderCard({required this.order});

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _expanded = false;

  Color _statusColor(String status) {
    switch (status) {
      case 'delivered':
        return Colors.green;
      case 'shipped':
        return Colors.blue;
      case 'processing':
        return kGold;
      case 'cancelled':
        return kRed;
      default:
        return kSlate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.order.status;
    final statusColor = _statusColor(status.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor),
      ),
      child: Column(
        children: [
          // â”€â”€ Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Order icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: kCream,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.receipt_long_outlined,
                        size: 20, color: kNavy),
                  ),
                  const SizedBox(width: 14),

                  // Order details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.order.referenceNumber,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: kNavy,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _formatDate(widget.order.createdAt),
                          style: const TextStyle(fontSize: 12, color: kSlate),
                        ),
                      ],
                    ),
                  ),

                  // Status + amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.name.capitalizeFirst ?? status.name,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'JOD ${widget.order.grandTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: kNavy,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 20, color: kSlate),
                  ),
                ],
              ),
            ),
          ),

          // â”€â”€ Expanded details â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _OrderDetails(order: widget.order),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'â€”';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

class _OrderDetails extends StatelessWidget {
  final SaleModel order;
  const _OrderDetails({required this.order});

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: kBorderColor)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress tracker
            _OrderProgress(status: order.status.name),
            const SizedBox(height: 24),

            // Pricing breakdown
            _PriceRow('Subtotal', 'JOD ${order.subtotal.toStringAsFixed(2)}'),
            if (order.discountTotal > 0) ...[
              const SizedBox(height: 6),
              _PriceRow(
                  'Discount', '- JOD ${order.discountTotal.toStringAsFixed(2)}',
                  green: true),
            ],
            if (order.shippingCost > 0) ...[
              const SizedBox(height: 6),
              _PriceRow(
                  'Shipping', 'JOD ${order.shippingCost.toStringAsFixed(2)}'),
            ],
            const SizedBox(height: 10),
            const Divider(color: kBorderColor),
            const SizedBox(height: 10),
            _PriceRow('Total', 'JOD ${order.grandTotal.toStringAsFixed(2)}',
                bold: true),

            const SizedBox(height: 20),

            // Actions
            Row(
              children: [
                // Reorder
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.replay_rounded, size: 16),
                    label: const Text('Reorder',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kNavy,
                      side: const BorderSide(color: kNavy),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Return
                if (order.status.name == 'delivered')
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.assignment_return_outlined,
                          size: 16),
                      label: const Text('Return',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kSlate,
                        side: const BorderSide(color: kBorderColor),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
}

class _OrderProgress extends StatelessWidget {
  final String status;
  const _OrderProgress({required this.status});

  static const _stages = [
    'pending',
    'processing',
    'shipped',
    'delivered',
  ];

  @override
  Widget build(BuildContext context) {
    if (status == 'cancelled') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: kRed.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kRed.withOpacity(0.2)),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel_outlined, size: 16, color: kRed),
            SizedBox(width: 10),
            Text('This order was cancelled.',
                style: TextStyle(
                    fontSize: 13, color: kRed, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    final currentIdx = _stages.indexOf(status);

    return Row(
      children: List.generate(_stages.length * 2 - 1, (i) {
        if (i.isOdd) {
          final lineIdx = i ~/ 2;
          final active = lineIdx < currentIdx;
          return Expanded(
            child: Container(
              height: 2,
              color: active ? kNavy : kBorderColor,
            ),
          );
        }
        final stageIdx = i ~/ 2;
        final done = stageIdx < currentIdx;
        final active = stageIdx == currentIdx;
        return Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: done || active ? kNavy : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                    color: done || active ? kNavy : kBorderColor, width: 2),
              ),
              child: done
                  ? const Icon(Icons.check_rounded,
                      size: 12, color: Colors.white)
                  : active
                      ? Container(
                          margin: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
            ),
            const SizedBox(height: 4),
            Text(
              _stages[stageIdx].capitalizeFirst ?? _stages[stageIdx],
              style: TextStyle(
                fontSize: 10,
                fontWeight: active || done ? FontWeight.w700 : FontWeight.w500,
                color: active || done ? kNavy : kSlate,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label, value;
  final bool green, bold;
  const _PriceRow(this.label, this.value,
      {this.green = false, this.bold = false});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: bold ? kNavy : kSlate,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: bold ? 15 : 13,
                  color: green ? Colors.green : kNavy,
                  fontWeight: FontWeight.w700)),
        ],
      );
}

// â”€â”€â”€ Orders Loading Skeleton â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _OrdersSkeleton extends StatelessWidget {
  const _OrdersSkeleton();

  @override
  Widget build(BuildContext context) => Column(
        children: List.generate(
          4,
          (_) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorderColor),
            ),
            child: Row(
              children: [
                Container(
                    width: 44,
                    height: 44,
                    color: kCream,
                    child: const SizedBox()),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 140, height: 14, color: kCream),
                      const SizedBox(height: 8),
                      Container(width: 100, height: 10, color: kCream),
                    ],
                  ),
                ),
                Container(width: 80, height: 32, color: kCream),
              ],
            ),
          ),
        ),
      );
}
