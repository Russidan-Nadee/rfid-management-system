// Path: frontend/lib/features/dashboard/presentation/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_decorations.dart';
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

    if (state == AppLifecycleState.resumed) {
      context.read<DashboardBloc>().add(const RefreshDashboard());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

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
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
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
                lastRefresh: state is DashboardLoaded
                    ? state.lastUpdated
                    : null,
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
            color: AppColors.primary,
            backgroundColor: theme.colorScheme.surface,
            child: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, DashboardState state) {
    final theme = Theme.of(context);

    if (state is DashboardInitial) {
      return _buildLoadingState(context, 'Initializing dashboard...');
    }

    if (state is DashboardLoading) {
      return _buildLoadingState(
        context,
        state.loadingMessage ?? 'Loading dashboard...',
      );
    }

    if (state is DashboardError && state.previousState == null) {
      return _buildErrorState(context, state.message);
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
            AppSpacing.verticalSpaceXL,

            // Summary Cards
            if (loadedState.stats != null)
              SummaryCardsWidget(
                stats: loadedState.stats!,
                isLoading:
                    state is DashboardPartialLoading &&
                    state.loadingType == 'stats',
              ),
            AppSpacing.verticalSpaceXL,

            // Audit Progress
            if (loadedState.auditProgress != null)
              AuditProgressWidget(
                key: ValueKey(
                  'audit_progress_widget_${loadedState.auditProgressDeptFilter}',
                ),
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
            AppSpacing.verticalSpaceXXL,

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

            AppSpacing.verticalSpaceXXL,

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

            AppSpacing.verticalSpaceXXL,

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

            AppSpacing.verticalSpaceXXL,

            // Last Updated Info
            _buildLastUpdatedInfo(loadedState),

            AppSpacing.verticalSpaceXXL,
          ],
        ),
      );
    }

    return _buildEmptyState(context);
  }

  Widget _buildLoadingState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
          AppSpacing.verticalSpaceXL,
          Text(
            message,
            style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: AppSpacing.paddingXXL,
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: AppBorders.circular,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
            ),
            AppSpacing.verticalSpaceXL,
            Text(
              'Dashboard Error',
              style: AppTextStyles.headline5.copyWith(
                color: theme.brightness == Brightness.dark
                    ? AppColors.onBackground
                    : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.verticalSpaceSM,
            Container(
              padding: AppSpacing.paddingMD,
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: AppBorders.md,
                border: Border.all(color: AppColors.error.withOpacity(0.2)),
              ),
              child: Text(
                message,
                style: AppTextStyles.body2.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ),
            AppSpacing.verticalSpaceXL,
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<DashboardBloc>().add(
                    const LoadInitialDashboard(),
                  );
                },
                icon: Icon(Icons.refresh, color: AppColors.onPrimary),
                label: Text(
                  'Retry',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: AppSpacing.buttonPaddingSymmetric,
                  shape: RoundedRectangleBorder(borderRadius: AppBorders.md),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: AppSpacing.paddingXXL,
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: AppBorders.circular,
              ),
              child: Icon(
                Icons.dashboard_outlined,
                size: 64,
                color: AppColors.textMuted,
              ),
            ),
            AppSpacing.verticalSpaceXL,
            Text(
              'No Dashboard Data',
              style: AppTextStyles.headline5.copyWith(
                color: theme.brightness == Brightness.dark
                    ? AppColors.onBackground
                    : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.verticalSpaceSM,
            Text(
              'Dashboard data is not available at the moment',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSpaceXL,
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<DashboardBloc>().add(
                    const LoadInitialDashboard(),
                  );
                },
                icon: Icon(Icons.dashboard, color: AppColors.onPrimary),
                label: Text(
                  'Load Dashboard',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: AppSpacing.buttonPaddingSymmetric,
                  shape: RoundedRectangleBorder(borderRadius: AppBorders.md),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _getAllDepartments(DashboardLoaded state) {
    final Set<String> allDeptCodes = {};
    final Map<String, String> deptMap = {};

    if (state.auditProgress != null) {
      for (final dept in state.auditProgress!.auditProgress) {
        allDeptCodes.add(dept.deptCode);
        deptMap[dept.deptCode] = dept.deptDescription;
      }
    }

    if (state.departmentGrowthTrend != null) {
      for (final trend in state.departmentGrowthTrend!.trends) {
        if (trend.deptCode.isNotEmpty) {
          allDeptCodes.add(trend.deptCode);
          deptMap[trend.deptCode] = trend.deptDescription;
        }
      }
    }

    if (state.distribution != null) {
      for (final item in state.distribution!.pieChartData) {
        if (item.deptCode.isNotEmpty) {
          allDeptCodes.add(item.deptCode);
          deptMap[item.deptCode] = item.name;
        }
      }
    }

    final List<Map<String, String>> departments = allDeptCodes
        .map((code) => {'code': code, 'name': deptMap[code] ?? code})
        .toList();

    departments.sort((a, b) => a['name']!.compareTo(b['name']!));
    return departments;
  }

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
      padding: AppSpacing.paddingLG,
      decoration: AppDecorations.card.copyWith(
        color: AppColors.backgroundSecondary,
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
          AppSpacing.horizontalSpaceSM,
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
            AppSpacing.horizontalSpaceSM,
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
            ),
            AppSpacing.horizontalSpaceXS,
            Text(
              'Fresh',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
