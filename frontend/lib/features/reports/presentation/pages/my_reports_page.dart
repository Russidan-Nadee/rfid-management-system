import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../di/injection.dart';
import '../bloc/reports_bloc.dart';
import '../bloc/reports_event.dart';
import '../bloc/reports_state.dart';
import '../../../../l10n/features/reports/reports_localizations.dart';
import '../types/view_mode.dart';
import '../widgets/view_mode_toggle.dart';
import '../widgets/reports_card_view.dart';
import '../widgets/reports_table_view.dart';

class MyReportsPage extends StatelessWidget {
  const MyReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ReportsBloc>()..add(const LoadMyReports()),
      child: const MyReportsPageView(),
    );
  }
}

class MyReportsPageView extends StatefulWidget {
  const MyReportsPageView({super.key});

  @override
  State<MyReportsPageView> createState() => _MyReportsPageViewState();
}

class _MyReportsPageViewState extends State<MyReportsPageView> {
  ViewMode _viewMode = ViewMode.card;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = ReportsLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkSurface.withValues(alpha: 0.5)
          : theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.myReportsTitle,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.primary,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: isDark ? AppColors.darkText : AppColors.primary,
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          ViewModeToggle(
            currentMode: _viewMode,
            onModeChanged: (ViewMode mode) {
              setState(() {
                _viewMode = mode;
              });
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              context.read<ReportsBloc>().add(const RefreshMyReports());
            },
            icon: Icon(
              Icons.refresh,
              color: isDark ? AppColors.darkText : AppColors.primary,
            ),
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading) {
            return _buildLoadingView(l10n);
          } else if (state is ReportsLoaded) {
            if (state.reports.isEmpty) {
              return _buildEmptyView(context, l10n);
            }
            return _buildReportsView(context, state.reports);
          } else if (state is ReportsError) {
            return _buildErrorView(context, l10n, state.message);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingView(ReportsLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(l10n.loadingReports),
        ],
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context, ReportsLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              padding: AppSpacing.paddingXXL,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.primarySurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? AppColors.darkBorder.withValues(alpha: 0.3)
                      : AppColors.primary.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.assignment_outlined,
                color: isDark ? AppColors.darkText : AppColors.primary,
                size: 60,
              ),
            ),
            AppSpacing.verticalSpaceXXL,
            Text(
              l10n.noReportsFoundUser,
              style: AppTextStyles.headline4.copyWith(
                color: isDark ? AppColors.darkText : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.verticalSpaceLG,
            Text(
              l10n.noReportsFound,
              style: AppTextStyles.body2.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(
    BuildContext context,
    ReportsLocalizations l10n,
    String message,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              padding: AppSpacing.paddingXXL,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.error.withValues(alpha: 0.2)
                    : AppColors.errorLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.error_outline,
                color: AppColors.error.withValues(alpha: 0.8),
                size: 60,
              ),
            ),
            AppSpacing.verticalSpaceXXL,
            Text(
              l10n.errorLoadingReports,
              style: AppTextStyles.headline4.copyWith(
                color: isDark ? AppColors.darkText : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.verticalSpaceLG,
            Container(
              padding: AppSpacing.paddingLG,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.error.withValues(alpha: 0.1)
                    : AppColors.errorLight,
                borderRadius: AppBorders.md,
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                message,
                style: AppTextStyles.body2.copyWith(
                  color: isDark
                      ? AppColors.darkText
                      : AppColors.error.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            AppSpacing.verticalSpaceXXL,
            ElevatedButton.icon(
              onPressed: () {
                context.read<ReportsBloc>().add(const LoadMyReports());
              },
              icon: const Icon(Icons.refresh, color: AppColors.onPrimary),
              label: Text(
                l10n.tryAgain,
                style: AppTextStyles.button.copyWith(
                  color: AppColors.onPrimary,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: AppSpacing.buttonPaddingSymmetric,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppBorders.md,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsView(BuildContext context, List<dynamic> reports) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ReportsBloc>().add(const RefreshMyReports());
      },
      child: _viewMode.isCard
        ? ReportsCardView(reports: reports)
        : SingleChildScrollView(
            padding: AppSpacing.screenPaddingAll,
            child: ReportsTableView(reports: reports),
          ),
    );
  }
}

