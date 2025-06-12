// Path: frontend/lib/features/dashboard/presentation/widgets/recent_activities_section.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/recent_activity.dart';
import 'dashboard_card.dart'; // Import dashboard_card.dart because DashboardSection is defined there

class RecentActivitiesSection extends StatelessWidget {
  final RecentActivity recentActivities;
  final VoidCallback? onViewAll;

  const RecentActivitiesSection({
    super.key,
    required this.recentActivities,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final hasRecentScans = recentActivities.recentScans.isNotEmpty;
    final hasRecentExports = recentActivities.recentExports.isNotEmpty;

    if (!hasRecentScans && !hasRecentExports) {
      return const SizedBox.shrink(); // Hide if no activities
    }

    // Correctly use DashboardSection with its parameters
    return DashboardSection(
      // Changed from DashboardCard to DashboardSection
      title: 'Recent Activities',
      icon: Icons.history,
      onViewAll: onViewAll,
      children: [
        // DashboardSection takes a List<Widget> named 'children'
        if (hasRecentScans) ...[
          _buildActivityHeader(Icons.qr_code_scanner, 'Recent Scans'),
          _buildScanList(),
          if (hasRecentExports) const SizedBox(height: 16),
        ],
        if (hasRecentExports) ...[
          _buildActivityHeader(Icons.file_download, 'Recent Exports'),
          _buildExportList(),
        ],
      ],
    );
  }

  Widget _buildActivityHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onBackground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanList() {
    if (recentActivities.recentScans.isEmpty) {
      return _buildEmptyState('No recent scan activities.');
    }
    return Column(
      children: recentActivities.recentScans
          .take(3) // Display top 3 for brevity
          .map((scan) => _buildScanItem(scan))
          .toList(),
    );
  }

  Widget _buildExportList() {
    if (recentActivities.recentExports.isEmpty) {
      return _buildEmptyState('No recent export activities.');
    }
    return Column(
      children: recentActivities.recentExports
          .take(3) // Display top 3 for brevity
          .map((export) => _buildExportItem(export))
          .toList(),
    );
  }

  Widget _buildScanItem(RecentScan scan) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.qr_code_scanner, size: 14, color: AppColors.info),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${scan.assetNo} - ${scan.assetDescription}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.onBackground,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _formatTime(scan.scannedAt),
            style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildExportItem(RecentExport export) {
    final statusColor = AppColors.getExportStatusColor(export.status);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(_getStatusIcon(export.status), size: 14, color: statusColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${export.typeLabel} (${export.statusLabel}) - ${export.totalRecords} records',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.onBackground,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _formatTime(export.createdAt),
            style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year % 100}';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'C':
      case 'COMPLETED':
        return Icons.check_circle_outline;
      case 'F':
      case 'FAILED':
        return Icons.error_outline;
      case 'P':
      case 'PENDING':
        return Icons.hourglass_empty;
      default:
        return Icons.info_outline;
    }
  }
}
