// Path: frontend/lib/features/dashboard/presentation/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../di/injection.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/summary_cards_widget.dart';
import '../widgets/asset_distribution_chart_widget.dart';
import '../widgets/growth_trend_chart_widget.dart';
import '../widgets/location_growth_trend_widget.dart';
import '../widgets/audit_progress_widget.dart';
import '../widgets/dashboard_refresh_widget.dart';

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

class _DashboardPageContent extends StatefulWidget {
  const _DashboardPageContent();

  @override
  State<_DashboardPageContent> createState() => _DashboardPageContentState();
}

class _DashboardPageContentState extends State<_DashboardPageContent>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Refresh เมื่อกลับมาที่ tab Dashboard
    if (state == AppLifecycleState.resumed) {
      context.read<DashboardBloc>().add(const RefreshDashboard());
    }
  }

  // Refresh เมื่อ Widget ถูกสร้างใหม่ (เปลี่ยน tab)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Refresh ทุกครั้งที่กลับมาที่ Dashboard tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DashboardBloc>().add(const RefreshDashboard());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: AppTextStyles.dashboardTitle,
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
                lastRefresh: state is DashboardLoaded ? state.lastUpdated : null,
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
            AppSpacing.verticalSpaceMedium,
            Text(
              state.loadingMessage ?? 'Loading dashboard...',
              style: AppTextStyles.body1,
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
            AppSpacing.verticalSpaceMedium,
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body1,
            ),
            AppSpacing.verticalSpaceMedium,
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
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and filters
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overview',
                  style: AppTextStyles.headline4.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            AppSpacing.verticalSpaceMedium,

            // Summary Cards
            if (loadedState.stats != null)
              SummaryCardsWidget(
                stats: loadedState.stats!,
                isLoading:
                    state is DashboardPartialLoading &&
                    state.loadingType == 'stats',
              ),
            AppSpacing.verticalSpaceMedium,

            // Audit Progress
            if (loadedState.auditProgress != null)
              AuditProgressWidget(
                key: ValueKey('audit_${DateTime.now().millisecondsSinceEpoch}'),
                auditProgress: loadedState.auditProgress!,
                includeDetails: loadedState.includeDetails,
                selectedDeptCode: loadedState.auditProgressDeptFilter,
                availableDepartments: _getAllDepartments(loadedState),
                onDeptChanged: (deptCode) {
                  context.read<DashboardBloc>().add(
                    LoadAuditProgress(deptCode: deptCode),
                  );
                },
                isLoading:
                    state is DashboardPartialLoading &&
                    state.loadingType == 'audit',
                onToggleDetails: (includeDetails) {
                  context.read<DashboardBloc>().add(
                    ToggleDetailsView(includeDetails),
                  );
                },
              ),

            AppSpacing.verticalSpaceLarge,

            // Asset Distribution Chart
            if (loadedState.distribution != null)
              AssetDistributionChartWidget(
                key: ValueKey(
                  'distribution_${DateTime.now().millisecondsSinceEpoch}',
                ),
                distribution: loadedState.distribution!,
                isLoading:
                    state is DashboardPartialLoading &&
                    state.loadingType == 'distribution',
              ),

            AppSpacing.verticalSpaceLarge,

            // Department Growth Trend Chart
            if (loadedState.departmentGrowthTrend != null)
              GrowthTrendChartWidget(
                key: ValueKey(
                  'dept_growth_${DateTime.now().millisecondsSinceEpoch}',
                ),
                growthTrend: loadedState.departmentGrowthTrend!,
                selectedDeptCode: loadedState.departmentGrowthDeptFilter,
                availableDepartments: _getAllDepartments(loadedState),
                onDeptChanged: (deptCode) {
                  context.read<DashboardBloc>().add(
                    LoadDepartmentGrowthTrends(deptCode: deptCode),
                  );
                },
                isLoading:
                    state is DashboardPartialLoading &&
                    state.loadingType == 'department_trends',
              ),

            AppSpacing.verticalSpaceLarge,

            if (loadedState.locationGrowthTrend != null)
              LocationGrowthTrendWidget(
                key: ValueKey(
                  'location_${DateTime.now().millisecondsSinceEpoch}',
                ),
                growthTrend: loadedState.locationGrowthTrend!,
                selectedLocationCode: loadedState.locationGrowthLocationFilter,
                availableLocations: _getAllLocations(loadedState),
                onLocationChanged: (locationCode) {
                  context.read<DashboardBloc>().add(
                    LoadLocationGrowthTrends(locationCode: locationCode),
                  );
                },
                isLoading:
                    state is DashboardPartialLoading &&
                    state.loadingType == 'location_trends',
              ),

            AppSpacing.verticalSpaceLarge,

            // Last Updated Info
            _buildLastUpdatedInfo(loadedState),

            AppSpacing.verticalSpaceXXL,
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
          AppSpacing.verticalSpaceMedium,
          Text(
            'No dashboard data available',
            style: AppTextStyles.body1,
          ),
          AppSpacing.verticalSpaceMedium,
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

  // Helper method เพื่อรวม Department จากทุกแหล่ง
  List<Map<String, String>> _getAllDepartments(DashboardLoaded state) {
    final Set<String> allDeptCodes = {};
    final Map<String, String> deptMap = {};

    // รวม Department จาก Audit Progress
    if (state.auditProgress != null) {
      for (final dept in state.auditProgress!.auditProgress) {
        allDeptCodes.add(dept.deptCode);
        deptMap[dept.deptCode] = dept.deptDescription;
      }
    }

    // รวม Department จาก Department Growth Trend
    if (state.departmentGrowthTrend != null) {
      for (final trend in state.departmentGrowthTrend!.trends) {
        if (trend.deptCode.isNotEmpty) {
          allDeptCodes.add(trend.deptCode);
          deptMap[trend.deptCode] = trend.deptDescription;
        }
      }
    }

    // รวม Department จาก Asset Distribution
    if (state.distribution != null) {
      for (final item in state.distribution!.pieChartData) {
        if (item.deptCode.isNotEmpty) {
          allDeptCodes.add(item.deptCode);
          deptMap[item.deptCode] = item.name;
        }
      }
    }

    // Convert เป็น List และเรียงตามชื่อ
    final List<Map<String, String>> departments = allDeptCodes
        .map((code) => {'code': code, 'name': deptMap[code] ?? code})
        .toList();

    // เรียงตามชื่อ Department
    departments.sort((a, b) => a['name']!.compareTo(b['name']!));

    return departments;
  }

  // Helper method เพื่อรวม Location จากทุกแหล่ง
  List<Map<String, String>> _getAllLocations(DashboardLoaded state) {
    final Set<String> allLocationCodes = {};
    final Map<String, String> locationMap = {};

    if (state.locationAnalytics != null) {
      for (final trend in state.locationAnalytics!.locationTrends) {
        allLocationCodes.add(trend.locationCode);
        locationMap[trend.locationCode] = trend.locationDescription;
      }
    }

    final List<Map<String, String>> locations = allLocationCodes
        .map((code) => {'code': code, 'name': locationMap[code] ?? code})
        .toList();

    locations.sort((a, b) => a['name']!.compareTo(b['name']!));
    return locations;
  }

  Widget _buildLastUpdatedInfo(DashboardLoaded state) {
    return Container(
      padding: AppSpacing.paddingMedium,
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
          AppSpacing.horizontalSpaceSmall,
          Text(
            'Last updated: ${Helpers.formatDateTime(state.lastUpdated)}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          if (state.hasActiveFilters) ...[
            Icon(Icons.filter_alt, size: 16, color: AppColors.primary),
            AppSpacing.horizontalSpaceXS,
            Text(
              'Filtered',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (state.isDataRecent) ...[
            AppSpacing.horizontalSpaceSmall,
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            AppSpacing.horizontalSpaceXS,
            Text(
              'Fresh',
              style: AppTextStyles.caption.copyWith(
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