// lib/views/admin/dashboard/dashboard_screen.dart
//
// Admin dashboard — the first tab in AdminAppScaffold.
//
// Displays 4 KPI stat cards (fetched from controllers), a recent-orders
// table, and a 7-day sales bar chart powered by fl_chart.
//
// ✅ REFACTORED: uses brand.dart color aliases consistent with customer side.
// ✅ REFACTORED: error state shows retry button via AdminErrorRetry.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/currency_extensions.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../models/enums.dart';
import '../../../models/sale_model.dart';
import '../shared/admin_widgets.dart';
import '../shared/brand.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdminDashboardScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Main analytics overview screen for admin and store-manager roles.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // ── Fetched state ─────────────────────────────────────────────────────────
  bool _isLoading = true;
  String? _error;

  // KPIs
  double _todayRevenue = 0;
  int _pendingOrders = 0;
  int _totalProducts = 0;
  int _totalOrders = 0;

  // Recent orders (last 5)
  List<SaleModel> _recentOrders = [];

  // 7-day sales data for bar chart  [day-index → revenue]
  final List<double> _weeklyRevenue = List.filled(7, 0);

  // ── Controllers ───────────────────────────────────────────────────────────
  CartController get _cartCtrl => Get.find<CartController>();
  ProductController get _productCtrl => Get.find<ProductController>();
  AuthController get _authCtrl => Get.find<AuthController>();

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final weekStart = todayStart.subtract(const Duration(days: 6));

      final results = await Future.wait([
        _cartCtrl.fetchOrders(
          fromDate: todayStart,
          toDate: now,
          updateState: false,
        ),
        _cartCtrl.fetchOrders(
          status: SaleStatus.pending.dbValue,
          updateState: false,
        ),
        _productCtrl.fetchProducts(
          page: 0,
          pageSize: 1,
          updateState: false,
        ),
        _cartCtrl.fetchOrders(
          page: 0,
          pageSize: 5,
          updateState: false,
        ),
        _cartCtrl.fetchOrders(
          fromDate: weekStart,
          toDate: now,
          pageSize: 200,
          updateState: false,
        ),
      ]);

      if (!mounted) return;

      final (todayOrders, _) = results[0] as (List<SaleModel>, int);
      final (_, pendingCount) = results[1] as (List<SaleModel>, int);
      final (_, productCount) = results[2] as (List<SaleModel>, int);
      final (recentList, totalCount) = results[3] as (List<SaleModel>, int);
      final (weekOrders, _) = results[4] as (List<SaleModel>, int);

      final todayRev = todayOrders.fold<double>(
        0,
        (sum, o) => sum + o.grandTotal,
      );

      final weekly = List.filled(7, 0.0);
      for (final o in weekOrders) {
        final diff = o.createdAt.toLocal().difference(weekStart).inDays;
        if (diff >= 0 && diff < 7) {
          weekly[diff] = weekly[diff] + o.grandTotal;
        }
      }

      setState(() {
        _todayRevenue = todayRev;
        _pendingOrders = pendingCount;
        _totalProducts = productCount;
        _totalOrders = totalCount;
        _recentOrders = recentList;
        _weeklyRevenue.setAll(0, weekly);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: Show error retry instead of silently failing
    if (_error != null && !_isLoading) {
      return Scaffold(
        backgroundColor: kSurface,
        body: AdminErrorRetry(
          message: _error!,
          onRetry: _loadDashboard,
        ),
      );
    }

    return Scaffold(
      backgroundColor: kSurface,
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        color: kGold,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
          children: [
            // ── Greeting ──────────────────────────────────────────────────
            Obx(() {
              final user = _authCtrl.state.value.user;
              return Text(
                'Welcome back, ${user?.firstName ?? 'Admin'}',
                style: AppTextStyles.headlineMedium,
              );
            }),
            const SizedBox(height: AppDimensions.space4),
            Text(
              DateTime.now().shortDate(),
              style: AppTextStyles.bodySmall.copyWith(color: kTextSecondary),
            ),

            const SizedBox(height: AppDimensions.space24),

            // ── KPI Stats grid ────────────────────────────────────────────
            const AdminSectionHeader(eyebrow: 'Today', title: 'Key Metrics'),
            const SizedBox(height: AppDimensions.space16),
            _buildStatsGrid(context),

            const SizedBox(height: AppDimensions.space32),

            // ── Weekly sales chart ────────────────────────────────────────
            const AdminSectionHeader(eyebrow: 'Revenue', title: '7-Day Sales'),
            const SizedBox(height: AppDimensions.space16),
            _WeeklySalesChart(
              data: _weeklyRevenue,
              isLoading: _isLoading,
            ),

            const SizedBox(height: AppDimensions.space32),

            // ── Recent orders ─────────────────────────────────────────────
            AdminSectionHeader(
              eyebrow: 'Activity',
              title: 'Recent Orders',
              trailing: TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ),
            const SizedBox(height: AppDimensions.space16),
            _buildRecentOrders(),

            const SizedBox(height: AppDimensions.space64),
          ],
        ),
      ),
    );
  }

  // ── Stats Grid ────────────────────────────────────────────────────────────

  Widget _buildStatsGrid(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final cols = constraints.maxWidth > 800
          ? 4
          : constraints.maxWidth > 500
              ? 2
              : 1;

      if (_isLoading) return AdminStatSkeleton(crossAxisCount: cols);

      return GridView.count(
        crossAxisCount: cols,
        crossAxisSpacing: AppDimensions.space16,
        mainAxisSpacing: AppDimensions.space16,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 2.5,
        children: [
          AdminStatCard(
            title: "Today's Revenue",
            value: _todayRevenue.toJOD(),
            icon: Icons.attach_money_rounded,
            color: kGreen,
          ),
          AdminStatCard(
            title: 'Pending Orders',
            value: '$_pendingOrders',
            icon: Icons.pending_actions_rounded,
            color: kAmber,
          ),
          AdminStatCard(
            title: 'Total Products',
            value: '$_totalProducts',
            icon: Icons.inventory_2_rounded,
            color: kBlue,
          ),
          AdminStatCard(
            title: 'Total Orders',
            value: '$_totalOrders',
            icon: Icons.receipt_long_rounded,
            color: kGold,
          ),
        ],
      );
    });
  }

  // ── Recent Orders list ────────────────────────────────────────────────────

  Widget _buildRecentOrders() {
    if (_isLoading) return const AdminListSkeleton(itemCount: 5);

    if (_recentOrders.isEmpty) {
      return const AdminEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No Orders Yet',
        subtitle: 'New orders will appear here.',
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: _recentOrders.asMap().entries.map((entry) {
          final isLast = entry.key == _recentOrders.length - 1;
          return _RecentOrderRow(
            order: entry.value,
            showDivider: !isLast,
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _WeeklySalesChart
// ─────────────────────────────────────────────────────────────────────────────

class _WeeklySalesChart extends StatelessWidget {
  const _WeeklySalesChart({
    required this.data,
    required this.isLoading,
  });

  final List<double> data;
  final bool isLoading;

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.space16,
        AppDimensions.space16,
        AppDimensions.space16,
        AppDimensions.space8,
      ),
      decoration: BoxDecoration(
        color: kSurfaceWhite,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        border: Border.all(color: kBorder),
      ),
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: kGold,
                strokeWidth: 2,
              ),
            )
          : BarChart(
              BarChartData(
                maxY: data.reduce((a, b) => a > b ? a : b) * 1.3,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        rod.toY.toJOD(),
                        AppTextStyles.labelSmall.copyWith(color: kTextOnDark),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            i >= 0 && i < _dayLabels.length
                                ? _dayLabels[i]
                                : '',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: kTextSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: data.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        color: kGold,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _RecentOrderRow
// ─────────────────────────────────────────────────────────────────────────────

class _RecentOrderRow extends StatelessWidget {
  const _RecentOrderRow({
    required this.order,
    this.showDivider = true,
  });

  final SaleModel order;
  final bool showDivider;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          ListTile(
            onTap: () => Get.toNamed(AppRoutes.adminOrderOf(order.id)),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: kGold.withAlpha(26),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Icon(
                order.channel == SaleChannel.online
                    ? Icons.language_rounded
                    : Icons.storefront_rounded,
                size: AppDimensions.iconM,
                color: kGold,
              ),
            ),
            title: Text(
              order.referenceNumber,
              style: AppTextStyles.titleSmall,
            ),
            subtitle: Text(
              order.createdAt.relativeTime(),
              style: AppTextStyles.bodySmall.copyWith(
                color: kTextSecondary,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  order.grandTotal.toJOD(),
                  style: AppTextStyles.priceSmall,
                ),
                const SizedBox(height: 2),
                SaleStatusBadge(status: order.status),
              ],
            ),
          ),
          if (showDivider)
            const Divider(
              height: 1,
              indent: 72,
              color: kBorder,
            ),
        ],
      );
}
