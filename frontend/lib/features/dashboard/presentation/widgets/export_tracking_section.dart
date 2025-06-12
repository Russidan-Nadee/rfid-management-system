// Path: frontend/lib/features/dashboard/presentation/widgets/export_tracking_section.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/recent_activity.dart';
import 'dashboard_card.dart';

class ExportTrackingSection extends StatelessWidget {
  final List<RecentExport> recentExports;
  final VoidCallback? onViewAll;

  const ExportTrackingSection({
    super.key,
    required this.recentExports,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardSection(
      title: 'Export Tracking',
      icon: Icons.file_download,
      onViewAll: onViewAll,
      children: recentExports.isEmpty
          ? [_buildEmptyState()]
          : recentExports
                .take(5)
                .map((export) => _buildExportItem(export))
                .toList(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.file_download_outlined,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            'No recent export activities',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportItem(RecentExport export) {
    final statusData = _getStatusData(export.status);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Status icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: statusData.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(statusData.icon, size: 16, color: statusData.color),
          ),

          const SizedBox(width: 12),

          // Export info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  export.typeLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onBackground,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusData.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: statusData.color.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        export.statusLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: statusData.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${export.totalRecords} records',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'by ${export.userName}',
                  style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Time and file size
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTime(export.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              if (export.fileSize != null) ...[
                const SizedBox(height: 2),
                Text(
                  export.fileSize!,
                  style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  _ExportStatusData _getStatusData(String status) {
    switch (status.toUpperCase()) {
      case 'C':
      case 'COMPLETED':
        return _ExportStatusData(
          color: AppColors.exportCompleted,
          icon: Icons.check_circle,
        );
      case 'P':
      case 'PENDING':
        return _ExportStatusData(
          color: AppColors.exportPending,
          icon: Icons.hourglass_empty,
        );
      case 'F':
      case 'FAILED':
        return _ExportStatusData(
          color: AppColors.exportFailed,
          icon: Icons.error,
        );
      default:
        return _ExportStatusData(
          color: AppColors.textSecondary,
          icon: Icons.help,
        );
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}

class _ExportStatusData {
  final Color color;
  final IconData icon;

  const _ExportStatusData({required this.color, required this.icon});
}

// Compact version for smaller spaces
class ExportTrackingCompact extends StatelessWidget {
  final List<RecentExport> recentExports;
  final int maxItems;

  const ExportTrackingCompact({
    super.key,
    required this.recentExports,
    this.maxItems = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (recentExports.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No recent exports',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: recentExports
          .take(maxItems)
          .map((export) => _buildCompactItem(export))
          .toList(),
    );
  }

  Widget _buildCompactItem(RecentExport export) {
    final statusColor = _getStatusColor(export.status);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(_getStatusIcon(export.status), size: 14, color: statusColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${export.typeLabel} (${export.statusLabel})',
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${export.totalRecords} records',
            style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    return AppColors.getExportStatusColor(status);
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'C':
      case 'COMPLETED':
        return Icons.check_circle;
      case 'P':
      case 'PENDING':
        return Icons.hourglass_empty;
      case 'F':
      case 'FAILED':
        return Icons.error;
      default:
        return Icons.help;
    }
  }
}
