// Path: frontend/lib/features/dashboard/presentation/widgets/asset_monitoring_section.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/recent_activity.dart';
import 'dashboard_card.dart';

class AssetMonitoringSection extends StatelessWidget {
  final List<RecentScan> recentScans;
  final VoidCallback? onViewAll;

  const AssetMonitoringSection({
    super.key,
    required this.recentScans,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardSection(
      title: 'Asset Monitoring',
      icon: Icons.monitor,
      onViewAll: onViewAll,
      children: recentScans.isEmpty
          ? [_buildEmptyState()]
          : recentScans.take(5).map((scan) => _buildScanItem(scan)).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(Icons.qr_code_scanner, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          Text(
            'No recent scan activities',
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

  Widget _buildScanItem(RecentScan scan) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Scan icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.qr_code_scanner, size: 16, color: AppColors.info),
          ),

          const SizedBox(width: 12),

          // Asset info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scan.assetNo,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onBackground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  scan.assetDescription,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 12,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      scan.location,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Time and user info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTime(scan.scannedAt),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                scan.scannedBy,
                style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
              ),
            ],
          ),
        ],
      ),
    );
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

// Compact version for smaller spaces
class AssetMonitoringCompact extends StatelessWidget {
  final List<RecentScan> recentScans;
  final int maxItems;

  const AssetMonitoringCompact({
    super.key,
    required this.recentScans,
    this.maxItems = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (recentScans.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No recent scans',
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
      children: recentScans
          .take(maxItems)
          .map((scan) => _buildCompactItem(scan))
          .toList(),
    );
  }

  Widget _buildCompactItem(RecentScan scan) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.qr_code_scanner, size: 14, color: AppColors.info),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${scan.assetNo} - ${scan.assetDescription}',
              style: const TextStyle(fontSize: 12),
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

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h';
    } else {
      return '${diff.inDays}d';
    }
  }
}
