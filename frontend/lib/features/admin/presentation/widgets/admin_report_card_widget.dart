import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../l10n/features/reports/reports_localizations.dart';
import 'report_status_badge.dart';
import 'report_priority_badge.dart';
import 'report_problem_type_icon.dart';
import 'admin_report_actions.dart';

class AdminReportCardWidget extends StatelessWidget {
  final dynamic report;
  final VoidCallback? onReportUpdated;

  const AdminReportCardWidget({
    super.key,
    required this.report,
    this.onReportUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final reportsL10n = ReportsLocalizations.of(context);

    return Card(
      color: isDark ? AppColors.darkSurfaceVariant : theme.colorScheme.surface,
      elevation: isDark ? 1 : 2,
      shape: const RoundedRectangleBorder(borderRadius: AppBorders.md),
      child: Padding(
        padding: AppSpacing.paddingSM,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Status Badge
                ReportStatusBadge(
                  status: report['status'],
                  reportsL10n: reportsL10n,
                ),
                const Spacer(),
                // Priority Badge
                ReportPriorityBadge(
                  priority: report['priority'],
                  reportsL10n: reportsL10n,
                ),
              ],
            ),

            AppSpacing.verticalSpaceSM,

            // Subject
            Text(
              report['subject'] ?? reportsL10n.noSubject,
              style: AppTextStyles.body1.copyWith(
                color: isDark ? AppColors.darkText : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            AppSpacing.verticalSpaceSM,

            // Description
            Text(
              report['description'] ?? reportsL10n.noDescription,
              style: AppTextStyles.caption.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                fontSize: 12,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            AppSpacing.verticalSpaceSM,

            // Problem Type & Asset
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      ReportProblemTypeHelper.getProblemTypeIcon(report['problem_type']),
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      ReportProblemTypeHelper.getProblemTypeText(reportsL10n, report['problem_type']),
                      style: AppTextStyles.body2.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                // Asset Information
                if (report['asset_no'] != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.qr_code,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              report['asset_no'],
                              style: AppTextStyles.body2.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (report['asset_master'] != null &&
                                report['asset_master']['description'] !=
                                    null) ...[
                              const SizedBox(height: 2),
                              Text(
                                report['asset_master']['description'],
                                style: AppTextStyles.caption.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],

                // Location Information
                if (report['asset_master'] != null &&
                    (report['asset_master']['location_code'] != null ||
                        report['asset_master']['plant_code'] != null)) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${report['asset_master']['plant_code'] ?? ''} - ${report['asset_master']['location_code'] ?? ''}',
                        style: AppTextStyles.caption.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),

            AppSpacing.verticalSpaceSM,

            // Footer
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Report ID
                Text(
                  'ID: #${report['notification_id']}',
                  style: AppTextStyles.caption.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                // Created timestamp
                const SizedBox(height: 2),
                Text(
                  '${reportsL10n.reportedLabel}: ${_formatDate(report['created_at'], reportsL10n)}',
                  style: AppTextStyles.caption.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),

                // Last updated
                if (report['updated_at'] != null &&
                    report['updated_at'] != report['created_at']) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${reportsL10n.updatedLabel}: ${_formatDate(report['updated_at'], reportsL10n)}',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],

                // Reporter Information
                if (report['reporter'] != null &&
                    report['reporter']['full_name'] != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Reported by: ${report['reporter']['full_name']}',
                        style: AppTextStyles.caption.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],

                // Acknowledgment info
                if (report['acknowledged_at'] != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.blue,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${reportsL10n.acknowledgedLabel}: ${_formatDate(report['acknowledged_at'], reportsL10n)}${_getAcknowledgerName(context, report)}',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // Resolution info
                if (report['resolved_at'] != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.task_alt, color: Colors.green, size: 12),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${reportsL10n.resolvedLabel}: ${_formatDate(report['resolved_at'], reportsL10n)}${_getResolverName(context, report)}',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),

            // Resolution Note (if available)
            if (report['resolution_note'] != null &&
                report['resolution_note'].toString().isNotEmpty) ...[
              AppSpacing.verticalSpaceSM,
              Container(
                padding: AppSpacing.paddingMD,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: AppBorders.sm,
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        report['resolution_note'],
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Rejection Note (if available)
            if (report['rejection_note'] != null &&
                report['rejection_note'].toString().isNotEmpty) ...[
              AppSpacing.verticalSpaceSM,
              Container(
                padding: AppSpacing.paddingMD,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: AppBorders.sm,
                  border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.cancel_outlined,
                      color: Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Rejected: ${report['rejection_note']}',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Admin Action Buttons
            AppSpacing.verticalSpaceSM,
            AdminReportActions(
              report: report,
              onReportUpdated: onReportUpdated,
            ),
          ],
        ),
      ),
    );
  }


  String _formatDate(dynamic dateTime, ReportsLocalizations reportsL10n) {
    if (dateTime == null) return reportsL10n.notAvailable;
    try {
      final DateTime date = DateTime.parse(dateTime.toString());
      return Helpers.formatDate(date);
    } catch (e) {
      return dateTime.toString();
    }
  }

  String _getAcknowledgerName(BuildContext context, dynamic report) {
    final acknowledger = report['acknowledger'];
    if (acknowledger != null && acknowledger['full_name'] != null) {
      return ' by ${acknowledger['full_name']}';
    }
    return '';
  }

  String _getResolverName(BuildContext context, dynamic report) {
    final resolver = report['resolver'];
    if (resolver != null && resolver['full_name'] != null) {
      return ' by ${resolver['full_name']}';
    }
    return '';
  }
}
