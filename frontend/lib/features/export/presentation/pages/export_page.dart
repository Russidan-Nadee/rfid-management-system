// Path: frontend/lib/features/export/presentation/pages/export_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../di/injection.dart';
import '../bloc/export_bloc.dart';
import '../bloc/export_event.dart';
import '../bloc/export_state.dart';
import '../widgets/export_config_form.dart';
import '../widgets/export_progress_widget.dart';
import '../widgets/export_history_list.dart';

class ExportPage extends StatelessWidget {
  const ExportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ExportBloc>()
        ..add(const LoadExportHistory())
        ..add(const LoadExportStats()),
      child: const ExportPageView(),
    );
  }
}

class ExportPageView extends StatefulWidget {
  const ExportPageView({super.key});

  @override
  State<ExportPageView> createState() => _ExportPageViewState();
}

class _ExportPageViewState extends State<ExportPageView>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWideScreen = Helpers.isDesktop(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: BlocListener<ExportBloc, ExportState>(
        listener: _handleStateChanges,
        child: isWideScreen
            ? _buildDesktopLayout(theme)
            : _buildMobileLayout(theme),
      ),
    );
  }

  void _handleStateChanges(BuildContext context, ExportState state) {
    // Handle success messages
    if (state is ExportJobCreated) {
      Helpers.showSuccess(context, 'Export job created successfully');
    } else if (state is ExportDownloadCompleted) {
      Helpers.showSuccess(context, 'File downloaded: ${state.fileName}');
    } else if (state is ExportShared) {
      Helpers.showSuccess(context, 'Export shared successfully');
    } else if (state is ExportDeleted) {
      Helpers.showSuccess(context, 'Export deleted successfully');
    } else if (state is ExportCancelled) {
      Helpers.showSuccess(context, 'Export cancelled successfully');
    } else if (state is CleanupCompleted) {
      Helpers.showSuccess(context, state.message);
    }
    // Handle error messages
    else if (state is ExportError) {
      Helpers.showError(context, state.userFriendlyMessage);
    }
    // Handle batch operations
    else if (state is BatchDownloadCompleted) {
      if (state.hasAnySuccess) {
        Helpers.showSuccess(
          context,
          'Downloaded ${state.successCount} files successfully',
        );
      }
      if (state.hasAnyErrors) {
        Helpers.showError(context, '${state.errorCount} downloads failed');
      }
    } else if (state is MultipleExportsDeleted) {
      Helpers.showSuccess(
        context,
        'Deleted ${state.deletedCount} exports successfully',
      );
      if (state.hasErrors) {
        Helpers.showError(context, 'Some deletions failed');
      }
    }
  }

  Widget _buildDesktopLayout(ThemeData theme) {
    return Row(
      children: [
        // Left Panel - Export Configuration
        Expanded(flex: 2, child: _buildMainContent(theme)),

        // Right Panel - Quick Actions & History
        Expanded(flex: 1, child: _buildSidePanel(theme)),
      ],
    );
  }

  Widget _buildMobileLayout(ThemeData theme) {
    return Column(
      children: [
        // App Bar
        _buildAppBar(theme),

        // Tab Bar
        _buildTabBar(theme),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildMainContent(theme), _buildHistoryTab(theme)],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.upload,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export Center',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    'Generate and download your data',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            // Stats Summary
            BlocBuilder<ExportBloc, ExportState>(
              builder: (context, state) {
                if (state is ExportStatsLoaded) {
                  return _buildStatsChip(theme, state.stats);
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(icon: Icon(Icons.add_to_queue), text: 'Create Export'),
          Tab(icon: Icon(Icons.history), text: 'History'),
        ],
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
        indicatorColor: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildMainContent(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (Helpers.isDesktop(context)) ...[
            _buildDesktopHeader(theme),
            const SizedBox(height: 24),
          ],

          // Progress Widget (shown when operations are in progress)
          BlocBuilder<ExportBloc, ExportState>(
            buildWhen: (previous, current) => _shouldShowProgress(current),
            builder: (context, state) {
              if (_shouldShowProgress(state)) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: ExportProgressWidget(state: state),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Export Configuration Form
          const ExportConfigForm(),
        ],
      ),
    );
  }

  Widget _buildDesktopHeader(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Export Center',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                'Generate and download your data in various formats',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        // Quick Action Buttons
        Row(
          children: [
            _buildQuickActionButton(
              theme,
              icon: Icons.cleaning_services,
              label: 'Cleanup',
              onPressed: () {
                context.read<ExportBloc>().add(
                  const CleanupExpiredFilesRequested(),
                );
              },
            ),
            const SizedBox(width: 8),
            _buildQuickActionButton(
              theme,
              icon: Icons.refresh,
              label: 'Refresh',
              onPressed: () {
                context.read<ExportBloc>()
                  ..add(const RefreshExportHistory())
                  ..add(const RefreshExportStats());
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: theme.colorScheme.primary,
        side: BorderSide(color: theme.colorScheme.primary),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildSidePanel(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
        ),
      ),
      child: Column(
        children: [
          // Quick Actions Panel
          _buildQuickActionsPanel(theme),

          // History Panel
          Expanded(child: _buildHistoryPanel(theme)),
        ],
      ),
    );
  }

  Widget _buildQuickActionsPanel(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flash_on, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildQuickActionTile(
            theme,
            icon: Icons.inventory,
            title: 'All Active Assets',
            subtitle: 'Export all active assets',
            onTap: () {
              context.read<ExportBloc>().add(
                const QuickExportRequested(QuickExportType.allActiveAssets),
              );
            },
          ),

          _buildQuickActionTile(
            theme,
            icon: Icons.qr_code_scanner,
            title: 'Recent Scans',
            subtitle: 'Last 7 days scan logs',
            onTap: () {
              context.read<ExportBloc>().add(
                const QuickExportRequested(QuickExportType.recentScans),
              );
            },
          ),

          _buildQuickActionTile(
            theme,
            icon: Icons.assessment,
            title: 'Monthly Report',
            subtitle: 'This month\'s summary',
            onTap: () {
              context.read<ExportBloc>().add(
                const QuickExportRequested(QuickExportType.monthlyReport),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionTile(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryPanel(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Recent Exports',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  if (!Helpers.isDesktop(context)) {
                    _tabController.animateTo(1);
                  }
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ExportHistoryList(
              isCompact: true,
              maxItems: Helpers.isDesktop(context) ? 5 : 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(ThemeData theme) {
    return ExportHistoryList(showHeader: true, enableSelection: true);
  }

  Widget _buildStatsChip(ThemeData theme, ExportStatsEntity stats) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.analytics, color: theme.colorScheme.primary, size: 16),
          const SizedBox(width: 4),
          Text(
            '${stats.totalExports}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          if (stats.hasPendingExports) ...[
            const SizedBox(width: 4),
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _shouldShowProgress(ExportState state) {
    return state is ExportCreating ||
        state is ExportDownloading ||
        state is BatchDownloadProgress ||
        state is ExportLoading ||
        (state is ExportStatusUpdated && state.exportJob.isPending);
  }
}
