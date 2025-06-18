// Path: frontend/lib/features/dashboard/presentation/widgets/line_chart_component.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LineChartData {
  final double x;
  final double y;
  final String label;
  final int? growthPercentage;
  final String? tooltip;

  const LineChartData({
    required this.x,
    required this.y,
    required this.label,
    this.growthPercentage,
    this.tooltip,
  });
}

class LineChartComponent extends StatefulWidget {
  final List<LineChartData> data;
  final List<String>? xAxisLabels;
  final String? title;
  final String? yAxisTitle;
  final Color color;
  final Color? backgroundColor;
  final bool showGrid;
  final bool showDots;
  final bool showGrowthIndicators;
  final bool isCurved;
  final double strokeWidth;
  final double? minY;
  final double? maxY;
  final EdgeInsets? padding;

  const LineChartComponent({
    super.key,
    required this.data,
    this.xAxisLabels,
    this.title,
    this.yAxisTitle,
    this.color = Colors.blue,
    this.backgroundColor,
    this.showGrid = true,
    this.showDots = true,
    this.showGrowthIndicators = false,
    this.isCurved = true,
    this.strokeWidth = 3.0,
    this.minY,
    this.maxY,
    this.padding,
  });

  @override
  State<LineChartComponent> createState() => _LineChartComponentState();
}

