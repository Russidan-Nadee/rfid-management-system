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
        child: _UniformCardGrid(
          reports: reports,
          onReportUpdated: () {
            context.read<ReportsBloc>().add(const RefreshMyReports());
          },
        ),
      ),
    );
  }
}

// Auto-adjusting grid where each row height adjusts to its tallest card
class _UniformCardGrid extends StatelessWidget {
  final List<dynamic> reports;
  final VoidCallback onReportUpdated;

  const _UniformCardGrid({
    required this.reports,
    required this.onReportUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive column count based on screen width
        int crossAxisCount;
        
        if (constraints.maxWidth >= 1200) {
          crossAxisCount = 4; // Extra large screens: 4 columns
        } else if (constraints.maxWidth >= 900) {
          crossAxisCount = 3; // Large screens: 3 columns
        } else if (constraints.maxWidth >= 600) {
          crossAxisCount = 2; // Medium screens: 2 columns
        } else {
          crossAxisCount = 1; // Small screens: 1 column
        }

        return _buildAutoAdjustingGrid(crossAxisCount: crossAxisCount);
      },
    );
  }

  Widget _buildAutoAdjustingGrid({required int crossAxisCount}) {
    final rows = <Widget>[];
    
    // Group reports into rows
    for (int i = 0; i < reports.length; i += crossAxisCount) {
      final rowReports = <dynamic>[];
      
      // Collect reports for this row
      for (int j = 0; j < crossAxisCount; j++) {
        final index = i + j;
        if (index < reports.length) {
          rowReports.add(reports[index]);
        }
      }
      
      // Create row with IntrinsicHeight to auto-adjust height
      rows.add(
        Container(
          margin: EdgeInsets.only(bottom: i + crossAxisCount < reports.length ? 16 : 0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: rowReports.asMap().entries.map((entry) {
                final j = entry.key;
                final report = entry.value;
                
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      right: j < rowReports.length - 1 ? 16 : 0,
                    ),
                    child: ReportCardWidget(
                      report: report,
                      onReportUpdated: onReportUpdated,
                    ),
                  ),
                );
              }).toList() +
              // Add empty spaces for incomplete rows
              List.generate(crossAxisCount - rowReports.length, (index) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      right: (rowReports.length + index) < crossAxisCount - 1 ? 16 : 0,
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      );
    }
    
    return SingleChildScrollView(
      child: Column(children: rows),
    );
  }
}