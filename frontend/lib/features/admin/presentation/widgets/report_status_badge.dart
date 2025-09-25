import 'package:flutter/material.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../l10n/features/reports/reports_localizations.dart';

class ReportStatusBadge extends StatelessWidget {
  final String status;
  final ReportsLocalizations reportsL10n;

  const ReportStatusBadge({
    super.key,
    required this.status,
    required this.reportsL10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: AppBorders.sm,
      ),
      child: Text(
        _getStatusText(reportsL10n, status),
        style: AppTextStyles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'acknowledged':
        return Colors.blue;
      case 'in_progress':
        return Colors.purple;
      case 'resolved':
        return Colors.green;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(ReportsLocalizations reportsL10n, String status) {
    switch (status) {
      case 'pending':
        return reportsL10n.pending;
      case 'acknowledged':
        return reportsL10n.acknowledgedStatus;
      case 'in_progress':
        return reportsL10n.inProgress;
      case 'resolved':
        return reportsL10n.resolvedStatus;
      case 'cancelled':
        return reportsL10n.cancelled;
      default:
        return status.replaceAll('_', ' ').toUpperCase();
    }
  }
}