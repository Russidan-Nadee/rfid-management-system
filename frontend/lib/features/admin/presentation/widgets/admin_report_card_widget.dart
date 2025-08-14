import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../di/injection.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../l10n/features/admin/admin_localizations.dart';
import 'admin_action_dialog.dart';

class AdminReportCardWidget extends StatelessWidget {
  final dynamic report;
  final VoidCallback? onReportUpdated;

  const AdminReportCardWidget({super.key, required this.report, this.onReportUpdated});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                    _getStatusText(context, report['status']),
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
                    _getPriorityText(context, report['priority']),
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
              report['subject'] ?? 'No Subject',
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
              report['description'] ?? 'No Description',
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
                      _getProblemTypeText(context, report['problem_type']),
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
                  'Reported: ${_formatDate(report['created_at'])}',
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
                    'Updated: ${_formatDate(report['updated_at'])}',
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
                          'Acknowledged: ${_formatDate(report['acknowledged_at'])}${_getAcknowledgerName(context, report)}',
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
                          'Resolved: ${_formatDate(report['resolved_at'])}${_getResolverName(context, report)}',
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

            // Admin Action Buttons (only show for pending/acknowledged reports)
            if (_shouldShowAdminActions(report['status'])) ...[
              AppSpacing.verticalSpaceSM,
              _buildAdminActions(context, report),
            ],
          ],
        ),
      ),
    );
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
                shape: RoundedRectangleBorder(borderRadius: AppBorders.sm),
              ),
              child: Text('Acknowledge', style: AppTextStyles.caption.copyWith(color: Colors.white)),
            ),
          ),
          const SizedBox(width: 8),
          // Reject button
          Expanded(
            child: ElevatedButton(
              onPressed: () => _showAdminActionDialog(context, report, 'reject'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: AppBorders.sm),
              ),
              child: Text('Reject', style: AppTextStyles.caption.copyWith(color: Colors.white)),
            ),
          ),
        ] else if (status == 'acknowledged' || status == 'in_progress') ...[
          // Complete button for acknowledged/in_progress reports
          Expanded(
            child: ElevatedButton(
              onPressed: () => _showAdminActionDialog(context, report, 'complete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: AppBorders.sm),
              ),
              child: Text('Complete', style: AppTextStyles.caption.copyWith(color: Colors.white)),
            ),
          ),
          const SizedBox(width: 8),
          // Reject button (still available)
          Expanded(
            child: ElevatedButton(
              onPressed: () => _showAdminActionDialog(context, report, 'reject'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: AppBorders.sm),
              ),
              child: Text('Reject', style: AppTextStyles.caption.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ],
    );
  }
  
  void _showAdminActionDialog(BuildContext context, dynamic report, String action) {
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

  Future<void> _handleDirectAcknowledge(BuildContext context, dynamic report) async {
    try {
      final notificationService = getIt<NotificationService>();
      
      final response = await notificationService.updateNotificationStatus(
        report['notification_id'],
        status: 'in_progress',
      );

      if (response.success) {
        Helpers.showSuccess(context, 'Report acknowledged and moved to in-progress');
        if (onReportUpdated != null) {
          onReportUpdated!();
        }
      } else {
        Helpers.showError(context, response.message ?? 'Failed to acknowledge report');
      }
    } catch (e) {
      Helpers.showError(context, 'Error acknowledging report: $e');
    }
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

  String _getStatusText(BuildContext context, String status) {
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

  String _getPriorityText(BuildContext context, String priority) {
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

  String _getProblemTypeText(BuildContext context, String problemType) {
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