import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../l10n/features/reports/reports_localizations.dart';

class ReportsTableView extends StatelessWidget {
  final List<dynamic> reports;

  const ReportsTableView({super.key, required this.reports});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final reportsL10n = ReportsLocalizations.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
        ),
        child: DataTable(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceVariant : theme.colorScheme.surface,
            borderRadius: AppBorders.md,
          ),
          headingRowColor: WidgetStateProperty.all(
            isDark
              ? AppColors.darkSurfaceVariant.withValues(alpha: 0.7)
              : AppColors.primarySurface.withValues(alpha: 0.3),
          ),
          headingTextStyle: AppTextStyles.body2.copyWith(
            color: isDark ? AppColors.darkText : AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
          dataTextStyle: AppTextStyles.body2.copyWith(
            color: isDark ? AppColors.darkText : AppColors.textPrimary,
          ),
          headingRowHeight: 56,
          dataRowMinHeight: 60,
          dataRowMaxHeight: 80,
          columnSpacing: 24,
          horizontalMargin: 16,
          columns: const [
            DataColumn(
              label: Text('Status'),
            ),
            DataColumn(
              label: Text('Priority'),
            ),
            DataColumn(
              label: SizedBox(
                width: 200,
                child: Text('Subject'),
              ),
            ),
            DataColumn(
              label: Text('Problem Type'),
            ),
            DataColumn(
              label: Text('Asset No'),
            ),
            DataColumn(
              label: Text('Reported'),
            ),
            DataColumn(
              label: Text('ID'),
            ),
          ],
          rows: reports.map<DataRow>((report) {
            return DataRow(
              color: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.hovered)) {
                    return isDark
                      ? AppColors.darkSurfaceVariant.withValues(alpha: 0.5)
                      : AppColors.primarySurface.withValues(alpha: 0.1);
                  }
                  return null;
                },
              ),
              cells: [
                // Status
                DataCell(
                  _buildStatusChip(report['status'], reportsL10n),
                ),
                // Priority
                DataCell(
                  _buildPriorityChip(report['priority'], reportsL10n),
                ),
                // Subject
                DataCell(
                  SizedBox(
                    width: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report['subject'] ?? reportsL10n.noSubject,
                          style: AppTextStyles.body2.copyWith(
                            color: isDark ? AppColors.darkText : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (report['description'] != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            report['description'],
                            style: AppTextStyles.caption.copyWith(
                              color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Problem Type
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getProblemTypeIcon(report['problem_type']),
                        size: 16,
                        color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getProblemTypeText(reportsL10n, report['problem_type']),
                        style: AppTextStyles.caption.copyWith(
                          color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Asset No
                DataCell(
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (report['asset_no'] != null) ...[
                        Text(
                          report['asset_no'],
                          style: AppTextStyles.body2.copyWith(
                            color: isDark ? AppColors.darkText : AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (report['asset_master'] != null &&
                            report['asset_master']['description'] != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            report['asset_master']['description'],
                            style: AppTextStyles.caption.copyWith(
                              color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ] else ...[
                        Text(
                          '-',
                          style: AppTextStyles.body2.copyWith(
                            color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Created Date
                DataCell(
                  Text(
                    _formatDate(report['created_at'], reportsL10n),
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    ),
                  ),
                ),
                // ID
                DataCell(
                  Text(
                    '#${report['notification_id']}',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, ReportsLocalizations reportsL10n) {
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

  Widget _buildPriorityChip(String priority, ReportsLocalizations reportsL10n) {
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
}