// Path: frontend/lib/features/export/presentation/pages/export_history_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../di/injection.dart';
import '../bloc/export_bloc.dart';
import '../bloc/export_event.dart';
import '../bloc/export_state.dart';
import '../widgets/export_history_list.dart';
import '../widgets/export_progress_widget.dart';

class ExportHistoryPage extends StatelessWidget {
  const ExportHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ExportBloc>()
        ..add(const LoadExportHistory())
        ..add(const LoadExportStats()),
      child: const ExportHistoryPageView(),
    );
  }
}

class ExportHistoryPageView extends StatefulWidget {
  const ExportHistoryPageView({super.key});

  @override
  State<ExportHistoryPageView> createState() => _ExportHistoryPageViewState();
}

class _ExportHistoryPageViewState extends State<ExportHistoryPageView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _statusFilter = 'all';
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    final newFilter = _getFilterForTab(_tabController.index);
    if (newFilter != _statusFilter) {
      setState(() => _statusFilter = newFilter);
      _loadHistoryWithFilter(newFilter);
    }
  }

  String _getFilterForTab(int index) {
    switch (index) {
      case 0:
        return 'all';
      case 1:
        return 'P'; // Pending
      case 2:
        return 'C'; // Completed
      case 3:
        return 'F'; // Failed
      default:
        return 'all';
    }
  }

  void _loadHistoryWithFilter(String filter) {
    final statusFilter = filter == 'all' ? null : filter;
    context.read<ExportBloc>().add(
      LoadExportHistory(statusFilter: statusFilter, refresh: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _buildAppBar(theme),
      body: BlocListener<ExportBloc, ExportState>(
        listener: _handleStateChanges,
        child: Column(
          children: [
            if (_shouldShowProgress()) _buildProgressSection(),
            _buildStatsHeader(theme),
            _buildTabBar(theme),
            Expanded(child: _buildTabContent()),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(theme),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.history,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text('Export History'),
        ],
      ),
      actions: [
        BlocBuilder<ExportBloc, ExportState>(
          builder: (context, state) {
            if (state is ExportHistoryLoaded && state.hasExports) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: _handleMenuAction,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'selection_mode',
                    child: Row(
                      children: [
                        Icon(
                          _isSelectionMode ? Icons.close : Icons.checklist,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isSelectionMode ? 'Exit Selection' : 'Select Mode',
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'refresh',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, size: 20),
                        SizedBox(width: 8),
                        Text('Refresh'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'cleanup',
                    child: Row(
                      children: [
                        Icon(Icons.cleaning_services, size: 20),
                        SizedBox(width: 8),
                        Text('Cleanup Expired'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'export_stats',
                    child: Row(
                      children: [
                        Icon(Icons.analytics, size: 20),
                        SizedBox(width: 8),
                        Text('View Statistics'),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'selection_mode':
        setState(() => _isSelectionMode = !_isSelectionMode);
        if (!_isSelectionMode) {
          context.read<ExportBloc>().add(const DeselectAllExports());
        }
        break;
      case 'refresh':
        context.read<ExportBloc>()
          ..add(const RefreshExportHistory())
          ..add(const RefreshExportStats());
        break;
      case 'cleanup':
        _showCleanupDialog();
        break;
      case 'export_stats':
        _showStatsDialog();
        break;
    }
  }

  void _handleStateChanges(BuildContext context, ExportState state) {
    if (state is ExportError) {
      Helpers.showError(context, state.userFriendlyMessage);
    } else if (state is CleanupCompleted) {
      Helpers.showSuccess(context, state.message);
    } else if (state is ExportDeleted) {
      Helpers.showSuccess(context, 'Export deleted successfully');
    } else if (state is MultipleExportsDeleted) {
      if (state.deletedCount > 0) {
        Helpers.showSuccess(context, '${state.deletedCount} exports deleted');
      }
      if (state.hasErrors) {
        Helpers.showError(context, 'Some deletions failed');
      }
    }
  }

  bool _shouldShowProgress() {
    final currentState = context.read<ExportBloc>().state;
    return currentState is ExportLoading ||
        currentState is BatchDownloadProgress;
  }

  Widget _buildProgressSection() {
    return BlocBuilder<ExportBloc, ExportState>(
      buildWhen: (previous, current) =>
          current is ExportLoading || current is BatchDownloadProgress,
      builder: (context, state) {
        if (state is ExportLoading || state is BatchDownloadProgress) {
          return ExportProgressWidget(state: state);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatsHeader(ThemeData theme) {
    return BlocBuilder<ExportBloc, ExportState>(
      builder: (context, state) {
        if (state is ExportStatsLoaded) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    theme,
                    'Total',
                    '${state.stats.totalExports}',
                    Icons.inventory,
                    theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    theme,
                    'Pending',
                    '${state.stats.pendingExports}',
                    Icons.hourglass_empty,
                    Colors.orange.shade600,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    theme,
                    'Completed',
                    '${state.stats.completedExports}',
                    Icons.check_circle,
                    Colors.green.shade600,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    theme,
                    'Failed',
                    '${state.stats.failedExports}',
                    Icons.error,
                    Colors.red.shade600,
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(icon: Icon(Icons.all_inclusive), text: 'All'),
          Tab(icon: Icon(Icons.hourglass_empty), text: 'Pending'),
          Tab(icon: Icon(Icons.check_circle), text: 'Completed'),
          Tab(icon: Icon(Icons.error), text: 'Failed'),
        ],
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurface.withValues(
          alpha: 0.6,
        ),
        indicatorColor: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        // All exports - no filter needed, bloc handles filtering
        ExportHistoryList(enableSelection: _isSelectionMode),

        // Pending exports - filter handled by bloc state
        BlocBuilder<ExportBloc, ExportState>(
          builder: (context, state) {
            if (state is ExportHistoryLoaded) {
              final pendingExports = state.exports
                  .where((e) => e.isPending)
                  .toList();
              return ExportHistoryList(
                enableSelection: _isSelectionMode,
                customExports: pendingExports,
              );
            }
            return ExportHistoryList(enableSelection: _isSelectionMode);
          },
        ),

        // Completed exports
        BlocBuilder<ExportBloc, ExportState>(
          builder: (context, state) {
            if (state is ExportHistoryLoaded) {
              final completedExports = state.exports
                  .where((e) => e.isCompleted)
                  .toList();
              return ExportHistoryList(
                enableSelection: _isSelectionMode,
                customExports: completedExports,
              );
            }
            return ExportHistoryList(enableSelection: _isSelectionMode);
          },
        ),

        // Failed exports
        BlocBuilder<ExportBloc, ExportState>(
          builder: (context, state) {
            if (state is ExportHistoryLoaded) {
              final failedExports = state.exports
                  .where((e) => e.isFailed)
                  .toList();
              return ExportHistoryList(
                enableSelection: _isSelectionMode,
                customExports: failedExports,
              );
            }
            return ExportHistoryList(enableSelection: _isSelectionMode);
          },
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton(ThemeData theme) {
    return BlocBuilder<ExportBloc, ExportState>(
      builder: (context, state) {
        if (state is ExportHistoryLoaded && state.hasSelections) {
          return FloatingActionButton.extended(
            onPressed: () => _showBatchActionsDialog(),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            icon: const Icon(Icons.more_horiz),
            label: Text('${state.selectedCount} Selected'),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showCleanupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cleanup Expired Files'),
        content: const Text(
          'This will remove all expired export files from the server. '
          'This action cannot be undone. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ExportBloc>().add(
                const CleanupExpiredFilesRequested(),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cleanup'),
          ),
        ],
      ),
    );
  }

  void _showStatsDialog() {
    showDialog(
      context: context,
      builder: (context) => BlocBuilder<ExportBloc, ExportState>(
        builder: (context, state) {
          if (state is ExportStatsLoaded) {
            return AlertDialog(
              title: const Text('Export Statistics'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(
                    'Total Exports',
                    '${state.stats.totalExports}',
                  ),
                  _buildStatsRow(
                    'Success Rate',
                    _formatSuccessRate(state.stats.successRate),
                  ),
                  _buildStatsRow(
                    'Total Size',
                    state.stats.totalFilesSizeFormatted,
                  ),
                  if (state.stats.lastExportDate != null)
                    _buildStatsRow(
                      'Last Export',
                      _formatDateTime(state.stats.lastExportDate!),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            );
          }
          return const AlertDialog(
            title: Text('Loading Statistics...'),
            content: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildStatsRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  void _showBatchActionsDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => BlocBuilder<ExportBloc, ExportState>(
        builder: (context, state) {
          if (state is ExportHistoryLoaded && state.hasSelections) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Batch Actions',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text('${state.selectedCount} exports selected'),
                  const SizedBox(height: 24),
                  ListTile(
                    leading: Icon(Icons.download, color: Colors.green.shade600),
                    title: const Text('Download All'),
                    subtitle: const Text('Download selected completed exports'),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.read<ExportBloc>().add(
                        BatchDownloadRequested(state.selectedExportIds),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.delete, color: Colors.red.shade600),
                    title: const Text('Delete Selected'),
                    subtitle: const Text('Delete selected exports'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _showDeleteSelectedDialog(state.selectedExportIds);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.clear),
                    title: const Text('Clear Selection'),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.read<ExportBloc>().add(
                        const DeselectAllExports(),
                      );
                    },
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showDeleteSelectedDialog(List<int> exportIds) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Selected Exports'),
        content: Text(
          'Are you sure you want to delete ${exportIds.length} selected exports? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ExportBloc>().add(
                DeleteMultipleExportsRequested(exportIds),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Helper methods - local implementation
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatSuccessRate(double rate) {
    return '${(rate * 100).toStringAsFixed(1)}%';
  }
}
