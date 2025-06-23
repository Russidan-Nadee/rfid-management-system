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
import '../widgets/location_growth_trend_widget.dart';
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
                        deptCode: null, // ลบ deptCode เพราะมี 2 filters แยกกัน
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
                  'Overview this year',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
            const SizedBox(height: 16),

            if (loadedState.auditProgress != null)
              AuditProgressWidget(
                auditProgress: loadedState.auditProgress!,
                includeDetails: loadedState.includeDetails,
                selectedDeptCode: loadedState
                    .auditProgressDeptFilter, // ใช้ auditProgressDeptFilter
                availableDepartments: _getAllDepartments(loadedState),
                onDeptChanged: (deptCode) {
                  context.read<DashboardBloc>().add(
                    LoadAuditProgress(
                      deptCode: deptCode,
                    ), // แยก event สำหรับ Audit Progress
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

            // Growth Trend Chart (Department)
            if (loadedState.growthTrend != null)
              GrowthTrendChartWidget(
                growthTrend: loadedState.growthTrend!,
                selectedDeptCode: loadedState
                    .growthTrendDeptFilter, // ใช้ growthTrendDeptFilter
                availableDepartments: _getAllDepartments(loadedState),
                onDeptChanged: (deptCode) {
                  context.read<DashboardBloc>().add(
                    LoadGrowthTrends(
                      deptCode: deptCode,
                    ), // แยก event สำหรับ Growth Trend
                  );
                },
                isLoading:
                    state is DashboardPartialLoading &&
                    state.loadingType == 'trends',
              ),

            const SizedBox(height: 24),

            if (loadedState.locationTrend != null)
              LocationGrowthTrendWidget(
                growthTrend: loadedState.locationTrend!,
                selectedLocationCode:
                    loadedState.locationAnalyticsLocationFilter,
                availableLocations: _getAllLocations(loadedState),
                onLocationChanged: (locationCode) {
                  context.read<DashboardBloc>().add(
                    LoadLocationGrowthTrends(
                      locationCode: locationCode,
                      period: 'Q2',
                    ),
                  );
                },
                isLoading:
                    state is DashboardPartialLoading &&
                    state.loadingType == 'location_trends',
              ),
            const SizedBox(height: 24),

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

    // รวม Department จาก Growth Trend (ถ้ามี)
    if (state.growthTrend != null) {
      for (final trend in state.growthTrend!.trends) {
        if (trend.deptCode.isNotEmpty) {
          allDeptCodes.add(trend.deptCode);
          deptMap[trend.deptCode] = trend.deptDescription;
        }
      }
    }

    // รวม Department จาก Asset Distribution (ถ้ามี)
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
  // Helper method เพื่อรวม Location จากทุกแหล่ง
  List<Map<String, String>> _getAllLocations(DashboardLoaded state) {
    final Set<String> allLocationCodes = {};
    final Map<String, String> locationMap = {};

    print('🏢 Getting all locations...');
    print(
      '🏢 State has location analytics: ${state.locationAnalytics != null}',
    );

    // รวม Location จาก Location Analytics
    if (state.locationAnalytics != null) {
      print(
        '🏢 Location trends count: ${state.locationAnalytics!.locationTrends.length}',
      );
      for (final trend in state.locationAnalytics!.locationTrends) {
        allLocationCodes.add(trend.locationCode);
        locationMap[trend.locationCode] = trend.locationDescription;
      }
    }

    // รวม Location จาก LocationTrend (ใหม่)
    if (state.locationTrend != null) {
      print(
        '🏢 Location trend data count: ${state.locationTrend!.trends.length}',
      );
      for (final trend in state.locationTrend!.trends) {
        // ใช้ deptCode และ deptDescription เป็น location data (เพราะ reuse GrowthTrend)
        if (trend.deptCode.isNotEmpty) {
          allLocationCodes.add(trend.deptCode);
          locationMap[trend.deptCode] = trend.deptDescription;
        }
      }
    }

    // เพิ่ม default locations ถ้าไม่มีข้อมูล
    if (allLocationCodes.isEmpty) {
      allLocationCodes.addAll(['30-OFF-002', '30-CUR-00', 'LOC-001']);
      locationMap['30-OFF-002'] = 'Office 002';
      locationMap['30-CUR-00'] = 'Curriculum Office';
      locationMap['LOC-001'] = 'Location 001';
    }

    // Convert เป็น List และเรียงตามชื่อ
    final List<Map<String, String>> locations = allLocationCodes
        .map((code) => {'code': code, 'name': locationMap[code] ?? code})
        .toList();

    // เรียงตามชื่อ Location
    locations.sort((a, b) => a['name']!.compareTo(b['name']!));

    print('🏢 Final locations: ${locations.map((l) => l['code']).toList()}');
    return locations;
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
