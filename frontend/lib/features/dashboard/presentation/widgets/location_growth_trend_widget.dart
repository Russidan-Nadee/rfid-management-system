// Path: frontend/lib/features/dashboard/presentation/widgets/location_growth_trend_widget.dart
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

enum GrowthChartType { line, bar }

class LocationGrowthTrendWidget extends StatefulWidget {
  final GrowthTrend growthTrend; // ใช้ GrowthTrend entity
  final bool isLoading;
  final String? selectedLocationCode;
  final List<Map<String, String>> availableLocations;
  final Function(String?) onLocationChanged;
  final GrowthChartType? chartType;
  final Function(GrowthChartType)? onChartTypeChanged;

  const LocationGrowthTrendWidget({
    super.key,
    required this.growthTrend,
    this.isLoading = false,
    this.selectedLocationCode,
    this.availableLocations = const [],
    required this.onLocationChanged,
    this.chartType,
    this.onChartTypeChanged,
  });

  @override
  State<LocationGrowthTrendWidget> createState() =>
      _LocationGrowthTrendWidgetState();
}

class _LocationGrowthTrendWidgetState extends State<LocationGrowthTrendWidget> {
  GrowthChartType get _selectedChartType => widget.chartType ?? GrowthChartType.bar;

  @override
  void initState() {
    super.initState();
    // LocationGrowthTrendWidget initState
  }

  @override
  void didUpdateWidget(LocationGrowthTrendWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedLocationCode != oldWidget.selectedLocationCode) {
      print(
        '🟢 LocationGrowthTrendWidget didUpdateWidget: selectedLocationCode changed from ${oldWidget.selectedLocationCode} to ${widget.selectedLocationCode}',
      );
    } else {
      print(
        '🟡 LocationGrowthTrendWidget didUpdateWidget: selectedLocationCode is same (${widget.selectedLocationCode})',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = DashboardLocalizations.of(context);

    if (widget.isLoading) {
      return _buildLoadingWidget(l10n);
    }

    return DashboardCard(
      title: l10n.assetGrowthLocation,
      trailing: widget.growthTrend.hasData ? _buildChartTypeSelector(context) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.growthTrend.hasData) ...[
            _buildLocationFilter(context),
            AppSpacing.verticalSpaceMedium,
            _buildPeriodInfo(context),
            AppSpacing.verticalSpaceMedium,
          ],
          SizedBox(
            height: 200,
            child: widget.growthTrend.hasData
                ? _buildSelectedChart()
                : _buildEmptyState(context),
          ),
          if (widget.growthTrend.hasData) ...[
            AppSpacing.verticalSpaceMedium,
            _buildTrendSummary(context),
          ],
        ],
      ),
    );
  }

  Widget _buildChartTypeSelector(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = DashboardLocalizations.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<GrowthChartType>(
          value: _selectedChartType,
          icon: Icon(Icons.keyboard_arrow_down, size: 16, color: theme.colorScheme.onSurface),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          items: [
            DropdownMenuItem(
              value: GrowthChartType.line,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.show_chart, size: 16, color: theme.colorScheme.onSurface),
                  const SizedBox(width: 8),
                  Text(l10n.lineChart),
                ],
              ),
            ),
            DropdownMenuItem(
              value: GrowthChartType.bar,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bar_chart, size: 16, color: theme.colorScheme.onSurface),
                  const SizedBox(width: 8),
                  Text(l10n.barChart),
                ],
              ),
            ),
          ],
          onChanged: (GrowthChartType? newType) {
            if (newType != null && widget.onChartTypeChanged != null) {
              widget.onChartTypeChanged!(newType);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSelectedChart() {
    switch (_selectedChartType) {
      case GrowthChartType.line:
        return _buildLineChart();
      case GrowthChartType.bar:
        return _buildBarChart();
    }
  }

  Widget _buildLocationFilter(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = DashboardLocalizations.of(context);
    final Map<String, String> uniqueLocations = {};

    for (final location in widget.availableLocations) {
      uniqueLocations[location['code']!] = location['name']!;
    }

    String? dropdownDisplayValue = widget.selectedLocationCode;

    // Building location filter

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
            l10n.allLocations,
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
                l10n.allLocations,
                style: AppTextStyles.body2.copyWith(
                  color: isDark ? AppColors.darkText : AppColors.textPrimary,
                ),
              ),
            ),
            ...uniqueLocations.entries.map(
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
            print('🔥 LocationGrowthTrendWidget onChanged: $newValue');
            widget.onLocationChanged(newValue);
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
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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

  Widget _buildBarChart() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = DashboardLocalizations.of(context);

    final maxValue = widget.growthTrend.trends
        .map((trend) => trend.assetCount)
        .fold(0, (prev, current) => current > prev ? current : prev)
        .toDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.black87,
            tooltipBorder: BorderSide.none,
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final trend = widget.growthTrend.trends[group.x.toInt()];
              return BarTooltipItem(
                l10n.chartTooltip(
                  trend.period,
                  trend.assetCount,
                  trend.formattedGrowthPercentage,
                ),
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < widget.growthTrend.trends.length) {
                  final trend = widget.growthTrend.trends[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      trend.period,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 10,
                        color: isDark
                            ? AppColors.darkTextSecondary.withValues(alpha: 0.8)
                            : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 10,
                    color: isDark
                        ? AppColors.darkTextSecondary.withValues(alpha: 0.8)
                        : AppColors.textSecondary,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: isDark
                ? AppColors.darkBorder.withValues(alpha: 0.4)
                : AppColors.divider,
          ),
        ),
        barGroups: widget.growthTrend.trends.asMap().entries.map((entry) {
          final index = entry.key;
          final trend = entry.value;
          
          // Choose bar color based on growth
          Color barColor;
          if (trend.isPositiveGrowth) {
            barColor = isDark
                ? Color.lerp(AppColors.trendUp, Colors.black, 0.2)!
                : AppColors.trendUp;
          } else if (trend.isNegativeGrowth) {
            barColor = AppColors.trendDown;
          } else {
            barColor = AppColors.trendStable;
          }

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: trend.assetCount.toDouble(),
                color: barColor,
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxValue / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: isDark
                  ? AppColors.darkBorder.withValues(alpha: 0.4)
                  : AppColors.divider,
              strokeWidth: 1,
            );
          },
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
      message: l10n.noLocationTrendDataAvailable,
    );
  }

  Widget _buildLoadingWidget(DashboardLocalizations l10n) {
    return DashboardCard(
      title: l10n.assetGrowthLocation,
      isLoading: true,
      child: const SkeletonChart(height: 200, hasLegend: true),
    );
  }
}
