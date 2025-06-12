// Path: frontend/lib/features/dashboard/presentation/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../di/injection.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/summary_card.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/alerts_section.dart';
import '../widgets/asset_status_pie_chart.dart';
import '../widgets/scan_trend_line_chart.dart';
import '../widgets/period_selector.dart';
import '../widgets/asset_monitoring_section.dart';
import '../widgets/export_tracking_section.dart';

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

class DashboardPageView extends StatefulWidget {
  const DashboardPageView({super.key});

  @override
  State<DashboardPageView> createState() => _DashboardPageViewState();
}

class _DashboardPageViewState extends State<DashboardPageView> {
  String _selectedPeriod = '7d';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard Overview'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _onRefresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is DashboardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: _onRefresh,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (state is DashboardLoaded) {
            return _buildDashboardContent(state);
          }

          if (state is DashboardError) {
            return _buildErrorView(state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDashboardContent(DashboardLoaded state) {
    return RefreshIndicator(
      onRefresh: () async => _onRefresh(),
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with period selector
            _buildHeader(),
            const SizedBox(height: 16),

            // Summary Cards Grid (2x3)
            _buildSummaryGrid(state),
            const SizedBox(height: 24),

            // Asset Status Pie Chart
            DashboardCard(
              title: 'Asset Status Distribution',
              icon: Icons.pie_chart,

              child: AssetStatusPieChart(
                assetStatusPie: state.dashboardStats.charts.assetStatusPie,
              ),
            ),
            const SizedBox(height: 16),

            // Alerts Section
            if (state.alerts.isNotEmpty) ...[
              AlertsSection(alerts: state.alerts),
              const SizedBox(height: 16),
            ],

            // Asset Monitoring Section
            AssetMonitoringSection(
              recentScans: state.recentActivities.recentScans,
            ),
            const SizedBox(height: 16),

            // Scan Trend Chart
            DashboardCard(
              title: 'Scan Activity Trend',
              icon: Icons.trending_up,
              child: ScanTrendLineChart(
                scanTrendList: state.dashboardStats.charts.scanTrend7d,
              ),
            ),
            const SizedBox(height: 16),

            // Export Tracking Section
            ExportTrackingSection(
              recentExports: state.recentActivities.recentExports,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.dashboard, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.onBackground,
              ),
            ),
          ],
        ),
        PeriodSelector(
          selectedPeriod: _selectedPeriod,
          onPeriodChanged: _onPeriodChanged,
        ),
      ],
    );
  }

  Widget _buildSummaryGrid(DashboardLoaded state) {
    final overview = state.dashboardStats.overview;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        SummaryCard(
          icon: Icons.inventory_2_outlined,
          label: 'Total Assets',
          value: overview.totalAssets.toString(),
          color: AppColors.primary,
        ),
        SummaryCard(
          icon: Icons.check_circle_outline,
          label: 'Active Assets',
          value: overview.activeAssets.toString(),
          color: AppColors.assetActive,
        ),
        SummaryCard(
          icon: Icons.cancel_outlined,
          label: 'Inactive Assets',
          value: overview.inactiveAssets.toString(),
          color: AppColors.assetInactive,
        ),
        SummaryCard(
          icon: Icons.qr_code_scanner,
          label: 'Scans Today',
          value: overview.todayScans.toString(),
          color: AppColors.info,
          changePercent: overview.scansChangePercent,
          trend: overview.scansTrend,
        ),
        SummaryCard(
          icon: Icons.file_upload_outlined,
          label: 'Export Success (7d)',
          value: overview.exportSuccess7d.toString(),
          color: AppColors.success,
          changePercent: overview.exportSuccessChangePercent,
          trend: overview.exportSuccessTrend,
        ),
        SummaryCard(
          icon: Icons.error_outline,
          label: 'Export Failed (7d)',
          value: overview.exportFailed7d.toString(),
          color: AppColors.error,
          changePercent: overview.exportFailedChangePercent,
          trend: overview.exportFailedTrend,
        ),
      ],
    );
  }

  Widget _buildErrorView(DashboardError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              state.isNetworkError ? Icons.wifi_off : Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              state.isNetworkError
                  ? 'Network Error'
                  : 'Failed to load dashboard',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPeriodChanged(String newPeriod) {
    setState(() {
      _selectedPeriod = newPeriod;
    });
    context.read<DashboardBloc>().add(ChangePeriod(newPeriod));
  }

  void _onRefresh() {
    context.read<DashboardBloc>().add(
      RefreshDashboard(period: _selectedPeriod),
    );
  }
}
