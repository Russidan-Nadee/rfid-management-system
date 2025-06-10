// Path: frontend/lib/features/export/presentation/widgets/export_history_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/helpers.dart';
import '../../domain/entities/export_job_entity.dart';
import '../bloc/export_bloc.dart';
import '../bloc/export_event.dart';
import '../bloc/export_state.dart';

class ExportHistoryWidget extends StatelessWidget {
  const ExportHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExportBloc, ExportState>(
      builder: (context, state) {
        if (state is ExportLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ExportHistoryLoaded) {
          final exports = state.exports;
          if (exports.isEmpty) {
            return const Center(child: Text('No export history.'));
          }
          return ListView.builder(
            itemCount: exports.length,
            itemBuilder: (context, index) {
              final export = exports[index];
              return ListTile(
                title: Text('Export ID: ${export.exportId}'),
                subtitle: Text('Status: ${export.status}'),
                trailing: Text(_getDisplayName(export)),
              );
            },
          );
        } else if (state is ExportError) {
          return Center(child: Text('Error: ${state.message}'));
        } else {
          return const SizedBox(); // default หรือ ExportInitial
        }
      },
    );
  }

  String _getDisplayName(ExportJobEntity export) {
    final String? format;
    // ถ้ามี downloadUrl ให้ extract filename
    if (export.downloadUrl != null) {
      final segments = export.downloadUrl!.split('/');
      if (segments.isNotEmpty) {
        final filename = segments.last;
        // ลบ extension ออก
        final nameWithoutExt = filename
            .replaceAll('.xlsx', '')
            .replaceAll('.csv', '');
        return nameWithoutExt;
      }
    }

    // ถ้าไม่มี downloadUrl ให้ใช้ export type
    return export.exportTypeLabel;
  }

  Widget _buildHistoryList(
    BuildContext context,
    List<ExportJobEntity> exports,
  ) {
    if (exports.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ExportBloc>().add(const LoadExportHistory());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: exports.length,
        itemBuilder: (context, index) {
          return _buildExportCard(context, exports[index]);
        },
      ),
    );
  }

  Widget _buildExportCard(BuildContext context, ExportJobEntity export) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _getDisplayName(export),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                _buildStatusBadge(theme, export),
              ],
            ),

            const SizedBox(height: 12),

            _buildDetailRow(
              theme,
              Icons.access_time,
              'Created',
              Helpers.formatDateTime(export.createdAt),
            ),

            if (export.totalRecords != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow(
                theme,
                Icons.storage,
                'Records',
                Helpers.formatNumber(export.totalRecords!),
              ),
            ],

            if (export.fileSize != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow(
                theme,
                Icons.file_download,
                'File Size',
                export.fileSizeFormatted,
              ),
            ],

            if (export.isCompleted && !export.isExpired) ...[
              const SizedBox(height: 8),
              _buildDetailRow(
                theme,
                Icons.schedule,
                'Expires',
                Helpers.formatDateTime(export.expiresAt),
              ),
            ],

            if (export.errorMessage != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow(
                theme,
                Icons.error_outline,
                'Error',
                export.errorMessage!,
                color: Colors.red,
              ),
            ],

            if (export.canDownload) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<ExportBloc>().add(
                      DownloadExport(export.exportId),
                    );
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Download & Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme, ExportJobEntity export) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    if (export.isCompleted) {
      backgroundColor = export.isExpired ? Colors.grey : Colors.green;
      textColor = Colors.white;
      icon = export.isExpired ? Icons.schedule : Icons.check_circle;
    } else if (export.isFailed) {
      backgroundColor = Colors.red;
      textColor = Colors.white;
      icon = Icons.error;
    } else {
      backgroundColor = Colors.blue;
      textColor = Colors.white;
      icon = Icons.hourglass_empty;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            export.isExpired ? 'Expired' : export.statusLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Row(
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
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color ?? theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

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
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first export to see it here',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading history',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<ExportBloc>().add(const LoadExportHistory());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
