// Path: frontend/lib/features/dashboard/presentation/widgets/alerts_section.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/alert.dart';
import 'dashboard_card.dart';

class AlertsSection extends StatelessWidget {
  final List<Alert> alerts;
  final int maxItems;
  final VoidCallback? onViewAll;

  const AlertsSection({
    super.key,
    required this.alerts,
    this.maxItems = 5,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayAlerts = alerts.take(maxItems).toList();
    final hasMoreAlerts = alerts.length > maxItems;

    return DashboardCard(
      backgroundColor: _getAlertBackgroundColor(),
      showBorder: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.warning, size: 20, color: _getHeaderIconColor()),
              const SizedBox(width: 8),
              const Text(
                'System Alerts',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onBackground,
                ),
              ),
              const Spacer(),
              if (hasMoreAlerts || onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text(
                    hasMoreAlerts ? 'View All (${alerts.length})' : 'View All',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Alerts list
          ...displayAlerts.map((alert) => _buildAlertItem(alert)),
        ],
      ),
    );
  }

  Widget _buildAlertItem(Alert alert) {
    final severityData = _getSeverityData(alert.severity);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: severityData.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: severityData.borderColor, width: 1),
      ),
      child: Row(
        children: [
          // Severity icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: severityData.iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              severityData.icon,
              size: 16,
              color: severityData.iconColor,
            ),
          ),

          const SizedBox(width: 12),

          // Alert content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Alert type badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: severityData.iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getTypeLabel(alert.type),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: severityData.iconColor,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Severity badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: severityData.iconColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        alert.severity.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Alert message
                Text(
                  alert.message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.onBackground,
                  ),
                ),
              ],
            ),
          ),

          // Count badge (if applicable)
          if (alert.hasCount) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: severityData.iconColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                alert.count.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  _AlertSeverityData _getSeverityData(String severity) {
    switch (severity.toLowerCase()) {
      case 'error':
        return _AlertSeverityData(
          iconColor: AppColors.severityError,
          backgroundColor: AppColors.errorLight,
          borderColor: AppColors.severityError.withOpacity(0.3),
          icon: Icons.error,
        );
      case 'warning':
        return _AlertSeverityData(
          iconColor: AppColors.severityWarning,
          backgroundColor: AppColors.warningLight,
          borderColor: AppColors.severityWarning.withOpacity(0.3),
          icon: Icons.warning,
        );
      case 'info':
      default:
        return _AlertSeverityData(
          iconColor: AppColors.severityInfo,
          backgroundColor: AppColors.infoLight,
          borderColor: AppColors.severityInfo.withOpacity(0.3),
          icon: Icons.info,
        );
    }
  }

  String _getTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'export':
        return 'Export';
      case 'asset':
        return 'Asset';
      case 'scan':
        return 'Scan';
      case 'data_quality':
        return 'Data';
      case 'system':
        return 'System';
      default:
        return 'Alert';
    }
  }

  Color _getAlertBackgroundColor() {
    if (alerts.isEmpty) return AppColors.surface;

    final hasError = alerts.any((alert) => alert.isError);
    final hasWarning = alerts.any((alert) => alert.isWarning);

    if (hasError) {
      return AppColors.errorLight.withOpacity(0.3);
    } else if (hasWarning) {
      return AppColors.warningLight.withOpacity(0.3);
    } else {
      return AppColors.surface;
    }
  }

  Color _getHeaderIconColor() {
    if (alerts.isEmpty) return AppColors.primary;

    final hasError = alerts.any((alert) => alert.isError);
    final hasWarning = alerts.any((alert) => alert.isWarning);

    if (hasError) {
      return AppColors.severityError;
    } else if (hasWarning) {
      return AppColors.severityWarning;
    } else {
      return AppColors.severityInfo;
    }
  }
}

class _AlertSeverityData {
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final IconData icon;

  const _AlertSeverityData({
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.icon,
  });
}

// Compact version for smaller spaces
class AlertsSectionCompact extends StatelessWidget {
  final List<Alert> alerts;
  final int maxItems;

  const AlertsSectionCompact({
    super.key,
    required this.alerts,
    this.maxItems = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayAlerts = alerts.take(maxItems).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.warning, size: 16, color: _getHeaderIconColor()),
            const SizedBox(width: 6),
            Text(
              'Alerts (${alerts.length})',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.onBackground,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...displayAlerts.map((alert) => _buildCompactAlertItem(alert)),
      ],
    );
  }

  Widget _buildCompactAlertItem(Alert alert) {
    final severityColor = AppColors.getSeverityColor(alert.severity);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: severityColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              alert.message,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.onBackground,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (alert.hasCount) ...[
            const SizedBox(width: 4),
            Text(
              '(${alert.count})',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getHeaderIconColor() {
    if (alerts.isEmpty) return AppColors.primary;

    final hasError = alerts.any((alert) => alert.isError);
    final hasWarning = alerts.any((alert) => alert.isWarning);

    if (hasError) {
      return AppColors.severityError;
    } else if (hasWarning) {
      return AppColors.severityWarning;
    } else {
      return AppColors.severityInfo;
    }
  }
}