class _LineChartComponentState extends State<LineChartComponent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Expanded(
          child: Padding(
            padding: widget.padding ?? const EdgeInsets.all(8),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) => _buildChart(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    return LineChart(
      LineChartData(
        gridData: _buildGridData(),
        titlesData: _buildTitlesData(),
        borderData: _buildBorderData(),
        lineBarsData: [_buildLineBarData()],
        minX: 0,
        maxX: widget.data.isNotEmpty ? widget.data.length - 1.0 : 5,
        minY: _calculateMinY(),
        maxY: _calculateMaxY(),
        lineTouchData: _buildTouchData(),
        backgroundColor: widget.backgroundColor,
      ),
    );
  }

  FlGridData _buildGridData() {
    return FlGridData(
      show: widget.showGrid,
      drawVerticalLine: true,
      drawHorizontalLine: true,
      horizontalInterval: _calculateHorizontalInterval(),
      verticalInterval: 1,
      getDrawingHorizontalLine: (value) {
        return FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1);
      },
      getDrawingVerticalLine: (value) {
        return FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1);
      },
    );
  }

  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toInt().toString(),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index >= 0 && index < widget.data.length) {
              final label =
                  widget.xAxisLabels != null &&
                      index < widget.xAxisLabels!.length
                  ? widget.xAxisLabels![index]
                  : widget.data[index].label;

              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              );
            }
            return const Text('');
          },
        ),
      ),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  FlBorderData _buildBorderData() {
    return FlBorderData(
      show: true,
      border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
    );
  }

  LineChartBarData _buildLineBarData() {
    final spots = widget.data.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final animatedY = data.y * _animation.value;
      return FlSpot(index.toDouble(), animatedY);
    }).toList();

    return LineChartBarData(
      spots: spots,
      isCurved: widget.isCurved,
      color: widget.color,
      barWidth: widget.strokeWidth,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: widget.showDots,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: touchedIndex == index ? 6 : 4,
            color: widget.color,
            strokeWidth: 2,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        color: widget.color.withOpacity(0.1),
      ),
      aboveBarData: widget.showGrowthIndicators
          ? BarAreaData(
              show: true,
              applyCutOffY: true,
              cutOffY: _calculateAverageY(),
              color: widget.color.withOpacity(0.05),
            )
          : BarAreaData(show: false),
    );
  }

  LineTouchData _buildTouchData() {
    return LineTouchData(
      enabled: true,
      touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
        setState(() {
          if (touchResponse == null || touchResponse.lineBarSpots == null) {
            touchedIndex = -1;
          } else {
            touchedIndex = touchResponse.lineBarSpots!.first.spotIndex;
          }
        });
      },
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: Colors.blueAccent.withOpacity(0.9),
        tooltipRoundedRadius: 8,
        tooltipPadding: const EdgeInsets.all(8),
        tooltipMargin: 8,
        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
          return touchedBarSpots.map((barSpot) {
            final index = barSpot.spotIndex;
            if (index >= 0 && index < widget.data.length) {
              final data = widget.data[index];
              return LineTooltipItem(
                _buildTooltipText(data),
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }
            return null;
          }).toList();
        },
      ),
      getTouchLineStart: (data, index) => 0,
      getTouchLineEnd: (data, index) => 0,
      touchSpotThreshold: 20,
    );
  }

  String _buildTooltipText(LineChartData data) {
    final lines = <String>[data.label, 'จำนวน: ${data.y.toStringAsFixed(0)}'];

    if (data.growthPercentage != null) {
      final sign = data.growthPercentage! >= 0 ? '+' : '';
      lines.add('เติบโต: $sign${data.growthPercentage}%');
    }

    if (data.tooltip != null) {
      lines.add(data.tooltip!);
    }

    return lines.join('\n');
  }

  double _calculateMinY() {
    if (widget.minY != null) return widget.minY!;
    if (widget.data.isEmpty) return 0;

    final minValue = widget.data
        .map((d) => d.y)
        .reduce((a, b) => a < b ? a : b);
    return (minValue * 0.9).floorToDouble();
  }

  double _calculateMaxY() {
    if (widget.maxY != null) return widget.maxY!;
    if (widget.data.isEmpty) return 100;

    final maxValue = widget.data
        .map((d) => d.y)
        .reduce((a, b) => a > b ? a : b);
    return (maxValue * 1.1).ceilToDouble();
  }

  double _calculateAverageY() {
    if (widget.data.isEmpty) return 0;
    final sum = widget.data.fold(0.0, (sum, data) => sum + data.y);
    return sum / widget.data.length;
  }

  double _calculateHorizontalInterval() {
    final range = _calculateMaxY() - _calculateMinY();
    return range / 5; // Show ~5 horizontal lines
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, color: Colors.grey.shade400, size: 48),
            const SizedBox(height: 16),
            Text(
              'ไม่มีข้อมูลสำหรับแสดงกราฟ',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

/// Enhanced Line Chart with multiple lines
class MultiLineChartComponent extends StatelessWidget {
  final List<MultiLineData> datasets;
  final List<String>? xAxisLabels;
  final String? title;
  final bool showLegend;
  final bool showGrid;

  const MultiLineChartComponent({
    super.key,
    required this.datasets,
    this.xAxisLabels,
    this.title,
    this.showLegend = true,
    this.showGrid = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
        ],
        if (showLegend) ...[_buildLegend(), const SizedBox(height: 12)],
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: showGrid),
              titlesData: _buildTitlesData(),
              borderData: FlBorderData(show: true),
              lineBarsData: datasets.map(_buildLineBarData).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      children: datasets.map((dataset) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 16, height: 3, color: dataset.color),
            const SizedBox(width: 8),
            Text(
              dataset.label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        );
      }).toList(),
    );
  }

  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toInt().toString(),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (xAxisLabels != null &&
                index >= 0 &&
                index < xAxisLabels!.length) {
              return Text(
                xAxisLabels![index],
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              );
            }
            return const Text('');
          },
        ),
      ),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  LineChartBarData _buildLineBarData(MultiLineData dataset) {
    return LineChartBarData(
      spots: dataset.data.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.y);
      }).toList(),
      isCurved: true,
      color: dataset.color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(show: true),
      belowBarData: BarAreaData(
        show: true,
        color: dataset.color.withOpacity(0.1),
      ),
    );
  }
}

class MultiLineData {
  final String label;
  final List<LineChartData> data;
  final Color color;

  const MultiLineData({
    required this.label,
    required this.data,
    required this.color,
  });
}
