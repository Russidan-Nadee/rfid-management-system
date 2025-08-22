import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../l10n/features/reports/reports_localizations.dart';

class UserReportCardWidget extends StatelessWidget {
  final dynamic report;

  const UserReportCardWidget({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final reportsL10n = ReportsLocalizations.of(context);

    return Card(
      color: isDark ? AppColors.darkSurfaceVariant : theme.colorScheme.surface,
      elevation: isDark ? 1 : 2,
      shape: RoundedRectangleBorder(borderRadius: AppBorders.md),
      child: Padding(
        padding: AppSpacing.paddingSM,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(report['status']),
                    borderRadius: AppBorders.sm,
                  ),
                  child: Text(
                    _getStatusText(reportsL10n, report['status']),
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                // Priority Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(report['priority']),
                    borderRadius: AppBorders.sm,
                  ),
                  child: Text(
                    _getPriorityText(reportsL10n, report['priority']),
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
                      _getProblemTypeIcon(report['problem_type']),
                      color: isDark 
                          ? AppColors.darkTextSecondary 
                          : AppColors.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getProblemTypeText(reportsL10n, report['problem_type']),
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
                            if (report['asset_master'] != null && report['asset_master']['description'] != null) ...[
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
                   (report['asset_master']['location_code'] != null || report['asset_master']['plant_code'] != null)) ...[
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
                if (report['updated_at'] != null && report['updated_at'] != report['created_at']) ...[
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
                if (report['reporter'] != null && report['reporter']['full_name'] != null) ...[
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
                      Icon(
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
                      Icon(
                        Icons.task_alt,
                        color: Colors.green,
                        size: 12,
                      ),
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
            if (report['resolution_note'] != null && report['resolution_note'].toString().isNotEmpty) ...[
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
                    Icon(
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
            if (report['rejection_note'] != null && report['rejection_note'].toString().isNotEmpty) ...[
              AppSpacing.verticalSpaceSM,
              Container(
                padding: AppSpacing.paddingMD,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: AppBorders.sm,
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
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
          ],
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

  IconData _getProblemTypeIcon(String problemType) {
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

  String _getProblemTypeText(ReportsLocalizations reportsL10n, String problemType) {
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