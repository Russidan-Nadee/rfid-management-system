// Path: frontend/lib/features/export/presentation/widgets/export_history_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/app/theme/app_decorations.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/app_constants.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= AppConstants.tabletBreakpoint;

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
            return _buildLoadingState(context, isLargeScreen);
          } else if (state is ExportHistoryLoaded) {
            return _buildHistoryList(context, state.exports, isLargeScreen);
          } else if (state is ExportHistoryDownloadSuccess) {
            return _buildHistoryList(context, state.exports, isLargeScreen);
          } else if (state is ExportError) {
            return _buildErrorState(context, state.message, isLargeScreen);
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, bool isLargeScreen) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isLargeScreen ? 400 : double.infinity,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: isLargeScreen ? 48 : 40,
              height: isLargeScreen ? 48 : 40,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: isLargeScreen ? 4 : 3,
              ),
            ),
            SizedBox(
              height: AppSpacing.responsiveSpacing(
                context,
                mobile: AppSpacing.lg,
                tablet: AppSpacing.xl,
                desktop: AppSpacing.xl,
              ),
            ),
            Text(
              'Loading export history...',
              style: AppTextStyles.responsive(
                context: context,
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.textSecondary,
                ),
                desktopFactor: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    List<ExportJobEntity> exports,
    bool isLargeScreen,
  ) {
    if (exports.isEmpty) {
      return _buildEmptyState(context, isLargeScreen);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ExportBloc>().add(const LoadExportHistory());
      },
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: _buildResponsiveLayout(context, exports, isLargeScreen),
    );
  }

  Widget _buildResponsiveLayout(
    BuildContext context,
    List<ExportJobEntity> exports,
    bool isLargeScreen,
  ) {
    if (isLargeScreen) {
      return _buildGridLayout(context, exports);
    } else {
      return _buildListLayout(context, exports);
    }
  }

  Widget _buildGridLayout(BuildContext context, List<ExportJobEntity> exports) {
    return Container(
      width: double.infinity, // เต็มความกว้างหน้าจอ
      padding: EdgeInsets.all(
        AppSpacing.responsiveSpacing(
          context,
          mobile: AppSpacing.lg,
          tablet: AppSpacing.xl,
          desktop: AppSpacing.xxl,
        ),
      ),
      child: ListView.builder(
        itemCount: exports.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
            child: ExportItemCard(
              export: exports[index],
              isLargeScreen: true,
              onTap: () {
                context.read<ExportBloc>().add(
                  DownloadHistoryExport(exports[index].exportId),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildListLayout(BuildContext context, List<ExportJobEntity> exports) {
    return ListView.builder(
      padding: AppSpacing.screenPaddingAll,
      itemCount: exports.length,
      itemBuilder: (context, index) {
        return ExportItemCard(
          export: exports[index],
          isLargeScreen: false,
          onTap: () {
            context.read<ExportBloc>().add(
              DownloadHistoryExport(exports[index].exportId),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isLargeScreen) {
    final theme = Theme.of(context);
    final maxWidth = isLargeScreen ? 500.0 : double.infinity;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: EdgeInsets.all(
          AppSpacing.responsiveSpacing(
            context,
            mobile: AppSpacing.lg,
            tablet: AppSpacing.xl,
            desktop: AppSpacing.xxl,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(
                AppSpacing.responsiveSpacing(
                  context,
                  mobile: AppSpacing.xxl,
                  tablet: AppSpacing.xxxl,
                  desktop: AppSpacing.xxxxl,
                ),
              ),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: AppBorders.circular,
              ),
              child: Icon(
                Icons.history,
                size: isLargeScreen ? 80 : 64,
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(
              height: AppSpacing.responsiveSpacing(
                context,
                mobile: AppSpacing.xl,
                tablet: AppSpacing.xxl,
                desktop: AppSpacing.xxxl,
              ),
            ),
            Text(
              'No export history',
              style: AppTextStyles.responsive(
                context: context,
                style: AppTextStyles.headline4.copyWith(
                  color: theme.brightness == Brightness.dark
                      ? AppColors.onBackground
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                desktopFactor: 1.2,
              ),
            ),
            AppSpacing.verticalSpaceSM,
            Text(
              'Create your first export to see it here',
              style: AppTextStyles.responsive(
                context: context,
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.textSecondary,
                ),
                desktopFactor: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: AppSpacing.responsiveSpacing(
                context,
                mobile: AppSpacing.xl,
                tablet: AppSpacing.xxl,
                desktop: AppSpacing.xxxl,
              ),
            ),
            Container(
              padding: EdgeInsets.all(
                AppSpacing.responsiveSpacing(
                  context,
                  mobile: AppSpacing.md,
                  tablet: AppSpacing.lg,
                  desktop: AppSpacing.xl,
                ),
              ),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: AppBorders.md,
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: isLargeScreen ? 20 : 16,
                  ),
                  AppSpacing.horizontalSpaceSM,
                  Flexible(
                    child: Text(
                      'Go to Create Export tab to get started',
                      style: AppTextStyles.responsive(
                        context: context,
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        desktopFactor: 1.05,
                      ),
                      textAlign: TextAlign.center,
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

  Widget _buildErrorState(
    BuildContext context,
    String message,
    bool isLargeScreen,
  ) {
    final theme = Theme.of(context);
    final maxWidth = isLargeScreen ? 500.0 : double.infinity;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: EdgeInsets.all(
          AppSpacing.responsiveSpacing(
            context,
            mobile: AppSpacing.lg,
            tablet: AppSpacing.xl,
            desktop: AppSpacing.xxl,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(
                AppSpacing.responsiveSpacing(
                  context,
                  mobile: AppSpacing.xxl,
                  tablet: AppSpacing.xxxl,
                  desktop: AppSpacing.xxxxl,
                ),
              ),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: AppBorders.circular,
              ),
              child: Icon(
                Icons.error_outline,
                size: isLargeScreen ? 80 : 64,
                color: AppColors.error,
              ),
            ),
            SizedBox(
              height: AppSpacing.responsiveSpacing(
                context,
                mobile: AppSpacing.xl,
                tablet: AppSpacing.xxl,
                desktop: AppSpacing.xxxl,
              ),
            ),
            Text(
              'Error loading history',
              style: AppTextStyles.responsive(
                context: context,
                style: AppTextStyles.headline4.copyWith(
                  color: theme.brightness == Brightness.dark
                      ? AppColors.onBackground
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                desktopFactor: 1.2,
              ),
            ),
            AppSpacing.verticalSpaceSM,
            Container(
              padding: EdgeInsets.all(
                AppSpacing.responsiveSpacing(
                  context,
                  mobile: AppSpacing.md,
                  tablet: AppSpacing.lg,
                  desktop: AppSpacing.xl,
                ),
              ),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: AppBorders.md,
                border: Border.all(color: AppColors.error.withOpacity(0.2)),
              ),
              child: Text(
                message,
                style: AppTextStyles.responsive(
                  context: context,
                  style: AppTextStyles.body1.copyWith(color: AppColors.error),
                  desktopFactor: 1.05,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: AppSpacing.responsiveSpacing(
                context,
                mobile: AppSpacing.xl,
                tablet: AppSpacing.xxl,
                desktop: AppSpacing.xxxl,
              ),
            ),
            SizedBox(
              width: isLargeScreen ? 250 : 200,
              height: isLargeScreen ? 56 : 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<ExportBloc>().add(const LoadExportHistory());
                },
                icon: Icon(
                  Icons.refresh,
                  color: AppColors.onPrimary,
                  size: isLargeScreen ? 20 : 18,
                ),
                label: Text(
                  'Retry',
                  style: AppTextStyles.responsive(
                    context: context,
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    desktopFactor: 1.1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.lg,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: AppBorders.lg),
                  elevation: isLargeScreen ? 4 : 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
