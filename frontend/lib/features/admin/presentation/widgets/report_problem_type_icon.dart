import 'package:flutter/material.dart';
import '../../../../l10n/features/reports/reports_localizations.dart';

class ReportProblemTypeHelper {
  static IconData getProblemTypeIcon(String problemType) {
    switch (problemType) {
      case 'asset_damage':
        return Icons.broken_image_outlined;
      case 'asset_missing':
        return Icons.search_off_outlined;
      case 'location_issue':
        return Icons.location_off_outlined;
      case 'data_error':
        return Icons.error_outline;
      case 'urgent_issue':
        return Icons.priority_high_outlined;
      case 'other':
        return Icons.help_outline;
      default:
        return Icons.report_problem_outlined;
    }
  }

  static String getProblemTypeText(
    ReportsLocalizations reportsL10n,
    String problemType,
  ) {
    switch (problemType) {
      case 'asset_damage':
        return reportsL10n.assetDamage;
      case 'asset_missing':
        return reportsL10n.missingAsset;
      case 'location_issue':
        return reportsL10n.locationIssue;
      case 'data_error':
        return reportsL10n.dataError;
      case 'urgent_issue':
        return reportsL10n.urgentIssue;
      case 'other':
        return reportsL10n.other;
      default:
        return problemType.replaceAll('_', ' ').toUpperCase();
    }
  }
}