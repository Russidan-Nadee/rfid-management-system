// Path: frontend/lib/features/dashboard/presentation/widgets/department_growth_trend_widget.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../l10n/features/dashboard/dashboard_localizations.dart';
import '../../domain/entities/growth_trend.dart';
import 'common/dashboard_card.dart';
import 'common/empty_state.dart';
import 'common/loading_skeleton.dart';

class GrowthTrendChartWidget extends StatefulWidget {
  final GrowthTrend growthTrend;
  final bool isLoading;
  final String? selectedDeptCode;
  final List<Map<String, String>> availableDepartments;
  final Function(String?) onDeptChanged;

  const GrowthTrendChartWidget({
    super.key,
    required this.growthTrend,
    this.isLoading = false,
    this.selectedDeptCode,
    this.availableDepartments = const [],
    required this.onDeptChanged,
  });

  @override
  State<GrowthTrendChartWidget> createState() => _GrowthTrendChartWidgetState();
}

class _GrowthTrendChartWidgetState extends State<GrowthTrendChartWidget> {
  @override
  void initState() {
    super.initState();
    print(
      '✅ GrowthTrendChartWidget initState: Initial selectedDeptCode: ${widget.selectedDeptCode}',
    );
  }

  @override
  void didUpdateWidget(GrowthTrendChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDeptCode != oldWidget.selectedDeptCode) {
      print(
        '🟢 GrowthTrendChartWidget didUpdateWidget: selectedDeptCode changed from ${oldWidget.selectedDeptCode} to ${widget.selectedDeptCode}',
      );
    } else {
      print(
        '🟡 GrowthTrendChartWidget didUpdateWidget: selectedDeptCode is same (${widget.selectedDeptCode})',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = DashboardLocalizations.of(context);

    if (widget.isLoading) {
      return _buildLoadingWidget(l10n);
    }

    return ChartCard(
      title: l10n.assetGrowthDepartment,
      filters: _buildDepartmentFilter(context),
      chart: Column(
        children: [
          _buildPeriodInfo(context),
          AppSpacing.verticalSpaceMedium,
          SizedBox(
            height: 200,
            child: widget.growthTrend.hasData
                ? _buildLineChart()
                : _buildEmptyState(context),
          ),
        ],
      ),
      legend: widget.growthTrend.hasData ? _buildTrendSummary(context) : null,
    );
  }

  Widget _buildDepartmentFilter(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = DashboardLocalizations.of(context);
    final Map<String, String> uniqueDepts = {};

    for (final dept in widget.availableDepartments) {
      uniqueDepts[dept['code']!] = dept['name']!;
    }

    String? dropdownDisplayValue = widget.selectedDeptCode;

    print(
      '🔵 GrowthTrendChartWidget _buildDepartmentFilter: Dropdown value: $dropdownDisplayValue',
    );

    return Container(
      padding: AppSpacing.paddingHorizontalLG.add(AppSpacing.paddingVerticalSM),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.surface,
        borderRadius: AppBorders.medium,
        border: isDark
            ? Border.all(color: AppColors.darkBorder.withValues(alpha: 0.3))
            : Border.all(color: AppColors.cardBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: dropdownDisplayValue,
          hint: Text(
            l10n.allDepartments,
            style: AppTextStyles.body2.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          isExpanded: true,
          dropdownColor: isDark ? AppColors.darkSurface : null,
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(
                l10n.allDepartments,
                style: AppTextStyles.body2.copyWith(
                  color: isDark ? AppColors.darkText : AppColors.textPrimary,
                ),
              ),
            ),
            ...uniqueDepts.entries.map(
              (entry) => DropdownMenuItem<String?>(
                value: entry.key,
                child: Text(
                  entry.value,
                  style: AppTextStyles.body2.copyWith(
                    color: isDark ? AppColors.darkText : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
          onChanged: (String? newValue) {
            print('🔥 GrowthTrendChartWidget onChanged: $newValue');
            widget.onDeptChanged(newValue);
          },
          icon: Icon(
            Icons.arrow_drop_down,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodInfo(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = DashboardLocalizations.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${l10n.period}: ${widget.growthTrend.periodInfo.period}',
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkText : AppColors.textPrimary,
          ),
        ),
        if (widget.growthTrend.periodInfo.isCurrentYear)
          Container(
            padding: AppSpacing.paddingHorizontalSM.add(
              AppSpacing.paddingVerticalXS,
            ),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: AppBorders.small,
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Text(
              l10n.currentYear,
              style: AppTextStyles.overline.copyWith(
                color: Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLineChart() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = DashboardLocalizations.of(context);

    final spots = widget.growthTrend.trends.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.assetCount.toDouble());
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 5,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: isDark
                  ? AppColors.darkBorder.withValues(alpha: 0.4)
                  : AppColors.divider,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: isDark
                  ? AppColors.darkBorder.withValues(alpha: 0.4)
                  : AppColors.divider,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: AppTextStyles.overline.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary.withValues(alpha: 0.8)
                        : AppColors.textSecondary,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < widget.growthTrend.trends.length) {
                  return Padding(
                    padding: AppSpacing.paddingVerticalSM,
                    child: Text(
                      widget.growthTrend.trends[index].period,
                      style: AppTextStyles.chartLabel.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.darkTextSecondary.withValues(alpha: 0.8)
                            : AppColors.textSecondary,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: isDark
                ? AppColors.darkBorder.withValues(alpha: 0.4)
                : AppColors.divider,
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: isDark
                ? Color.lerp(Colors.orange, Colors.black, 0.2)!
                : Colors.orange,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                if (index < widget.growthTrend.trends.length) {
                  final trend = widget.growthTrend.trends[index];
                  Color dotColor;

                  if (trend.isPositiveGrowth) {
                    dotColor = isDark
                        ? Color.lerp(AppColors.trendUp, Colors.black, 0.2)!
                        : AppColors.trendUp;
                  } else if (trend.isNegativeGrowth) {
                    dotColor = AppColors.trendDown;
                  } else {
                    dotColor = AppColors.trendStable;
                  }

                  return FlDotCirclePainter(
                    radius: 4,
                    color: dotColor,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                }
                return FlDotCirclePainter(
                  radius: 4,
                  color: isDark
                      ? Color.lerp(Colors.orange, Colors.black, 0.2)!
                      : Colors.orange,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: isDark
                  ? Color.lerp(
                      Colors.orange,
                      Colors.black,
                      0.2,
                    )!.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final index = barSpot.x.toInt();
                if (index < widget.growthTrend.trends.length) {
                  final trend = widget.growthTrend.trends[index];
                  return LineTooltipItem(
                    l10n.chartTooltip(
                      trend.period,
                      trend.assetCount,
                      trend.formattedGrowthPercentage,
                    ),
                    AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
                return null;
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTrendSummary(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = DashboardLocalizations.of(context);
    int latestYearGrowth = _calculateLatestYearGrowth();
    int correctedAverageGrowth = _calculateAverageGrowth();

    return Container(
      padding: AppSpacing.paddingMedium,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.backgroundSecondary,
        borderRadius: AppBorders.medium,
        border: isDark
            ? Border.all(color: AppColors.darkBorder.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            context,
            l10n.latestYear,
            '${latestYearGrowth.toString()}%',
            Icons.trending_up,
            latestYearGrowth > 0
                ? AppColors.trendUp
                : latestYearGrowth < 0
                ? AppColors.trendDown
                : AppColors.trendStable,
          ),
          _buildDivider(context),
          _buildSummaryItem(
            context,
            l10n.averageGrowth,
            '${correctedAverageGrowth.toString()}%',
            Icons.analytics,
            Colors.orange,
          ),
          _buildDivider(context),
          _buildSummaryItem(
            context,
            l10n.periods,
            widget.growthTrend.summary.totalPeriods.toString(),
            Icons.calendar_today,
            isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        AppSpacing.verticalSpaceXS,
        Text(
          value,
          style: AppTextStyles.body2.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : color,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.overline.copyWith(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 1,
      height: 30,
      color: isDark ? AppColors.darkBorder : AppColors.divider,
    );
  }

  int _calculateLatestYearGrowth() {
    if (widget.growthTrend.trends.length < 2) return 0;

    final latestYear = widget.growthTrend.trends.last;
    final previousYear =
        widget.growthTrend.trends[widget.growthTrend.trends.length - 2];

    if (previousYear.assetCount == 0) return 100;

    return (((latestYear.assetCount - previousYear.assetCount) /
                previousYear.assetCount) *
            100)
        .round();
  }

  int _calculateAverageGrowth() {
    if (widget.growthTrend.trends.length < 2) return 0;

    List<int> growthPercentages = [];

    for (int i = 1; i < widget.growthTrend.trends.length; i++) {
      final current = widget.growthTrend.trends[i];
      final previous = widget.growthTrend.trends[i - 1];

      if (previous.assetCount > 0) {
        final growth =
            (((current.assetCount - previous.assetCount) /
                        previous.assetCount) *
                    100)
                .round();
        growthPercentages.add(growth);
      }
    }

    if (growthPercentages.isEmpty) return 0;

    return (growthPercentages.reduce((a, b) => a + b) /
            growthPercentages.length)
        .round();
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = DashboardLocalizations.of(context);

    return CompactEmptyState(
      icon: Icons.show_chart,
      message: l10n.noTrendDataAvailable,
    );
  }

  Widget _buildLoadingWidget(DashboardLocalizations l10n) {
    return DashboardCard(
      title: l10n.assetGrowthDepartment,
      isLoading: true,
      child: const SkeletonChart(height: 200, hasLegend: true),
    );
  }
}
