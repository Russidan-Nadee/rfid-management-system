// Path: frontend/lib/features/dashboard/presentation/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/app/app_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../di/injection.dart';
import '../../../../l10n/features/dashboard/dashboard_localizations.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/summary_cards_widget.dart';
import '../widgets/summary_section_widget.dart';
import '../widgets/asset_distribution_chart_widget.dart';
import '../widgets/department_growth_trend_widget.dart';
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
  DepartmentChartType _departmentChartType = DepartmentChartType.bar;
  GrowthChartType _locationChartType = GrowthChartType.bar;
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
    final isDark = theme.brightness == Brightness.dark;
    final l10n = DashboardLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkSurface.withValues(alpha: 0.5)
          : theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.pageTitle,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: isDark
                ? theme.colorScheme.onSurface
                : theme.colorScheme.primary,
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
            color: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.surface,
            child: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, DashboardState state) {
    final l10n = DashboardLocalizations.of(context);

    if (state is DashboardInitial) {
      return _buildLoadingState(context, l10n.initializing);
    }

    if (state is DashboardLoading) {
      return _buildLoadingState(
        context,
        state.loadingMessage ?? l10n.loadingDashboard,
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

      return _buildDashboardContent(context, loadedState, state);
    }

    return _buildEmptyState(context);
  }

  Widget _buildDashboardContent(
    BuildContext context,
    DashboardLoaded loadedState,
    DashboardState currentState,
  ) {
    final isDesktop =
        MediaQuery.of(context).size.width >= AppConstants.tabletBreakpoint;

    return SingleChildScrollView(
      padding: AppSpacing.screenPaddingAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacing.verticalSpaceXL,

          if (isDesktop)
            _buildDesktopLayout(context, loadedState, currentState)
          else
            _buildMobileLayout(context, loadedState, currentState),

          AppSpacing.verticalSpaceXXL,
          _buildLastUpdatedInfo(loadedState),
          AppSpacing.verticalSpaceXXL,
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    DashboardLoaded loadedState,
    DashboardState currentState,
  ) {
    return Column(
      children: [
        // Top Row Grid
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Column (Summary Cards)
              Expanded(
                flex: 1, 
                child: SummarySectionWidget(stats: loadedState.stats),
              ),
              AppSpacing.horizontalSpaceMedium,

              // Middle Column (Audit Progress)
              Expanded(
                flex: 2,
                child: _buildAuditProgressSection(loadedState, currentState),
              ),
              AppSpacing.horizontalSpaceMedium,

              // Right Column (Asset Distribution)
              Expanded(
                flex: 2,
                child: _buildDistributionSection(loadedState, currentState),
              ),
            ],
          ),
        ),

        AppSpacing.verticalSpaceXXL,

        // Bottom Row Grid (Growth Charts)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Location Growth
              Expanded(
                child: _buildLocationGrowthSection(loadedState, currentState),
              ),
              AppSpacing.horizontalSpaceMedium,

              // Department Growth
              Expanded(
                child: _buildDepartmentGrowthSection(loadedState, currentState),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    DashboardLoaded loadedState,
    DashboardState currentState,
  ) {
    return Column(
      children: [
        // Summary Cards
        if (loadedState.stats != null)
          SummaryCardsWidget(
            stats: loadedState.stats!,
            isLoading:
                currentState is DashboardPartialLoading &&
                currentState.loadingType == 'stats',
          ),
        AppSpacing.verticalSpaceXL,

        // Audit Progress
        _buildAuditProgressSection(loadedState, currentState),
        AppSpacing.verticalSpaceXXL,

        // Asset Distribution Chart
        _buildDistributionSection(loadedState, currentState),
        AppSpacing.verticalSpaceXXL,

        // Department Growth Trend Chart
        _buildDepartmentGrowthSection(loadedState, currentState),
        AppSpacing.verticalSpaceXXL,

        // Location Growth Trend Chart
        _buildLocationGrowthSection(loadedState, currentState),
      ],
    );
  }


  Widget _buildAuditProgressSection(
    DashboardLoaded loadedState,
    DashboardState currentState,
  ) {
    final l10n = DashboardLocalizations.of(context);

    if (loadedState.auditProgress != null) {
      return AuditProgressWidget(
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
            currentState is DashboardPartialLoading &&
            currentState.loadingType == 'audit',
        onToggleDetails: (includeDetails) {
          context.read<DashboardBloc>().add(ToggleDetailsView(includeDetails));
        },
      );
    }

    return _buildEmptyCard(l10n.noAuditData);
  }

  Widget _buildDistributionSection(
    DashboardLoaded loadedState,
    DashboardState currentState,
  ) {
    final l10n = DashboardLocalizations.of(context);

    if (loadedState.distribution != null) {
      return AssetDistributionChartWidget(
        key: ValueKey('distribution_${DateTime.now().millisecondsSinceEpoch}'),
        distribution: loadedState.distribution!,
        isLoading:
            currentState is DashboardPartialLoading &&
            currentState.loadingType == 'distribution',
      );
    }

    return _buildEmptyCard(l10n.noDistributionData);
  }

  Widget _buildDepartmentGrowthSection(
    DashboardLoaded loadedState,
    DashboardState currentState,
  ) {
    final l10n = DashboardLocalizations.of(context);

    if (loadedState.departmentGrowthTrend != null) {
      return GrowthTrendChartWidget(
        key: ValueKey('dept_growth_${loadedState.departmentGrowthDeptFilter}'),
        growthTrend: loadedState.departmentGrowthTrend!,
        selectedDeptCode: loadedState.departmentGrowthDeptFilter,
        availableDepartments: _getAllDepartments(loadedState),
        chartType: _departmentChartType,
        onDeptChanged: (deptCode) {
          context.read<DashboardBloc>().add(
            LoadDepartmentGrowthTrends(deptCode: deptCode),
          );
        },
        onChartTypeChanged: (chartType) {
          setState(() {
            _departmentChartType = chartType;
          });
        },
        isLoading:
            currentState is DashboardPartialLoading &&
            currentState.loadingType == 'department_trends',
      );
    }

    return _buildEmptyCard(l10n.noDepartmentData);
  }

  Widget _buildLocationGrowthSection(
    DashboardLoaded loadedState,
    DashboardState currentState,
  ) {
    final l10n = DashboardLocalizations.of(context);

    if (loadedState.locationGrowthTrend != null) {
      return LocationGrowthTrendWidget(
        key: ValueKey('location_${loadedState.locationGrowthLocationFilter}'),
        growthTrend: loadedState.locationGrowthTrend!,
        selectedLocationCode: loadedState.locationGrowthLocationFilter,
        availableLocations: _getAllLocations(loadedState),
        chartType: _locationChartType,
        onLocationChanged: (locationCode) {
          context.read<DashboardBloc>().add(
            LoadLocationGrowthTrends(locationCode: locationCode),
          );
        },
        onChartTypeChanged: (chartType) {
          setState(() {
            _locationChartType = chartType;
          });
        },
        isLoading:
            currentState is DashboardPartialLoading &&
            currentState.loadingType == 'location_trends',
      );
    }

    return _buildEmptyCard(l10n.noLocationData);
  }

  Widget _buildEmptyCard(String message) {
    final theme = Theme.of(context);

    return Container(
      decoration: _getCardDecoration(theme),
      child: Center(
        child: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: _getSecondaryTextColor(theme),
          ),
        ),
      ),
    );
  }

  // Theme helper methods

  Color _getSecondaryTextColor(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
  }

  Color _getTertiaryTextColor(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return isDark ? AppColors.darkTextMuted : AppColors.textTertiary;
  }

  BoxDecoration _getCardDecoration(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return isDark
        ? BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: AppBorders.large,
            border: Border.all(
              color: AppColors.darkBorder.withValues(alpha: 0.3),
            ),
          )
        : AppDecorations.dashboardCard;
  }

  Widget _buildLoadingState(BuildContext context, String message) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: isDark
                ? theme.colorScheme.onSurface
                : theme.colorScheme.primary,
            strokeWidth: 3,
          ),
          AppSpacing.verticalSpaceXL,
          Text(
            message,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: _getSecondaryTextColor(theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = DashboardLocalizations.of(context);

    return Center(
      child: Padding(
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: AppSpacing.paddingXXL,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.error.withValues(alpha: 0.1)
                    : AppColors.errorLight,
                borderRadius: AppBorders.circular,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
            ),
            AppSpacing.verticalSpaceXL,
            Text(
              l10n.dashboardError,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.verticalSpaceSM,
            Container(
              padding: AppSpacing.paddingMD,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.error.withValues(alpha: 0.1)
                    : AppColors.errorLight,
                borderRadius: AppBorders.md,
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.error,
                ),
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
                icon: Icon(Icons.refresh, color: theme.colorScheme.onPrimary),
                label: Text(
                  l10n.retry,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: AppSpacing.buttonPaddingSymmetric,
                  shape: const RoundedRectangleBorder(borderRadius: AppBorders.md),
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
    final isDark = theme.brightness == Brightness.dark;
    final l10n = DashboardLocalizations.of(context);

    return Center(
      child: Padding(
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: AppSpacing.paddingXXL,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.backgroundSecondary,
                borderRadius: AppBorders.circular,
              ),
              child: Icon(
                Icons.dashboard_outlined,
                size: 64,
                color: _getTertiaryTextColor(theme),
              ),
            ),
            AppSpacing.verticalSpaceXL,
            Text(
              l10n.noDashboardData,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.verticalSpaceSM,
            Text(
              l10n.noDashboardDataDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _getSecondaryTextColor(theme),
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
                icon: Icon(Icons.dashboard, color: theme.colorScheme.onPrimary),
                label: Text(
                  l10n.loadDashboard,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: AppSpacing.buttonPaddingSymmetric,
                  shape: const RoundedRectangleBorder(borderRadius: AppBorders.md),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = DashboardLocalizations.of(context);

    return Container(
      padding: AppSpacing.paddingLG,
      decoration: isDark
          ? BoxDecoration(
              color: AppColors.darkSurfaceVariant,
              borderRadius: AppBorders.large,
              border: Border.all(
                color: AppColors.darkBorder.withValues(alpha: 0.5),
              ),
            )
          : AppDecorations.card.copyWith(
              color: AppColors.backgroundSecondary,
              border: Border.all(
                color: AppColors.divider.withValues(alpha: 0.5),
              ),
            ),
      child: Row(
        children: [
          Icon(
            Icons.access_time,
            size: 16,
            color: _getSecondaryTextColor(theme),
          ),
          AppSpacing.horizontalSpaceSM,
          Text(
            '${l10n.lastUpdated}: ${Helpers.formatDateTime(state.lastUpdated)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: _getSecondaryTextColor(theme),
            ),
          ),
          const Spacer(),
          if (state.hasActiveFilters) ...[
            Icon(Icons.filter_alt, size: 16, color: theme.colorScheme.primary),
            AppSpacing.horizontalSpaceXS,
            Text(
              l10n.filtered,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (state.isDataRecent) ...[
            AppSpacing.horizontalSpaceSM,
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
            ),
            AppSpacing.horizontalSpaceXS,
            Text(
              l10n.fresh,
              style: theme.textTheme.bodySmall?.copyWith(
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
