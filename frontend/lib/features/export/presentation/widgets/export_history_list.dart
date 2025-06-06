// Path: frontend/lib/features/export/presentation/widgets/export_history_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/helpers.dart';
import '../../domain/entities/export_job_entity.dart';
import '../bloc/export_bloc.dart';
import '../bloc/export_event.dart';
import '../bloc/export_state.dart';

class ExportHistoryList extends StatefulWidget {
  final bool isCompact;
  final int? maxItems;
  final bool showHeader;
  final bool enableSelection;
  final VoidCallback? onSelectionChanged;
  final List<ExportJobEntity>? customExports;

  const ExportHistoryList({
    super.key,
    this.isCompact = false,
    this.maxItems,
    this.showHeader = false,
    this.enableSelection = false,
    this.onSelectionChanged,
    this.customExports,
  });

  @override
  State<ExportHistoryList> createState() => _ExportHistoryListState();
}

class _ExportHistoryListState extends State<ExportHistoryList> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isCompact) {
      _scrollController.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (!_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      // Implement load more logic
      context.read<ExportBloc>().add(const LoadExportHistory(page: 2));
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ExportBloc, ExportState>(
      builder: (context, state) {
        if (state is ExportLoading) {
          return _buildLoadingState(theme);
        } else if (state is ExportHistoryLoaded) {
          return _buildHistoryList(theme, state);
        } else if (state is ExportError) {
          return _buildErrorState(theme, state);
        }
        return _buildEmptyState(theme);
      },
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Loading export history...',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(ThemeData theme, ExportHistoryLoaded state) {
    final exports = widget.maxItems != null
        ? state.exports.take(widget.maxItems!).toList()
        : state.exports;

    if (exports.isEmpty) {
      return _buildEmptyState(theme);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showHeader) _buildHeader(theme, state),
        if (widget.enableSelection && exports.isNotEmpty)
          _buildSelectionControls(theme, state),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<ExportBloc>().add(const RefreshExportHistory());
            },
            child: ListView.separated(
              controller: widget.isCompact ? null : _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: exports.length + (_isLoadingMore ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                if (index >= exports.length) {
                  return _buildLoadingMoreIndicator(theme);
                }

                final export = exports[index];
                return _buildExportCard(theme, export, state);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme, ExportHistoryLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.history, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Export History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${state.exports.length} exports found',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              context.read<ExportBloc>().add(const RefreshExportHistory());
            },
            icon: Icon(Icons.refresh, color: theme.colorScheme.primary),
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionControls(ThemeData theme, ExportHistoryLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: state.selectedCount == state.exports.length,
            tristate: true,
            onChanged: (value) {
              if (value == true) {
                context.read<ExportBloc>().add(const SelectAllExports());
              } else {
                context.read<ExportBloc>().add(const DeselectAllExports());
              }
              widget.onSelectionChanged?.call();
            },
          ),
          Expanded(
            child: Text(
              state.hasSelections
                  ? '${state.selectedCount} selected'
                  : 'Select exports',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (state.hasSelections) ...[
            TextButton.icon(
              onPressed: () => _showBatchActions(context, state),
              icon: const Icon(Icons.more_horiz),
              label: const Text('Actions'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExportCard(
    ThemeData theme,
    ExportJobEntity export,
    ExportHistoryLoaded state,
  ) {
    final isSelected = state.selectedExportIds.contains(export.exportId);
    final isCompact = widget.isCompact;

    return Card(
      elevation: isSelected ? 4 : 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => _handleExportTap(export, state),
        onLongPress: widget.enableSelection
            ? () => _toggleSelection(export.exportId)
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(isCompact ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildExportHeader(theme, export, isSelected, isCompact),
              if (!isCompact) const SizedBox(height: 12),
              if (!isCompact) _buildExportDetails(theme, export),
              const SizedBox(height: 8),
              _buildExportFooter(theme, export, isCompact),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExportHeader(
    ThemeData theme,
    ExportJobEntity export,
    bool isSelected,
    bool isCompact,
  ) {
    return Row(
      children: [
        if (widget.enableSelection)
          Checkbox(
            value: isSelected,
            onChanged: (_) => _toggleSelection(export.exportId),
          ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getStatusColor(export.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getExportTypeIcon(export.exportType),
            color: _getStatusColor(export.status),
            size: isCompact ? 16 : 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                export.exportTypeLabel,
                style: TextStyle(
                  fontSize: isCompact ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                'ID: ${export.exportId}',
                style: TextStyle(
                  fontSize: isCompact ? 12 : 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        _buildStatusChip(theme, export, isCompact),
      ],
    );
  }

  Widget _buildExportDetails(ThemeData theme, ExportJobEntity export) {
    return Row(
      children: [
        if (export.totalRecords != null) ...[
          _buildDetailChip(
            theme,
            Icons.inventory,
            '${export.totalRecords} records',
          ),
          const SizedBox(width: 8),
        ],
        if (export.fileSize != null) ...[
          _buildDetailChip(theme, Icons.storage, export.fileSizeFormatted),
          const SizedBox(width: 8),
        ],
        _buildDetailChip(
          theme,
          Icons.access_time,
          Helpers.formatTimeAgo(export.createdAt),
        ),
      ],
    );
  }

  Widget _buildDetailChip(ThemeData theme, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportFooter(
    ThemeData theme,
    ExportJobEntity export,
    bool isCompact,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            _getExportMessage(export),
            style: TextStyle(
              fontSize: isCompact ? 11 : 12,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            maxLines: isCompact ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!isCompact) _buildActionButtons(theme, export),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme, ExportJobEntity export) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (export.canDownload) ...[
          IconButton(
            onPressed: () => _downloadExport(export.exportId),
            icon: const Icon(Icons.download),
            iconSize: 20,
            tooltip: 'Download',
            style: IconButton.styleFrom(foregroundColor: Colors.green[600]),
          ),
          IconButton(
            onPressed: () => _shareExport(export.exportId),
            icon: const Icon(Icons.share),
            iconSize: 20,
            tooltip: 'Share',
            style: IconButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
          ),
        ],
        if (export.isPending)
          IconButton(
            onPressed: () => _cancelExport(export.exportId),
            icon: const Icon(Icons.cancel),
            iconSize: 20,
            tooltip: 'Cancel',
            style: IconButton.styleFrom(foregroundColor: Colors.red[600]),
          ),
        if (export.isCompleted || export.isFailed)
          IconButton(
            onPressed: () => _deleteExport(export.exportId),
            icon: const Icon(Icons.delete),
            iconSize: 20,
            tooltip: 'Delete',
            style: IconButton.styleFrom(foregroundColor: Colors.red[600]),
          ),
      ],
    );
  }

  Widget _buildStatusChip(
    ThemeData theme,
    ExportJobEntity export,
    bool isCompact,
  ) {
    final color = _getStatusColor(export.status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 6 : 8,
        vertical: isCompact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isCompact ? 6 : 8,
            height: isCompact ? 6 : 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            export.statusLabel,
            style: TextStyle(
              fontSize: isCompact ? 10 : 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMoreIndicator(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: CircularProgressIndicator(
          color: theme.colorScheme.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, ExportError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Failed to load export history',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.userFriendlyMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<ExportBloc>().add(const RefreshExportHistory());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No export history',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first export to see it here',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'P':
        return Colors.orange[600]!;
      case 'C':
        return Colors.green[600]!;
      case 'F':
        return Colors.red[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  IconData _getExportTypeIcon(String exportType) {
    switch (exportType) {
      case 'assets':
        return Icons.inventory_2;
      case 'scan_logs':
        return Icons.qr_code_scanner;
      case 'status_history':
        return Icons.history;
      default:
        return Icons.file_download;
    }
  }

  String _getExportMessage(ExportJobEntity export) {
    if (export.isPending) {
      final elapsed = DateTime.now().difference(export.createdAt);
      if (elapsed.inMinutes < 1) {
        return 'Export started just now...';
      } else {
        return 'Processing for ${elapsed.inMinutes}m...';
      }
    } else if (export.isCompleted) {
      if (export.isExpired) {
        return 'File expired and deleted';
      } else {
        final remaining = export.timeUntilExpiry;
        if (remaining.inDays > 0) {
          return 'Expires in ${remaining.inDays} days';
        } else if (remaining.inHours > 0) {
          return 'Expires in ${remaining.inHours} hours';
        } else {
          return 'Expires soon';
        }
      }
    } else if (export.isFailed) {
      return export.errorMessage ?? 'Export failed';
    }
    return 'Created ${Helpers.formatTimeAgo(export.createdAt)}';
  }

  void _handleExportTap(ExportJobEntity export, ExportHistoryLoaded state) {
    if (widget.enableSelection && state.hasSelections) {
      _toggleSelection(export.exportId);
    } else {
      context.read<ExportBloc>().add(ShowExportDetails(export.exportId));
      _showExportDetails(export);
    }
  }

  void _toggleSelection(int exportId) {
    context.read<ExportBloc>().add(ToggleExportSelection(exportId));
    widget.onSelectionChanged?.call();
  }

  void _downloadExport(int exportId) {
    context.read<ExportBloc>().add(DownloadExportRequested(exportId));
  }

  void _shareExport(int exportId) {
    context.read<ExportBloc>().add(ShareExportRequested(exportId));
  }

  void _cancelExport(int exportId) {
    context.read<ExportBloc>().add(CancelExportRequested(exportId));
  }

  void _deleteExport(int exportId) {
    _showDeleteConfirmation(exportId);
  }

  void _showExportDetails(ExportJobEntity export) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ExportDetailsSheet(export: export),
    );
  }

  void _showBatchActions(BuildContext context, ExportHistoryLoaded state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _BatchActionsSheet(
        selectedIds: state.selectedExportIds,
        selectedExports: state.selectedExports,
      ),
    );
  }

  void _showDeleteConfirmation(int exportId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Export'),
        content: const Text(
          'Are you sure you want to delete this export? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ExportBloc>().add(DeleteExportRequested(exportId));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _ExportDetailsSheet extends StatelessWidget {
  final ExportJobEntity export;

  const _ExportDetailsSheet({required this.export});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Export Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildDetailRow('Export ID', '${export.exportId}'),
          _buildDetailRow('Type', export.exportTypeLabel),
          _buildDetailRow('Status', export.statusLabel),
          if (export.totalRecords != null)
            _buildDetailRow('Records', '${export.totalRecords}'),
          if (export.fileSize != null)
            _buildDetailRow('File Size', export.fileSizeFormatted),
          _buildDetailRow('Created', Helpers.formatDateTime(export.createdAt)),
          _buildDetailRow('Expires', Helpers.formatDateTime(export.expiresAt)),
          if (export.errorMessage != null)
            _buildDetailRow('Error', export.errorMessage!),
          const SizedBox(height: 24),
          if (export.canDownload) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<ExportBloc>().add(
                    DownloadExportRequested(export.exportId),
                  );
                },
                icon: const Icon(Icons.download),
                label: const Text('Download'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _BatchActionsSheet extends StatelessWidget {
  final List<int> selectedIds;
  final List<ExportJobEntity> selectedExports;

  const _BatchActionsSheet({
    required this.selectedIds,
    required this.selectedExports,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final downloadableCount = selectedExports
        .where((e) => e.canDownload)
        .length;
    final deletableCount = selectedExports.where((e) => !e.isPending).length;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Batch Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${selectedIds.length} exports selected',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          if (downloadableCount > 0) ...[
            ListTile(
              leading: Icon(Icons.download, color: Colors.green[600]),
              title: Text('Download All ($downloadableCount)'),
              subtitle: const Text('Download all completed exports'),
              onTap: () {
                Navigator.of(context).pop();
                final downloadableIds = selectedExports
                    .where((e) => e.canDownload)
                    .map((e) => e.exportId)
                    .toList();
                context.read<ExportBloc>().add(
                  BatchDownloadRequested(downloadableIds),
                );
              },
            ),
          ],
          if (deletableCount > 0) ...[
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red[600]),
              title: Text('Delete Selected ($deletableCount)'),
              subtitle: const Text('Delete completed or failed exports'),
              onTap: () {
                Navigator.of(context).pop();
                final deletableIds = selectedExports
                    .where((e) => !e.isPending)
                    .map((e) => e.exportId)
                    .toList();
                context.read<ExportBloc>().add(
                  DeleteMultipleExportsRequested(deletableIds),
                );
              },
            ),
          ],
          ListTile(
            leading: Icon(Icons.clear, color: theme.colorScheme.primary),
            title: const Text('Clear Selection'),
            onTap: () {
              Navigator.of(context).pop();
              context.read<ExportBloc>().add(const DeselectAllExports());
            },
          ),
        ],
      ),
    );
  }
}
