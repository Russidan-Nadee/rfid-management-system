import 'package:flutter/material.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../di/injection.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../l10n/features/reports/reports_localizations.dart';
import 'admin_action_dialog.dart';
import 'asset_edit_dialog.dart';
import '../../data/datasources/admin_remote_datasource.dart';
import '../../data/repositories/admin_repository_impl.dart';

class AdminReportActions extends StatelessWidget {
  final dynamic report;
  final VoidCallback? onReportUpdated;
  final bool isInDialog;

  const AdminReportActions({
    super.key,
    required this.report,
    this.onReportUpdated,
    this.isInDialog = false,
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

    return isInDialog
        ? Column(children: _buildActionButtons(context, status, report))
        : Row(children: _buildActionButtons(context, status, report));
  }

  List<Widget> _buildActionButtons(
    BuildContext context,
    String status,
    dynamic report,
  ) {
    List<Widget> buttons = [];

    if (status == 'pending') {
      // Acknowledge button for pending reports
      buttons.add(
        isInDialog
            ? SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleDirectAcknowledge(context, report),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: Text(ReportsLocalizations.of(context).acknowledge),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppBorders.sm,
                    ),
                  ),
                ),
              )
            : Expanded(
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
      );

      buttons.add(
        SizedBox(width: isInDialog ? 0 : 8, height: isInDialog ? 8 : 0),
      );

      // Reject button
      buttons.add(
        isInDialog
            ? SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _showAdminActionDialog(context, report, 'reject'),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: Text(ReportsLocalizations.of(context).reject),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppBorders.sm,
                    ),
                  ),
                ),
              )
            : Expanded(
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
      );
    } else if (status == 'acknowledged' || status == 'in_progress') {
      // Complete button for acknowledged/in_progress reports
      buttons.add(
        isInDialog
            ? SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _showAdminActionDialog(context, report, 'complete'),
                  icon: const Icon(Icons.task_alt, size: 18),
                  label: Text(ReportsLocalizations.of(context).complete),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppBorders.sm,
                    ),
                  ),
                ),
              )
            : Expanded(
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
      );

      buttons.add(
        SizedBox(width: isInDialog ? 0 : 8, height: isInDialog ? 8 : 0),
      );

      // Reject button (still available)
      buttons.add(
        isInDialog
            ? SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _showAdminActionDialog(context, report, 'reject'),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: Text(ReportsLocalizations.of(context).reject),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppBorders.sm,
                    ),
                  ),
                ),
              )
            : Expanded(
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
      );
    }

    // Add Edit button for all statuses (if asset_no exists)
    if (report['asset_no'] != null &&
        report['asset_no'].toString().isNotEmpty) {
      buttons.add(
        SizedBox(width: isInDialog ? 0 : 8, height: isInDialog ? 8 : 0),
      );

      buttons.add(
        isInDialog
            ? SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAssetEditDialog(context, report),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppBorders.sm,
                    ),
                  ),
                ),
              )
            : Expanded(
                child: ElevatedButton(
                  onPressed: () => _showAssetEditDialog(context, report),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppBorders.sm,
                    ),
                  ),
                  child: Text(
                    'Edit',
                    style: AppTextStyles.caption.copyWith(color: Colors.white),
                  ),
                ),
              ),
      );
    }

    return buttons;
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

  void _showAssetEditDialog(BuildContext context, dynamic report) async {
    final assetNo = report['asset_no']?.toString();

    if (assetNo == null || assetNo.isEmpty) {
      if (context.mounted) {
        Helpers.showError(context, 'No asset number found in this report');
      }
      return;
    }

    try {
      // Load real asset data
      final adminDatasource = AdminRemoteDatasourceImpl();
      final repository = AdminRepositoryImpl(remoteDataSource: adminDatasource);
      final asset = await repository.getAssetByNo(assetNo);

      if (asset == null) {
        if (context.mounted) {
          Helpers.showError(context, 'Asset $assetNo not found');
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
                // Update asset via API
                await repository.updateAsset(updateRequest);

                // Call refresh callback after successful update
                if (onReportUpdated != null) {
                  onReportUpdated!();
                }
              } catch (e) {
                throw e;
              }
            },
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Helpers.showError(context, 'Failed to load asset: $e');
      }
    }
  }
}
