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
import '../widgets/report_card_widget.dart';

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

class MyReportsPageView extends StatelessWidget {
  const MyReportsPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkSurface.withValues(alpha: 0.5)
          : theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'My Reports',
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
          IconButton(
            onPressed: () {
              context.read<ReportsBloc>().add(const RefreshMyReports());
            },
            icon: Icon(
              Icons.refresh,
              color: isDark ? AppColors.darkText : AppColors.primary,
            ),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading) {
            return _buildLoadingView();
          } else if (state is ReportsLoaded) {
            if (state.reports.isEmpty) {
              return _buildEmptyView(context);
            }
            return _buildReportsView(context, state.reports);
          } else if (state is ReportsError) {
            return _buildErrorView(context, state.message);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading your reports...'),
        ],
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
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
              'No Reports Yet',
              style: AppTextStyles.headline4.copyWith(
                color: isDark ? AppColors.darkText : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.verticalSpaceLG,
            Text(
              'You haven\'t submitted any problem reports yet.\nWhen you report issues through the scan feature,\nthey will appear here.',
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

  Widget _buildErrorView(BuildContext context, String message) {
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
              'Error Loading Reports',
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
              icon: Icon(Icons.refresh, color: AppColors.onPrimary),
              label: Text(
                'Try Again',
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
      child: Padding(
        padding: AppSpacing.screenPaddingAll,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive column count based on screen width
            int crossAxisCount;
            double aspectRatio;
            
            if (constraints.maxWidth >= 1200) {
              // Extra large screens: 4 columns
              crossAxisCount = 4;
              aspectRatio = 1.1;
            } else if (constraints.maxWidth >= 900) {
              // Large screens: 3 columns
              crossAxisCount = 3;
              aspectRatio = 1.0;
            } else if (constraints.maxWidth >= 600) {
              // Medium screens: 2 columns
              crossAxisCount = 2;
              aspectRatio = 1.0;
            } else {
              // Small screens: 1 column
              crossAxisCount = 1;
              aspectRatio = 0.6;
            }
            
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16, // Space between columns
                mainAxisSpacing: 16, // Space between rows
                childAspectRatio: aspectRatio,
              ),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return ReportCardWidget(
                  report: report,
                  onReportUpdated: () {
                    // Refresh the reports list
                    context.read<ReportsBloc>().add(const RefreshMyReports());
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}