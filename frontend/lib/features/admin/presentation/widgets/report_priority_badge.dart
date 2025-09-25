import 'package:flutter/material.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../l10n/features/reports/reports_localizations.dart';

class ReportPriorityBadge extends StatelessWidget {
  final String priority;
  final ReportsLocalizations reportsL10n;

  const ReportPriorityBadge({
    super.key,
    required this.priority,
    required this.reportsL10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getPriorityColor(priority),
        borderRadius: AppBorders.sm,
      ),
      child: Text(
        _getPriorityText(reportsL10n, priority),
        style: AppTextStyles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'low':
        return Colors.green;
      case 'normal':
        return Colors.blue;
      case 'high':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityText(ReportsLocalizations reportsL10n, String priority) {
    switch (priority) {
      case 'low':
        return reportsL10n.low;
      case 'normal':
        return reportsL10n.normal;
      case 'high':
        return reportsL10n.high;
      case 'critical':
        return reportsL10n.critical;
      default:
        return priority.toUpperCase();
    }
  }
}