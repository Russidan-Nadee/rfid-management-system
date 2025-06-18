// Path: frontend/lib/features/dashboard/presentation/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../di/injection.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/summary_cards_widget.dart';
import '../widgets/department_card.dart';
import '../widgets/growth_trends_card.dart';
import '../widgets/audit_progress_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _selectedPeriod = '7d';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => getIt<DashboardBloc>()
        ..add(const LoadDashboardStats())
        ..add(const LoadQuickStats())
        ..add(const LoadDepartmentAnalytics())
        ..add(const LoadGrowthTrends())
        ..add(const LoadAuditProgress()),
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: AppBar(
          title: const Text('Dashboard Overview'),
          centerTitle: true,
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          elevation: 1,
          actions: [
            BlocBuilder<DashboardBloc, DashboardState>(
              builder: (context, state) {
                return IconButton(
                  onPressed: state is DashboardLoading
                      ? null
                      : () {
                          context.read<DashboardBloc>().add(
                            const RefreshDashboard(),
                          );
                        },
                  icon: state is DashboardLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.onSurface,
                            ),
                          ),
                        )
                      : const Icon(Icons.refresh),
                );
              },
            ),
          ],
        ),
        body: BlocListener<DashboardBloc, DashboardState>(
          listener: (context, state) {
            if (state is DashboardError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            } else if (state is DashboardRefreshed) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dashboard refreshed successfully'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardBloc>().add(const RefreshDashboard());
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period selector header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '🏠 Overview (สรุปภาพรวม)',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildPeriodDropdown(context, theme),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Summary Cards
                  const SummaryCardsWidget(),
                  const SizedBox(height: 24),

                  // Department Analytics (Pie Chart)
                  const DepartmentCard(),
                  const SizedBox(height: 24),

                  // Growth Trends (Line Chart)
                  const GrowthTrendsCard(),
                  const SizedBox(height: 24),

                  // Audit Progress (Circle Progress)
                  const AuditProgressCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodDropdown(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPeriod,
          items: const [
            DropdownMenuItem(value: 'today', child: Text('วันนี้')),
            DropdownMenuItem(value: '7d', child: Text('7 วัน')),
            DropdownMenuItem(value: '30d', child: Text('30 วัน')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedPeriod = value;
              });
              context.read<DashboardBloc>().add(ChangePeriod(value));
            }
          },
          style: theme.textTheme.bodyMedium,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

/// Alternative implementation with tabs for different dashboard views
class DashboardPageWithTabs extends StatefulWidget {
  const DashboardPageWithTabs({super.key});

  @override
  State<DashboardPageWithTabs> createState() => _DashboardPageWithTabsState();
}

class _DashboardPageWithTabsState extends State<DashboardPageWithTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => getIt<DashboardBloc>()
        ..add(const LoadDashboardStats())
        ..startAutoRefresh(),
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: AppBar(
          title: const Text('Dashboard'),
          backgroundColor: theme.colorScheme.surface,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: theme.colorScheme.primary,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
            tabs: const [
              Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
              Tab(icon: Icon(Icons.trending_up), text: 'Analytics'),
              Tab(icon: Icon(Icons.assignment), text: 'Audit'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Overview Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: const [
                  SummaryCardsWidget(),
                  SizedBox(height: 24),
                  DepartmentCard(),
                ],
              ),
            ),

            // Analytics Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: const [
                  GrowthTrendsCard(),
                  SizedBox(height: 24),
                  // LocationAnalyticsCard(), // TODO: Add when implemented
                ],
              ),
            ),

            // Audit Tab
            const SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: AuditProgressCard(),
            ),
          ],
        ),
      ),
    );
  }
}
