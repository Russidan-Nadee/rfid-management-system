// Path: frontend/lib/features/export/presentation/widgets/export_progress_widget.dart
import 'package:flutter/material.dart';
import '../bloc/export_state.dart';

class ExportProgressWidget extends StatefulWidget {
  final ExportState state;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;

  const ExportProgressWidget({
    super.key,
    required this.state,
    this.onCancel,
    this.onRetry,
  });

  @override
  State<ExportProgressWidget> createState() => _ExportProgressWidgetState();
}

class _ExportProgressWidgetState extends State<ExportProgressWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Card(
              elevation: 4,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: _getGradientForState(theme),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildProgressHeader(theme),
                    const SizedBox(height: 20),
                    _buildProgressContent(theme),
                    const SizedBox(height: 20),
                    _buildProgressActions(theme),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressHeader(ThemeData theme) {
    final (icon, title, color) = _getHeaderInfo(theme);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                _getSubtitle(),
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        if (_shouldShowSpinner()) _buildSpinner(color),
      ],
    );
  }

  Widget _buildProgressContent(ThemeData theme) {
    return Column(
      children: [
        if (_shouldShowProgressBar()) ...[
          _buildProgressBar(theme),
          const SizedBox(height: 16),
        ],
        _buildStatusMessage(theme),
        if (_shouldShowDetails()) ...[
          const SizedBox(height: 16),
          _buildProgressDetails(theme),
        ],
      ],
    );
  }

  Widget _buildProgressBar(ThemeData theme) {
    final progress = _getProgress();
    final color = _getProgressColor(theme);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusMessage(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(_getStatusIcon(), color: _getStatusColor(theme), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getStatusMessage(),
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDetails(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: _buildDetailRows(theme)),
    );
  }

  Widget _buildProgressActions(ThemeData theme) {
    return Row(
      children: [
        if (_canCancel()) ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: widget.onCancel,
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red[700],
                side: BorderSide(color: Colors.red[700]!),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        if (_canRetry()) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: widget.onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
        if (_isCompleted()) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _handleDownloadComplete(),
              icon: const Icon(Icons.check_circle),
              label: const Text('View Details'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
        if (_shouldShowMinimize()) ...[
          IconButton(
            onPressed: () => _minimizeProgress(),
            icon: const Icon(Icons.minimize),
            tooltip: 'Minimize',
          ),
        ],
      ],
    );
  }

  Widget _buildSpinner(Color color) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  List<Widget> _buildDetailRows(ThemeData theme) {
    final details = <Widget>[];

    if (widget.state is BatchDownloadProgress) {
      final batchState = widget.state as BatchDownloadProgress;
      details.addAll([
        _buildDetailRow(
          theme,
          'Total Items',
          '${batchState.totalItems}',
          Icons.inventory,
        ),
        _buildDetailRow(
          theme,
          'Completed',
          '${batchState.completedItems}',
          Icons.check_circle,
        ),
        if (batchState.hasErrors)
          _buildDetailRow(
            theme,
            'Errors',
            '${batchState.errors.length}',
            Icons.error,
            color: Colors.red[600],
          ),
        if (batchState.currentItem != null)
          _buildDetailRow(
            theme,
            'Current',
            batchState.currentItem!,
            Icons.download,
          ),
      ]);
    } else if (widget.state is ExportDownloading) {
      final downloadState = widget.state as ExportDownloading;
      details.addAll([
        _buildDetailRow(
          theme,
          'Export ID',
          '${downloadState.exportId}',
          Icons.tag,
        ),
        if (downloadState.fileName != null)
          _buildDetailRow(
            theme,
            'File Name',
            downloadState.fileName!,
            Icons.file_present,
          ),
      ]);
    } else if (widget.state is ExportCreating) {
      final createState = widget.state as ExportCreating;
      details.addAll([
        _buildDetailRow(theme, 'Type', createState.exportType, Icons.category),
        _buildDetailRow(
          theme,
          'Format',
          createState.config.format.toUpperCase(),
          Icons.description,
        ),
      ]);
    }

    return details;
  }

  Widget _buildDetailRow(
    ThemeData theme,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: color ?? theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: color ?? theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for state analysis
  (IconData, String, Color) _getHeaderInfo(ThemeData theme) {
    switch (widget.state.runtimeType) {
      case ExportCreating:
        return (Icons.build, 'Creating Export', Colors.blue[600]!);
      case ExportDownloading:
        return (Icons.download, 'Downloading', Colors.orange[600]!);
      case BatchDownloadProgress:
        return (Icons.cloud_download, 'Batch Download', Colors.purple[600]!);
      case ExportLoading:
        return (Icons.hourglass_empty, 'Processing', Colors.grey[600]!);
      default:
        return (Icons.sync, 'Processing', theme.colorScheme.primary);
    }
  }

  LinearGradient _getGradientForState(ThemeData theme) {
    final color = _getHeaderInfo(theme).$3;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [color.withOpacity(0.05), Colors.transparent],
    );
  }

  String _getSubtitle() {
    switch (widget.state.runtimeType) {
      case ExportCreating:
        return 'Preparing your export job...';
      case ExportDownloading:
        return 'Downloading export file...';
      case BatchDownloadProgress:
        final state = widget.state as BatchDownloadProgress;
        return 'Downloading ${state.totalItems} files...';
      case ExportLoading:
        final state = widget.state as ExportLoading;
        return state.message ?? 'Please wait...';
      default:
        return 'Processing request...';
    }
  }

  bool _shouldShowSpinner() {
    return widget.state is ExportCreating ||
        widget.state is ExportDownloading ||
        (widget.state is BatchDownloadProgress &&
            !(widget.state as BatchDownloadProgress).isCompleted) ||
        widget.state is ExportLoading;
  }

  bool _shouldShowProgressBar() {
    return widget.state is ExportDownloading ||
        widget.state is BatchDownloadProgress;
  }

  bool _shouldShowDetails() {
    return widget.state is BatchDownloadProgress ||
        widget.state is ExportDownloading ||
        widget.state is ExportCreating;
  }

  double _getProgress() {
    if (widget.state is ExportDownloading) {
      final state = widget.state as ExportDownloading;
      return state.progress ?? 0.0;
    } else if (widget.state is BatchDownloadProgress) {
      final state = widget.state as BatchDownloadProgress;
      return state.progress;
    }
    return 0.0;
  }

  Color _getProgressColor(ThemeData theme) {
    if (widget.state is BatchDownloadProgress) {
      final state = widget.state as BatchDownloadProgress;
      if (state.hasErrors) return Colors.orange[600]!;
    }
    return _getHeaderInfo(theme).$3;
  }

  IconData _getStatusIcon() {
    switch (widget.state.runtimeType) {
      case ExportCreating:
        return Icons.settings;
      case ExportDownloading:
        return Icons.download;
      case BatchDownloadProgress:
        return Icons.queue_play_next;
      case ExportLoading:
        return Icons.sync;
      default:
        return Icons.info;
    }
  }

  Color _getStatusColor(ThemeData theme) {
    if (widget.state is BatchDownloadProgress) {
      final state = widget.state as BatchDownloadProgress;
      if (state.hasErrors) return Colors.orange[600]!;
    }
    return theme.colorScheme.primary;
  }

  String _getStatusMessage() {
    if (widget.state is ExportCreating) {
      return 'Setting up export configuration and validating data...';
    } else if (widget.state is ExportDownloading) {
      final state = widget.state as ExportDownloading;
      if (state.progress != null) {
        return 'Downloading file... ${(state.progress! * 100).toInt()}% complete';
      }
      return 'Preparing download...';
    } else if (widget.state is BatchDownloadProgress) {
      final state = widget.state as BatchDownloadProgress;
      if (state.isCompleted) {
        return 'Batch download completed! ${state.completedItems} files processed.';
      }
      return 'Processing ${state.completedItems} of ${state.totalItems} files...';
    } else if (widget.state is ExportLoading) {
      final state = widget.state as ExportLoading;
      return state.message ?? 'Processing your request...';
    }
    return 'Working on your request...';
  }

  bool _canCancel() {
    return widget.onCancel != null &&
        (widget.state is ExportCreating ||
            widget.state is ExportDownloading ||
            (widget.state is BatchDownloadProgress &&
                !(widget.state as BatchDownloadProgress).isCompleted));
  }

  bool _canRetry() {
    return widget.onRetry != null && widget.state is ExportError;
  }

  bool _isCompleted() {
    return widget.state is ExportDownloadCompleted ||
        (widget.state is BatchDownloadProgress &&
            (widget.state as BatchDownloadProgress).isCompleted);
  }

  bool _shouldShowMinimize() {
    return widget.state is ExportCreating ||
        widget.state is ExportDownloading ||
        (widget.state is BatchDownloadProgress &&
            !(widget.state as BatchDownloadProgress).isCompleted);
  }

  void _handleDownloadComplete() {
    // Handle completion - could navigate to results page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export completed successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _minimizeProgress() {
    // Could implement minimizing to a floating widget
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Progress minimized. Check notifications for updates.'),
      ),
    );
  }
}
