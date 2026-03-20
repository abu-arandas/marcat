// lib/views/admin/dashboard/dashboard_screen.dart
//
// Admin dashboard — the first tab in AdminAppScaffold.
//
// Displays 4 KPI stat cards (fetched from controllers), a recent-orders
// table, and a 7-day sales bar chart powered by fl_chart.
//
// State is managed locally with setState() since this screen is an
// independent tab inside an IndexedStack — no GetX Obx nesting needed
// for the fetch lifecycle; controller observables are used for the
// user-avatar header only.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/currency_extensions.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../models/enums.dart';
import '../../../models/sale_model.dart';
import '../shared/admin_widgets.dart';

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
      // Fetch in parallel to minimise wait time.
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final weekStart = todayStart.subtract(const Duration(days: 6));

      final results = await Future.wait([
        // [0] Today's orders → revenue
        _cartCtrl.fetchOrders(
          fromDate: todayStart,
          toDate: now,
          updateState: false,
        ),
        // [1] Pending orders count
        _cartCtrl.fetchOrders(
          status: SaleStatus.pending.dbValue,
          updateState: false,
        ),
        // [2] All products (for total count)
        _productCtrl.fetchProducts(
          page: 0,
          pageSize: 1,
          updateState: false,
        ),
        // [3] Last 5 orders (recent list)
        _cartCtrl.fetchOrders(
          page: 0,
          pageSize: 5,
          updateState: false,
        ),
        // [4] Last 7 days orders (for chart)
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

      // Compute today's revenue
      final todayRev = todayOrders.fold<double>(
        0,
        (sum, o) => sum + o.grandTotal,
      );

      // Compute 7-day chart data
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
    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        color: AppColors.marcatGold,
        child: _buildBody(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Dashboard'),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded),
          tooltip: 'Notifications',
          onPressed: () {},
        ),
        const SizedBox(width: AppDimensions.space4),
        // User avatar — reactive to auth state
        Obx(() {
          final user = _authCtrl.state.value.user;
          return Padding(
            padding: const EdgeInsets.only(right: AppDimensions.space16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.borderMedium,
              backgroundImage: user?.avatarUrl != null
                  ? NetworkImage(user!.avatarUrl!)
                  : null,
              child: user?.avatarUrl == null
                  ? Text(
                      user?.firstName.substring(0, 1).toUpperCase() ?? 'A',
                      style: AppTextStyles.labelMedium,
                    )
                  : null,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_error != null) {
      return AdminErrorRetry(
        message: _error!,
        onRetry: _loadDashboard,
      );
    }

    return SingleChildScrollView(
      // Always-scrollable so RefreshIndicator works even on short content.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Greeting ────────────────────────────────────────────────────
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
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary),
          ),

          const SizedBox(height: AppDimensions.space24),

          // ── KPI Stats grid ───────────────────────────────────────────────
          const AdminSectionHeader(eyebrow: 'Today', title: 'Key Metrics'),
          const SizedBox(height: AppDimensions.space16),
          _buildStatsGrid(context),

          const SizedBox(height: AppDimensions.space32),

          // ── Weekly sales chart ────────────────────────────────────────────
          const AdminSectionHeader(eyebrow: 'Revenue', title: '7-Day Sales'),
          const SizedBox(height: AppDimensions.space16),
          _WeeklySalesChart(
            data: _weeklyRevenue,
            isLoading: _isLoading,
          ),

          const SizedBox(height: AppDimensions.space32),

          // ── Recent orders ─────────────────────────────────────────────────
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

          // Bottom padding for safe area
          const SizedBox(height: AppDimensions.space64),
        ],
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
            color: AppColors.statusGreen,
          ),
          AdminStatCard(
            title: 'Pending Orders',
            value: '$_pendingOrders',
            icon: Icons.pending_actions_rounded,
            color: AppColors.statusAmber,
          ),
          AdminStatCard(
            title: 'Total Products',
            value: '$_totalProducts',
            icon: Icons.inventory_2_rounded,
            color: AppColors.statusBlue,
          ),
          AdminStatCard(
            title: 'Total Orders',
            value: '$_totalOrders',
            icon: Icons.receipt_long_rounded,
            color: AppColors.marcatGold,
          ),
        ],
      );
    });
  }

  // ── Recent Orders list ────────────────────────────────────────────────────

  Widget _buildRecentOrders() {
    if (_isLoading) {
      return const AdminListSkeleton(itemCount: 5);
    }

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

/// 7-day bar chart rendered with fl_chart.
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
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.marcatGold,
                strokeWidth: 2,
              ),
            )
          : BarChart(
              BarChartData(
                maxY: data.reduce((a, b) => a > b ? a : b) * 1.3 + 1,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                        BarTooltipItem(
                      rod.toY.toJOD(),
                      AppTextStyles.labelSmall.copyWith(
                        color: AppColors.marcatGold,
                      ),
                    ),
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= _dayLabels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding:
                              const EdgeInsets.only(top: AppDimensions.space4),
                          child: Text(
                            _dayLabels[idx],
                            style: AppTextStyles.labelSmall
                                .copyWith(color: AppColors.textDisabled),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 50,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: AppColors.borderLight,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: data.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        color: AppColors.marcatGold,
                        width: 16,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(AppDimensions.radiusXS),
                          topRight: Radius.circular(AppDimensions.radiusXS),
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space16,
            vertical: AppDimensions.space4,
          ),
          title: Text(
            order.referenceNumber,
            style: AppTextStyles.titleSmall,
          ),
          subtitle: Text(
            order.createdAt.toDeviceShortDate(),
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                order.grandTotal.toJOD(),
                style: AppTextStyles.titleSmall,
              ),
              const SizedBox(width: AppDimensions.space8),
              SaleStatusBadge(status: order.status),
            ],
          ),
          onTap: () => Get.toNamed(AppRoutes.adminOrderOf(order.id)),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            indent: AppDimensions.space16,
            color: AppColors.borderLight,
          ),
      ],
    );
  }
}
