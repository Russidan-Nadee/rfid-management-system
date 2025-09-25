import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../core/utils/helpers.dart';
import 'admin_action_dialog.dart';

class AdminReportsTableView extends StatelessWidget {
  final List<dynamic> reports;
  final VoidCallback onReportUpdated;

  const AdminReportsTableView({
    super.key,
    required this.reports,
    required this.onReportUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
        ),
        child: DataTable(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceVariant
                : theme.colorScheme.surface,
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
          dataRowMinHeight: 70,
          dataRowMaxHeight: 90,
          columnSpacing: 20,
          horizontalMargin: 16,
          columns: const [
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Priority')),
            DataColumn(label: SizedBox(width: 250, child: Text('Subject'))),
            DataColumn(label: Text('Problem Type')),
            DataColumn(label: Text('Asset No')),
            DataColumn(label: Text('Reporter')),
            DataColumn(label: Text('Reported')),
            DataColumn(label: Text('Actions')),
          ],
          rows: reports.map<DataRow>((report) {
            return DataRow(
              color: WidgetStateProperty.resolveWith<Color?>((
                Set<WidgetState> states,
              ) {
                if (states.contains(WidgetState.hovered)) {
                  return isDark
                      ? AppColors.darkSurfaceVariant.withValues(alpha: 0.5)
                      : AppColors.primarySurface.withValues(alpha: 0.1);
                }
                return null;
              }),
              cells: [
                // Status
                DataCell(_buildStatusChip(report['status'])),

                // Priority
                DataCell(_buildPriorityChip(report['priority'])),

                // Subject
                DataCell(
                  SizedBox(
                    width: 250,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report['subject'] ?? 'No Subject',
                          style: AppTextStyles.body2.copyWith(
                            color: isDark
                                ? AppColors.darkText
                                : AppColors.textPrimary,
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
                      Flexible(
                        child: Text(
                          _getProblemTypeText(report['problem_type']),
                          style: AppTextStyles.caption.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
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
                            color: isDark
                                ? AppColors.darkText
                                : AppColors.textPrimary,
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

                // Reporter
                DataCell(
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (report['reporter'] != null &&
                          report['reporter']['full_name'] != null) ...[
                        Text(
                          report['reporter']['full_name'],
                          style: AppTextStyles.body2.copyWith(
                            color: isDark
                                ? AppColors.darkText
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (report['reporter']['employee_id'] != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'ID: ${report['reporter']['employee_id']}',
                            style: AppTextStyles.caption.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
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
                    _formatDate(report['created_at']),
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),

                // Actions
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _buildActionButtons(context, report),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: AppBorders.sm,
      ),
      child: Text(
        _getStatusText(status),
        style: AppTextStyles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String priority) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getPriorityColor(priority),
        borderRadius: AppBorders.sm,
      ),
      child: Text(
        _getPriorityText(priority),
        style: AppTextStyles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons(BuildContext context, dynamic report) {
    List<Widget> buttons = [];
    final status = report['status'];

    if (status == 'pending') {
      buttons.addAll([
        _buildActionButton(
          context,
          report,
          'acknowledge',
          Icons.check_circle_outline,
          Colors.blue,
          'Ack',
        ),
        const SizedBox(width: 4),
        _buildActionButton(
          context,
          report,
          'reject',
          Icons.cancel_outlined,
          Colors.red,
          'Reject',
        ),
      ]);
    } else if (status == 'acknowledged' || status == 'in_progress') {
      buttons.add(
        _buildActionButton(
          context,
          report,
          'complete',
          Icons.task_alt,
          Colors.green,
          'Complete',
        ),
      );
    }

    return buttons.isEmpty
        ? [Text('-', style: AppTextStyles.caption.copyWith(color: Colors.grey))]
        : buttons;
  }

  Widget _buildActionButton(
    BuildContext context,
    dynamic report,
    String action,
    IconData icon,
    Color color,
    String label,
  ) {
    return SizedBox(
      width: 70,
      height: 28,
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AdminActionDialog(
              report: report,
              action: action,
              onActionCompleted: onReportUpdated,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          textStyle: const TextStyle(fontSize: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12),
            const SizedBox(width: 2),
            Text(label),
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

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'acknowledged':
        return 'Acknowledged';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'cancelled':
        return 'Cancelled';
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

  String _getPriorityText(String priority) {
    switch (priority) {
      case 'low':
        return 'Low';
      case 'normal':
        return 'Normal';
      case 'high':
        return 'High';
      case 'critical':
        return 'Critical';
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

  String _getProblemTypeText(String problemType) {
    switch (problemType) {
      case 'asset_damage':
        return 'Asset Damage';
      case 'asset_missing':
        return 'Missing Asset';
      case 'location_issue':
        return 'Location Issue';
      case 'data_error':
        return 'Data Error';
      case 'urgent_issue':
        return 'Urgent Issue';
      case 'other':
        return 'Other';
      default:
        return problemType.replaceAll('_', ' ').toUpperCase();
    }
  }

  String _formatDate(dynamic dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      final DateTime date = DateTime.parse(dateTime.toString());
      return Helpers.formatDate(date);
    } catch (e) {
      return dateTime.toString();
    }
  }
}
