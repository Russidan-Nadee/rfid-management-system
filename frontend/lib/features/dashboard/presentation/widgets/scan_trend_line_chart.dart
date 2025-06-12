// Path: frontend/lib/features/dashboard/presentation/widgets/scan_trend_line_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/scan_trend.dart';

class ScanTrendLineChart extends StatelessWidget {
  final List<ScanTrend> scanTrendList;
  final double? height;
  final bool showGrid;
  final bool showTooltip;

  const ScanTrendLineChart({
    super.key,
    required this.scanTrendList,
    this.height,
    this.showGrid = true,
    this.showTooltip = true,
  });

  @override
  Widget build(BuildContext context) {
    if (scanTrendList.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      height: height ?? 200,
      child: LineChart(
        LineChartData(
          lineBarsData: [_buildLineData()],
          titlesData: _buildTitlesData(),
          gridData: _buildGridData(),
          borderData: _buildBorderData(),
          lineTouchData: _buildTouchData(),
          minX: 0,
          maxX: (scanTrendList.length - 1).toDouble(),
          minY: 0,
          maxY: _getMaxY(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: height ?? 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.trending_up, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          Text(
            'No scan trend data available',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _buildLineData() {
    final spots = scanTrendList.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.count.toDouble());
    }).toList();

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: AppColors.primary,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: AppColors.primary,
            strokeWidth: 2,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.3),
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
      ),
    );
  }

  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 35,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toInt().toString(),
              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 25,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index >= 0 && index < scanTrendList.length) {
              return Text(
                scanTrendList[index].dayName ?? '',
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              );
            }
            return const Text('');
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  FlGridData _buildGridData() {
    if (!showGrid) {
      return const FlGridData(show: false);
    }

    return FlGridData(
      show: true,
      drawVerticalLine: true,
      drawHorizontalLine: true,
      horizontalInterval: _getGridInterval(),
      verticalInterval: 1,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: AppColors.divider,
          strokeWidth: 1,
          dashArray: [5, 5],
        );
      },
      getDrawingVerticalLine: (value) {
        return FlLine(
          color: AppColors.divider,
          strokeWidth: 1,
          dashArray: [5, 5],
        );
      },
    );
  }

  FlBorderData _buildBorderData() {
    return FlBorderData(
      show: true,
      border: Border.all(color: AppColors.cardBorder, width: 1),
    );
  }

  LineTouchData _buildTouchData() {
    if (!showTooltip) {
      return const LineTouchData(enabled: false);
    }

    return LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        // Removed tooltipBgColor and tooltipRoundedRadius as they are not defined in your fl_chart version.
        tooltipPadding: const EdgeInsets.all(8),
        getTooltipItems: (List<LineBarSpot> touchedSpots) {
          return touchedSpots.map((LineBarSpot touchedSpot) {
            final index = touchedSpot.x.toInt();
            if (index >= 0 && index < scanTrendList.length) {
              final trend = scanTrendList[index];
              return LineTooltipItem(
                '${trend.dayName ?? 'Day ${index + 1}'}\n${trend.count} scans',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              );
            }
            return null;
          }).toList();
        },
      ),
    );
  }

  double _getMaxY() {
    if (scanTrendList.isEmpty) return 10;

    final maxCount = scanTrendList
        .map((trend) => trend.count)
        .reduce((a, b) => a > b ? a : b);

    // Add 20% padding to max value
    return (maxCount * 1.2).ceilToDouble();
  }

  double _getGridInterval() {
    final maxY = _getMaxY();
    if (maxY <= 10) return 2;
    if (maxY <= 50) return 10;
    if (maxY <= 100) return 20;
    return (maxY / 5).ceilToDouble();
  }
}

// Compact version for smaller spaces
class ScanTrendLineChartCompact extends StatelessWidget {
  final List<ScanTrend> scanTrendList;
  final double height;
  final Color? lineColor;

  const ScanTrendLineChartCompact({
    super.key,
    required this.scanTrendList,
    this.height = 60,
    this.lineColor,
  });

  @override
  Widget build(BuildContext context) {
    if (scanTrendList.isEmpty) {
      return Container(
        height: height,
        child: Center(
          child: Icon(
            Icons.trending_up,
            size: height * 0.4,
            color: AppColors.textTertiary,
          ),
        ),
      );
    }

    return Container(
      height: height,
      child: LineChart(
        LineChartData(
          lineBarsData: [_buildCompactLineData()],
          titlesData: const FlTitlesData(show: false),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          minX: 0,
          maxX: (scanTrendList.length - 1).toDouble(),
          minY: 0,
          maxY: _getMaxY(),
        ),
      ),
    );
  }

  LineChartBarData _buildCompactLineData() {
    final spots = scanTrendList.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.count.toDouble());
    }).toList();

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: lineColor ?? AppColors.primary,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            (lineColor ?? AppColors.primary).withOpacity(0.2),
            (lineColor ?? AppColors.primary).withOpacity(0.05),
          ],
        ),
      ),
    );
  }

  double _getMaxY() {
    if (scanTrendList.isEmpty) return 10;

    final maxCount = scanTrendList
        .map((trend) => trend.count)
        .reduce((a, b) => a > b ? a : b);

    return (maxCount * 1.1).ceilToDouble();
  }
}

// Sparkline version for inline display
class ScanTrendSparkline extends StatelessWidget {
  final List<ScanTrend> scanTrendList;
  final double width;
  final double height;
  final Color? color;

  const ScanTrendSparkline({
    super.key,
    required this.scanTrendList,
    this.width = 80,
    this.height = 30,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (scanTrendList.isEmpty) {
      return Container(
        width: width,
        height: height,
        child: Center(
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      child: LineChart(
        LineChartData(
          lineBarsData: [_buildSparklineData()],
          titlesData: const FlTitlesData(show: false),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          minX: 0,
          maxX: (scanTrendList.length - 1).toDouble(),
          minY: 0,
          maxY: _getMaxY(),
        ),
      ),
    );
  }

  LineChartBarData _buildSparklineData() {
    final spots = scanTrendList.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.count.toDouble());
    }).toList();

    return LineChartBarData(
      spots: spots,
      isCurved: false,
      color: color ?? AppColors.primary,
      barWidth: 1.5,
      dotData: const FlDotData(show: false),
    );
  }

  double _getMaxY() {
    if (scanTrendList.isEmpty) return 10;

    final maxCount = scanTrendList
        .map((trend) => trend.count)
        .reduce((a, b) => a > b ? a : b);

    return maxCount.toDouble();
  }
}
