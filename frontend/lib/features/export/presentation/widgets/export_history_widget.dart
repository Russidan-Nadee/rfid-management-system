// Path: frontend/lib/features/export/presentation/widgets/export_history_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/app/theme/app_decorations.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/helpers.dart';
import '../../domain/entities/export_job_entity.dart';
import '../bloc/export_bloc.dart';
import '../bloc/export_event.dart';
import '../bloc/export_state.dart';
import 'export_item_card.dart';

class ExportHistoryWidget extends StatelessWidget {
  const ExportHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExportBloc, ExportState>(
      listener: (context, state) {
        if (state is ExportHistoryDownloadSuccess) {
          Helpers.showSuccess(context, 'File shared: ${state.fileName}');
        } else if (state is ExportError) {
          Helpers.showError(context, 'Error: ${state.message}');
        }
      },
      child: BlocBuilder<ExportBloc, ExportState>(
        builder: (context, state) {
          if (state is ExportLoading) {
            return _buildLoadingState(context);
          } else if (state is ExportHistoryLoaded) {
            return _buildHistoryList(context, state.exports);
          } else if (state is ExportHistoryDownloadSuccess) {
            return _buildHistoryList(context, state.exports);
          } else if (state is ExportError) {
            return _buildErrorState(context, state.message);
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
          AppSpacing.verticalSpaceLG,
          Text(
            'Loading export history...',
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    List<ExportJobEntity> exports,
  ) {
    if (exports.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ExportBloc>().add(const LoadExportHistory());
      },
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: ListView.builder(
        padding: AppSpacing.screenPaddingAll,
        itemCount: exports.length,
        itemBuilder: (context, index) {
          return ExportItemCard(
            export: exports[index],
            onTap: () {
              context.read<ExportBloc>().add(
                DownloadHistoryExport(exports[index].exportId),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: AppSpacing.paddingXXL,
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: AppBorders.circular,
              ),
              child: Icon(Icons.history, size: 64, color: AppColors.textMuted),
            ),
            AppSpacing.verticalSpaceXL,
            Text(
              'No export history',
              style: AppTextStyles.headline5.copyWith(
                color: theme.brightness == Brightness.dark
                    ? AppColors.onBackground
                    : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.verticalSpaceSM,
            Text(
              'Create your first export to see it here',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSpaceXL,
            Container(
              padding: AppSpacing.paddingMD,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: AppBorders.md,
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary, size: 16),
                  AppSpacing.horizontalSpaceSM,
                  Text(
                    'Go to Create Export tab to get started',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: AppSpacing.paddingXXL,
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: AppBorders.circular,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
            ),
            AppSpacing.verticalSpaceXL,
            Text(
              'Error loading history',
              style: AppTextStyles.headline5.copyWith(
                color: theme.brightness == Brightness.dark
                    ? AppColors.onBackground
                    : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.verticalSpaceSM,
            Container(
              padding: AppSpacing.paddingMD,
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: AppBorders.md,
                border: Border.all(color: AppColors.error.withOpacity(0.2)),
              ),
              child: Text(
                message,
                style: AppTextStyles.body2.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ),
            AppSpacing.verticalSpaceXL,
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<ExportBloc>().add(const LoadExportHistory());
                },
                icon: Icon(Icons.refresh, color: AppColors.onPrimary),
                label: Text(
                  'Retry',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: AppSpacing.buttonPaddingSymmetric,
                  shape: RoundedRectangleBorder(borderRadius: AppBorders.md),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
