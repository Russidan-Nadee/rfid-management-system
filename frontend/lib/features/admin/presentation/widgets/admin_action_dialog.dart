import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../di/injection.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../l10n/features/admin/admin_localizations.dart';

class AdminActionDialog extends StatefulWidget {
  final dynamic report;
  final String action; // 'acknowledge', 'complete', 'reject'
  final VoidCallback onActionCompleted;

  const AdminActionDialog({
    super.key,
    required this.report,
    required this.action,
    required this.onActionCompleted,
  });

  @override
  State<AdminActionDialog> createState() => _AdminActionDialogState();
}

class _AdminActionDialogState extends State<AdminActionDialog> {
  final TextEditingController _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _actionTitle(AdminLocalizations l10n) {
    switch (widget.action) {
      case 'acknowledge':
        return l10n.acknowledgeReportTitle;
      case 'complete':
        return l10n.completeReportTitle;
      case 'reject':
        return l10n.rejectReportTitle;
      default:
        return l10n.updateReportTitle;
    }
  }

  String _actionDescription(AdminLocalizations l10n) {
    switch (widget.action) {
      case 'acknowledge':
        return l10n.acknowledgeDescription;
      case 'complete':
        return l10n.completeDescription;
      case 'reject':
        return l10n.rejectDescription;
      default:
        return l10n.updateDescription;
    }
  }

