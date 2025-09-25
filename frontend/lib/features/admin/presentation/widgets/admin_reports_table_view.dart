import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../di/injection.dart';
import '../../../../core/services/notification_service.dart';
import 'admin_action_dialog.dart';
import 'asset_edit_dialog.dart';
import 'admin_report_card_widget.dart';
import '../../data/datasources/admin_remote_datasource.dart';
import '../../data/repositories/admin_repository_impl.dart';

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
          showCheckboxColumn: false,
          columns: const [
            DataColumn(
              label: SizedBox(
                width: 120,
                child: Center(child: Text('Actions')),
              ),
            ), // Combined actions column
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Priority')),
            DataColumn(label: SizedBox(width: 250, child: Text('Subject'))),
            DataColumn(label: Text('Problem Type')),
            DataColumn(label: Text('Asset No')),
            DataColumn(label: Text('Reporter')),
            DataColumn(label: Text('Reported')),
          ],
          rows: reports.map<DataRow>((report) {
            return DataRow(
              onSelectChanged: (_) => _showReportCardDialog(context, report),
              color: WidgetStateProperty.resolveWith<Color?>((
                Set<WidgetState> states,
              ) {
                if (states.contains(WidgetState.hovered)) {
                  return isDark
                      ? AppColors.darkSurfaceVariant.withValues(alpha: 0.5)
                      : AppColors.primarySurface.withValues(alpha: 0.1);
                }
                if (states.contains(WidgetState.selected)) {
                  return isDark
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : AppColors.primary.withValues(alpha: 0.1);
                }
                return null;
              }),
              cells: [
                // Combined Actions
                DataCell(_buildCombinedActions(context, report)),

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

  Widget _buildCombinedActions(BuildContext context, dynamic report) {
    final status = report['status'];
    final actions = _getAvailableActions(status);
    final hasAsset =
        report['asset_no'] != null && report['asset_no'].toString().isNotEmpty;
    final canEdit = status != 'cancelled' && status != 'resolved';

    if (actions.isEmpty) {
      return (hasAsset && canEdit)
          ? _buildEditShortcut(context, report)
          : const Text('-', style: TextStyle(color: Colors.grey));
    }

    // Create 2x2 grid layout with tall edit icon
    return SizedBox(
      width: 130, // Increased width to accommodate longer button text
      child: Row(
        children: [
          // Left column: Action buttons
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildActionButton(context, report, actions[0]),
                const SizedBox(height: 2),
                actions.length > 1
                    ? _buildActionButton(context, report, actions[1])
                    : const SizedBox(height: 24), // Empty space
              ],
            ),
          ),
          const SizedBox(width: 4),
          // Right column: Tall edit icon or dash
          if (hasAsset && canEdit)
            _buildTallEditShortcut(context, report)
          else
            Container(
              width: 50,
              height: 50,
              child: const Center(
                child: Text('-', style: TextStyle(color: Colors.grey)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEditShortcut(BuildContext context, dynamic report) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        onTap: () => _showReportDialog(context, report),
        borderRadius: BorderRadius.circular(4),
        child: const Icon(Icons.edit_outlined, color: Colors.white, size: 14),
      ),
    );
  }

  Widget _buildTallEditShortcut(BuildContext context, dynamic report) {
    return Container(
      width: 50,
      height: 50, // Square - same width and height
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        onTap: () => _showReportDialog(context, report),
        borderRadius: BorderRadius.circular(4),
        child: const Center(
          child: Icon(Icons.edit_outlined, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    dynamic report,
    String action,
  ) {
    final actionInfo = _getActionInfo(action);
    return SizedBox(
      width: 60,
      height: 24,
      child: ElevatedButton(
        onPressed: () {
          if (action == 'acknowledge') {
            _handleDirectAcknowledge(context, report);
          } else {
            _showActionDialog(context, report, action);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: actionInfo['color'] as Color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          minimumSize: const Size(60, 24),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        ),
        child: Text(
          _getActionShortLabel(action),
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context, dynamic report) async {
    final assetNo = report['asset_no']?.toString();

    if (assetNo == null || assetNo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No asset number found in this report'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Load real asset data without showing loading dialog first
      final adminDatasource = AdminRemoteDatasourceImpl();
      final repository = AdminRepositoryImpl(remoteDataSource: adminDatasource);
      final asset = await repository.getAssetByNo(assetNo);

      if (asset == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Asset $assetNo not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Show asset edit dialog with real asset data
      if (context.mounted) {
        showDialog(
          context: context,
          barrierColor: Colors.black.withValues(alpha: 0.7),
          builder: (context) => AssetEditDialog(
            asset: asset,
            onUpdate: (updateRequest) async {
              try {
                // Actually call the backend API to update the asset
                final adminDatasource = AdminRemoteDatasourceImpl();
                final repository = AdminRepositoryImpl(
                  remoteDataSource: adminDatasource,
                );

                await repository.updateAsset(updateRequest);

                // Call refresh callback after successful update
                onReportUpdated();
              } catch (e) {
                throw e;
              }
            },
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load asset: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getActionShortLabel(String action) {
    switch (action) {
      case 'acknowledge':
        return 'Acknowledge';
      case 'reject':
        return 'Reject';
      case 'complete':
        return 'Complete';
      default:
        return action.toUpperCase();
    }
  }

  List<String> _getAvailableActions(String status) {
    switch (status) {
      case 'pending':
        return ['acknowledge', 'reject'];
      case 'acknowledged':
      case 'in_progress':
        return ['complete', 'reject'];
      default:
        return [];
    }
  }

  Map<String, dynamic> _getActionInfo(String action) {
    switch (action) {
      case 'acknowledge':
        return {
          'icon': Icons.check_circle_outline,
          'label': 'Acknowledge',
          'color': Colors.blue,
        };
      case 'reject':
        return {
          'icon': Icons.cancel_outlined,
          'label': 'Reject',
          'color': Colors.red,
        };
      case 'complete':
        return {
          'icon': Icons.task_alt,
          'label': 'Complete',
          'color': Colors.green,
        };
      default:
        return {
          'icon': Icons.help_outline,
          'label': action,
          'color': Colors.grey,
        };
    }
  }

  void _handleDirectAcknowledge(BuildContext context, dynamic report) async {
    try {
      final notificationService = getIt<NotificationService>();

      final response = await notificationService.updateNotificationStatus(
        report['notification_id'],
        status: 'in_progress',
      );

      if (response.success) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report acknowledged and moved to in-progress'),
              backgroundColor: Colors.green,
            ),
          );
        }
        onReportUpdated();
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error acknowledging report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showActionDialog(BuildContext context, dynamic report, String action) {
    showDialog(
      context: context,
      builder: (context) => AdminActionDialog(
        report: report,
        action: action,
        onActionCompleted: onReportUpdated,
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

  void _showReportCardDialog(BuildContext context, dynamic report) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => Dialog(
        shape: const RoundedRectangleBorder(borderRadius: AppBorders.lg),
        child: IntrinsicHeight(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(16),
            child: AdminReportCardWidget(
              report: report,
              onReportUpdated: onReportUpdated,
            ),
          ),
        ),
      ),
    );
  }
}
