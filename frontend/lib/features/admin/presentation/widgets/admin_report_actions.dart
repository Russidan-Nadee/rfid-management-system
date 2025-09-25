import 'package:flutter/material.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../di/injection.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../l10n/features/reports/reports_localizations.dart';
import 'admin_action_dialog.dart';

class AdminReportActions extends StatelessWidget {
  final dynamic report;
  final VoidCallback? onReportUpdated;

  const AdminReportActions({
    super.key,
    required this.report,
    this.onReportUpdated,
  });

  @override
  Widget build(BuildContext context) {
    if (!_shouldShowAdminActions(report['status'])) {
      return const SizedBox.shrink();
    }

    return _buildAdminActions(context, report);
  }

  bool _shouldShowAdminActions(String status) {
    // Show admin buttons for pending, acknowledged, and in_progress statuses
    return ['pending', 'acknowledged', 'in_progress'].contains(status);
  }

  Widget _buildAdminActions(BuildContext context, dynamic report) {
    final status = report['status'];

    return Row(
      children: [
        if (status == 'pending') ...[
          // Acknowledge button for pending reports
          Expanded(
            child: ElevatedButton(
              onPressed: () => _handleDirectAcknowledge(context, report),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppBorders.sm,
                ),
              ),
              child: Text(
                ReportsLocalizations.of(context).acknowledge,
                style: AppTextStyles.caption.copyWith(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Reject button
          Expanded(
            child: ElevatedButton(
              onPressed: () =>
                  _showAdminActionDialog(context, report, 'reject'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppBorders.sm,
                ),
              ),
              child: Text(
                ReportsLocalizations.of(context).reject,
                style: AppTextStyles.caption.copyWith(color: Colors.white),
              ),
            ),
          ),
        ] else if (status == 'acknowledged' || status == 'in_progress') ...[
          // Complete button for acknowledged/in_progress reports
          Expanded(
            child: ElevatedButton(
              onPressed: () =>
                  _showAdminActionDialog(context, report, 'complete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppBorders.sm,
                ),
              ),
              child: Text(
                ReportsLocalizations.of(context).complete,
                style: AppTextStyles.caption.copyWith(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Reject button (still available)
          Expanded(
            child: ElevatedButton(
              onPressed: () =>
                  _showAdminActionDialog(context, report, 'reject'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppBorders.sm,
                ),
              ),
              child: Text(
                ReportsLocalizations.of(context).reject,
                style: AppTextStyles.caption.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showAdminActionDialog(
    BuildContext context,
    dynamic report,
    String action,
  ) {
    showDialog(
      context: context,
      builder: (context) => AdminActionDialog(
        report: report,
        action: action,
        onActionCompleted: () {
          // Refresh the reports list
          Navigator.of(context).pop();
          if (onReportUpdated != null) {
            onReportUpdated!();
          }
        },
      ),
    );
  }

  Future<void> _handleDirectAcknowledge(
    BuildContext context,
    dynamic report,
  ) async {
    try {
      final notificationService = getIt<NotificationService>();

      final response = await notificationService.updateNotificationStatus(
        report['notification_id'],
        status: 'in_progress',
      );

      if (response.success) {
        if (context.mounted) {
          Helpers.showSuccess(
            context,
            'Report acknowledged and moved to in-progress',
          );
        }
        if (onReportUpdated != null) {
          onReportUpdated!();
        }
      } else {
        if (context.mounted) {
          Helpers.showError(context, response.message);
        }
      }
    } catch (e) {
      if (context.mounted) {
        Helpers.showError(context, 'Error acknowledging report: $e');
      }
    }
  }
}