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
import '../../../../l10n/features/export/export_localizations.dart';

class ExportHistoryWidget extends StatelessWidget {
  const ExportHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= AppConstants.tabletBreakpoint;
    final locale = ExportLocalizations.of(context);

    return BlocListener<ExportBloc, ExportState>(
      listener: (context, state) {
        if (state is ExportHistoryDownloadSuccess) {
          Helpers.showSuccess(
            context,
            '${locale.fileShared}: ${state.fileName}',
          );
        } else if (state is ExportError) {
          Helpers.showError(
            context,
            '${locale.errorGeneric}: ${state.message}',
          );
        }
      },
      child: BlocBuilder<ExportBloc, ExportState>(
        builder: (context, state) {
          if (state is ExportLoading) {
            return _buildLoadingState(context, isLargeScreen, locale);
          } else if (state is ExportHistoryLoaded) {
            return _buildHistoryList(
              context,
              state.exports,
              isLargeScreen,
              locale,
            );
          } else if (state is ExportHistoryDownloadSuccess) {
            return _buildHistoryList(
              context,
              state.exports,
              isLargeScreen,
              locale,
            );
          } else if (state is ExportError) {
            return _buildErrorState(
              context,
              state.message,
              isLargeScreen,
              locale,
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }

  Widget _buildLoadingState(
    BuildContext context,
    bool isLargeScreen,
    ExportLocalizations locale,
  ) {
    final theme = Theme.of(context);

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
                color: Theme.of(context).brightness == Brightness.dark
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary,
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
              locale.loadingExportHistory,
              style: AppTextStyles.responsive(
                context: context,
                style: AppTextStyles.body1.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkTextSecondary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
    ExportLocalizations locale,
  ) {
    if (exports.isEmpty) {
      return _buildEmptyState(context, isLargeScreen, locale);
    }

    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ExportBloc>().add(const LoadExportHistory());
      },
      color: Theme.of(context).brightness == Brightness.dark
          ? theme.colorScheme.primary
          : theme.colorScheme.primary,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurface
          : theme.colorScheme.surface,
      child: _buildResponsiveLayout(context, exports, isLargeScreen, locale),
    );
  }

  Widget _buildResponsiveLayout(
    BuildContext context,
    List<ExportJobEntity> exports,
    bool isLargeScreen,
    ExportLocalizations locale,
  ) {
    if (isLargeScreen) {
      return _buildGridLayout(context, exports, locale);
    } else {
      return _buildListLayout(context, exports, locale);
    }
  }

  Widget _buildGridLayout(
    BuildContext context,
    List<ExportJobEntity> exports,
    ExportLocalizations locale,
  ) {
    return Container(
      width: double.infinity,
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
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
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

  Widget _buildListLayout(
    BuildContext context,
    List<ExportJobEntity> exports,
    ExportLocalizations locale,
  ) {
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

  Widget _buildEmptyState(
    BuildContext context,
    bool isLargeScreen,
    ExportLocalizations locale,
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
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkSurfaceVariant
                    : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: AppBorders.circular,
              ),
              child: Icon(
                Icons.history,
                size: isLargeScreen ? 80 : 64,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextMuted
                    : theme.colorScheme.onSurface.withValues(alpha: 0.4),
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
              locale.noExportHistory,
              style: AppTextStyles.responsive(
                context: context,
                style: AppTextStyles.headline4.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkText
                      : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                desktopFactor: 1.2,
              ),
            ),
            AppSpacing.verticalSpaceSM,
            Text(
              locale.createFirstExport,
              style: AppTextStyles.responsive(
                context: context,
                style: AppTextStyles.body1.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkTextSecondary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkSurfaceVariant
                    : theme.colorScheme.primary.withValues(alpha: 0.05),
                borderRadius: AppBorders.md,
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkBorder.withValues(alpha: 0.3)
                      : theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primary,
                    size: isLargeScreen ? 20 : 16,
                  ),
                  AppSpacing.horizontalSpaceSM,
                  Flexible(
                    child: Text(
                      locale.goToCreateExportTab,
                      style: AppTextStyles.responsive(
                        context: context,
                        style: AppTextStyles.body2.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary,
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
    ExportLocalizations locale,
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
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.error.withValues(alpha: 0.1)
                    : theme.colorScheme.errorContainer.withValues(alpha: 0.5),
                borderRadius: AppBorders.circular,
              ),
              child: Icon(
                Icons.error_outline,
                size: isLargeScreen ? 80 : 64,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.error
                    : theme.colorScheme.error,
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
              locale.errorLoadingHistory,
              style: AppTextStyles.responsive(
                context: context,
                style: AppTextStyles.headline4.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkText
                      : theme.colorScheme.onSurface,
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
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.error.withValues(alpha: 0.1)
                    : theme.colorScheme.errorContainer.withValues(alpha: 0.5),
                borderRadius: AppBorders.md,
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.error.withValues(alpha: 0.3)
                      : theme.colorScheme.error.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                message,
                style: AppTextStyles.responsive(
                  context: context,
                  style: AppTextStyles.body1.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.error
                        : theme.colorScheme.error,
                  ),
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
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.onPrimary
                      : AppColors.onPrimary,
                  size: isLargeScreen ? 20 : 18,
                ),
                label: Text(
                  locale.retry,
                  style: AppTextStyles.responsive(
                    context: context,
                    style: AppTextStyles.button.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.onPrimary
                          : AppColors.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    desktopFactor: 1.1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary,
                  foregroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? AppColors.onPrimary
                      : AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.lg,
                  ),
                  shape: const RoundedRectangleBorder(borderRadius: AppBorders.lg),
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
