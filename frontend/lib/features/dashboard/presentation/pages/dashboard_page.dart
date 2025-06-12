// frontend/lib/features/dashboard/presentation/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../di/injection.dart';
import '../../../../core/utils/helpers.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/summary_card.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/alerts_section.dart';
import '../widgets/asset_status_pie_chart.dart';
import '../widgets/scan_trend_line_chart.dart';
import '../widgets/recent_activities_section.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DashboardBloc>()..add(const LoadDashboard()),
      child: const DashboardPageView(),
    );
  }
}

class DashboardPageView extends StatelessWidget {
  const DashboardPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Overview'),
        centerTitle: true,
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DashboardLoaded) {
            return _buildDashboardContent(context, state, theme);
          } else if (state is DashboardError) {
            return _buildErrorView(context, state, theme);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    DashboardLoaded state,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          _buildSummaryCards(state, theme),
          const SizedBox(height: 24),

          // Asset Status Pie Chart ใช้ domain entity ตัวจริง
          AssetStatusPieChart(
            assetStatusPie: state.dashboardStats.charts.assetStatusPie,
          ),
          const SizedBox(height: 16),

          // Scan Trend Line Chart
          ScanTrendLineChart(
            scanTrendList: state.dashboardStats.charts.scanTrend7d,
          ),
          const SizedBox(height: 24),

          // Alerts Section
          AlertsSection(alerts: state.alerts),
          const SizedBox(height: 24),

          // Recent Activities Section
          RecentActivitiesSection(recentActivities: state.recentActivities),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(DashboardLoaded state, ThemeData theme) {
    final overview = state.dashboardStats.overview;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SummaryCard(
          icon: Icons.inventory_2_outlined,
          label: 'Total Assets',
          value: overview.totalAssets.toString(),
          valueColor: theme.colorScheme.primary,
        ),
        SummaryCard(
          icon: Icons.check_circle_outline,
          label: 'Active Assets',
          value: overview.activeAssets.toString(),
          valueColor: Colors.green,
        ),
        SummaryCard(
          icon: Icons.cancel_outlined,
          label: 'Inactive Assets',
          value: overview.inactiveAssets.toString(),
          valueColor: Colors.orange,
        ),
        SummaryCard(
          icon: Icons.qr_code_scanner,
          label: 'Today Scans',
          value: overview.todayScans.toString(),
          valueColor: Colors.blue,
        ),
        SummaryCard(
          icon: Icons.file_upload_outlined,
          label: 'Export Success (7d)',
          value: overview.exportSuccess7d.toString(),
          valueColor: Colors.green,
        ),
        SummaryCard(
          icon: Icons.error_outline,
          label: 'Export Failed (7d)',
          value: overview.exportFailed7d.toString(),
          valueColor: Colors.red,
        ),
      ],
    );
  }

  Widget _buildErrorView(
    BuildContext context,
    DashboardError state,
    ThemeData theme,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Failed to load dashboard',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            state.message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<DashboardBloc>().add(
                RetryDashboardLoad(period: state.period),
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