  Color get _actionColor {
    switch (widget.action) {
      case 'acknowledge':
        return Colors.blue;
      case 'complete':
        return Colors.green;
      case 'reject':
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }

  String get _targetStatus {
    switch (widget.action) {
      case 'acknowledge':
        return 'in_progress'; // Changed from 'acknowledged' to 'in_progress' as requested
      case 'complete':
        return 'resolved';
      case 'reject':
        return 'cancelled';
      default:
        return widget.report['status'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AdminLocalizations.of(context);

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppBorders.lg),
      child: Container(
        width: 400,
        padding: AppSpacing.paddingXL,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : theme.colorScheme.surface,
          borderRadius: AppBorders.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _actionColor.withValues(alpha: 0.1),
                    borderRadius: AppBorders.md,
                  ),
                  child: Icon(
                    _getActionIcon(),
                    color: _actionColor,
                    size: 24,
                  ),
                ),
                AppSpacing.horizontalSpaceMD,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _actionTitle(l10n),
                        style: AppTextStyles.headline6.copyWith(
                          color: isDark ? AppColors.darkText : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSpacing.verticalSpaceXS,
                      Text(
                        '${l10n.reportNumber}${widget.report['notification_id']}',
                        style: AppTextStyles.body2.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            AppSpacing.verticalSpaceLG,

            // Report Summary
            Container(
              padding: AppSpacing.paddingMD,
              decoration: BoxDecoration(
                color: isDark 
                    ? AppColors.darkSurfaceVariant.withValues(alpha: 0.5)
                    : AppColors.backgroundSecondary,
                borderRadius: AppBorders.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.report['subject'] ?? l10n.noSubject,
                    style: AppTextStyles.body1.copyWith(
                      color: isDark ? AppColors.darkText : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppSpacing.verticalSpaceXS,
                  Text(
                    widget.report['description'] ?? l10n.noDescription,
                    style: AppTextStyles.body2.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.report['asset_no'] != null) ...[
                    AppSpacing.verticalSpaceXS,
                    Text(
                      '${l10n.asset}: ${widget.report['asset_no']}',
                      style: AppTextStyles.caption.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            AppSpacing.verticalSpaceLG,

            // Description
            Text(
              _actionDescription(l10n),
              style: AppTextStyles.body2.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),

            AppSpacing.verticalSpaceLG,

            // Note Input (required for complete/reject)
            if (widget.action == 'complete' || widget.action == 'reject') ...[
              Text(
                widget.action == 'complete' ? l10n.resolutionNoteRequired : l10n.rejectionReasonRequired,
                style: AppTextStyles.body2.copyWith(
                  color: isDark ? AppColors.darkText : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacing.verticalSpaceSM,
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: widget.action == 'complete' 
                      ? l10n.resolutionNotePlaceholder
                      : l10n.rejectionReasonPlaceholder,
                  border: const OutlineInputBorder(borderRadius: AppBorders.md),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppBorders.md,
                    borderSide: BorderSide(color: _actionColor),
                  ),
                ),
                style: AppTextStyles.body2,
              ),
              AppSpacing.verticalSpaceLG,
            ] else if (widget.action == 'acknowledge') ...[
              Text(
                l10n.acknowledgmentNoteOptional,
                style: AppTextStyles.body2.copyWith(
                  color: isDark ? AppColors.darkText : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacing.verticalSpaceSM,
              TextField(
                controller: _noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: l10n.acknowledgmentNotePlaceholder,
                  border: const OutlineInputBorder(borderRadius: AppBorders.md),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppBorders.md,
                    borderSide: BorderSide(color: _actionColor),
                  ),
                ),
                style: AppTextStyles.body2,
              ),
              AppSpacing.verticalSpaceLG,
            ],

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: AppSpacing.buttonPaddingSymmetric,
                      shape: const RoundedRectangleBorder(borderRadius: AppBorders.md),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: AppTextStyles.button.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                AppSpacing.horizontalSpaceMD,
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _actionColor,
                      foregroundColor: Colors.white,
                      padding: AppSpacing.buttonPaddingSymmetric,
                      shape: const RoundedRectangleBorder(borderRadius: AppBorders.md),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _getActionButtonText(l10n),
                            style: AppTextStyles.button.copyWith(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActionIcon() {
    switch (widget.action) {
      case 'acknowledge':
        return Icons.check_circle_outline;
      case 'complete':
        return Icons.task_alt_outlined;
      case 'reject':
        return Icons.cancel_outlined;
      default:
        return Icons.edit_outlined;
    }
  }

  String _getActionButtonText(AdminLocalizations l10n) {
    switch (widget.action) {
      case 'acknowledge':
        return l10n.acknowledgeButton;
      case 'complete':
        return l10n.markCompleteButton;
      case 'reject':
        return l10n.rejectReportButton;
      default:
        return l10n.updateButton;
    }
  }

  Future<void> _handleSubmit() async {
    final l10n = AdminLocalizations.of(context);
    
    // Validate required fields
    if ((widget.action == 'complete' || widget.action == 'reject') && 
        _noteController.text.trim().isEmpty) {
      Helpers.showError(
        context, 
        widget.action == 'complete' 
            ? l10n.pleaseProvideResolution
            : l10n.pleaseProvideRejection
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final notificationService = getIt<NotificationService>();
      
      print('🔍 Admin Action: ${widget.action} for report #${widget.report['notification_id']}');
      print('🔍 Target Status: $_targetStatus');
      print('🔍 Note: ${_noteController.text.trim().isNotEmpty ? _noteController.text.trim() : "None"}');

      // Call the API to update notification status
      final response = await notificationService.updateNotificationStatus(
        widget.report['notification_id'],
        status: _targetStatus,
        resolutionNote: (widget.action == 'complete' && _noteController.text.trim().isNotEmpty) 
            ? _noteController.text.trim() 
            : null,
        rejectionNote: (widget.action == 'reject' && _noteController.text.trim().isNotEmpty) 
            ? _noteController.text.trim() 
            : null,
      );

      print('🔍 Update Response: ${response.success ? "SUCCESS" : "FAILED"}');
      if (!response.success) {
        print('🔍 Error Message: ${response.message}');
      }

      if (response.success) {
        if (mounted) {
          Navigator.of(context).pop();
          Helpers.showSuccess(
            context,
            _getSuccessMessage(l10n),
          );
          widget.onActionCompleted();
        }
      } else {
        if (mounted) {
          Helpers.showError(context, response.message);
        }
      }
    } catch (e) {
      if (mounted) {
        Helpers.showError(context, 'Error updating report: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _getSuccessMessage(AdminLocalizations l10n) {
    switch (widget.action) {
      case 'acknowledge':
        return l10n.reportAcknowledgedMessage;
      case 'complete':
        return l10n.reportCompletedMessage;
      case 'reject':
        return l10n.reportRejectedMessage;
      default:
        return l10n.reportUpdatedMessage;
    }
  }
}