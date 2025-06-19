// Path: frontend/lib/features/dashboard/presentation/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dashboard_refresh_widget.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../di/injection.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/summary_cards_widget.dart';
import '../widgets/asset_distribution_chart_widget.dart';
import '../widgets/growth_trend_chart_widget.dart';
import '../widgets/audit_progress_widget.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<DashboardBloc>()..add(const LoadInitialDashboard()),
      child: const _DashboardPageContent(),
    );
  }
}

class _DashboardPageContent extends StatelessWidget {
  const _DashboardPageContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              return DashboardRefreshWidget(
                onRefresh: () {
                  if (state is DashboardLoaded) {
                    context.read<DashboardBloc>().add(
                      RefreshDashboard(
                        period: state.currentPeriod,
                        plantCode: state.currentPlantFilter,
                        deptCode: state.currentDeptFilter,
                      ),
                    );
                  } else {
                    context.read<DashboardBloc>().add(
                      const LoadInitialDashboard(),
                    );
                  }
                },
                isLoading:
                    state is DashboardLoading ||
                    state is DashboardPartialLoading,
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is DashboardError) {
            Helpers.showError(context, state.message);
          }
          if (state is DashboardCacheCleared) {
            Helpers.showSuccess(context, state.message);
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardBloc>().add(const RefreshDashboard());
            },
            child: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, DashboardState state) {
    if (state is DashboardInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is DashboardLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              state.loadingMessage ?? 'Loading dashboard...',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (state is DashboardError && state.previousState == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<DashboardBloc>().add(const LoadInitialDashboard());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is DashboardLoaded ||
        state is DashboardPartialLoading ||
        (state is DashboardError && state.previousState != null)) {
      final loadedState = state is DashboardLoaded
          ? state
          : state is DashboardPartialLoading
          ? state.currentState
          : (state as DashboardError).previousState!;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and filters
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overview',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // DashboardFiltersWidget(
                //   currentPeriod: loadedState.currentPeriod,
                //   currentPlantFilter: loadedState.currentPlantFilter,
                //   currentDeptFilter: loadedState.currentDeptFilter,
                //   onPeriodChanged: (period) {
                //     context.read<DashboardBloc>().add(
                //       ChangePeriodFilter(period),
                //     );
                //   },
                //   onPlantChanged: (plantCode) {
                //     context.read<DashboardBloc>().add(
                //       ChangePlantFilter(plantCode),
                //     );
                //   },
                //   onDeptChanged: (deptCode) {
                //     context.read<DashboardBloc>().add(
                //       ChangeDepartmentFilter(deptCode),
                //     );
                //   },
                //   onResetFilters: () {
                //     context.read<DashboardBloc>().add(const ResetFilters());
                //   },
                // ),
              ],
            ),

            const SizedBox(height: 16),

            // Summary Cards
            if (loadedState.stats != null)
              SummaryCardsWidget(
                stats: loadedState.stats!,
                isLoading:
                    state is DashboardPartialLoading &&
                    state.loadingType == 'stats',
              ),

            const SizedBox(height: 24),

            // Asset Distribution Chart
            if (loadedState.distribution != null)
              AssetDistributionChartWidget(
                distribution: loadedState.distribution!,
                isLoading:
                    state is DashboardPartialLoading &&
                    state.loadingType == 'distribution',
              ),

            const SizedBox(height: 24),

            // Growth Trend Chart
            if (loadedState.growthTrend != null)
              GrowthTrendChartWidget(
                growthTrend: loadedState.growthTrend!,
                isLoading:
                    state is DashboardPartialLoading &&
                    state.loadingType == 'trends',
              ),

            const SizedBox(height: 24),

            // Audit Progress
            if (loadedState.auditProgress != null)
              AuditProgressWidget(
                auditProgress: loadedState.auditProgress!,
                includeDetails: loadedState.includeDetails,
                isLoading:
                    state is DashboardPartialLoading &&
                    state.loadingType == 'audit',
                onToggleDetails: (includeDetails) {
                  context.read<DashboardBloc>().add(
                    ToggleDetailsView(includeDetails),
                  );
                },
              ),

            const SizedBox(height: 16),

            // Last Updated Info
            _buildLastUpdatedInfo(loadedState),

            const SizedBox(height: 32),
          ],
        ),
      );
    }

    // Empty state when no data loaded
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.dashboard_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No dashboard data available',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<DashboardBloc>().add(const LoadInitialDashboard());
            },
            child: const Text('Load Dashboard'),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdatedInfo(DashboardLoaded state) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            'Last updated: ${Helpers.formatDateTime(state.lastUpdated)}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const Spacer(),
          if (state.hasActiveFilters) ...[
            Icon(Icons.filter_alt, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              'Filtered',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (state.isDataRecent) ...[
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'Fresh',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
