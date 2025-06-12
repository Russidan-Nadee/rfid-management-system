// Path: frontend/lib/features/dashboard/presentation/widgets/scan_trend_line_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/scan_trend.dart';

class ScanTrendLineChart extends StatelessWidget {
  final List<ScanTrend> scanTrendList;

  const ScanTrendLineChart({required this.scanTrendList, super.key});

  @override
  Widget build(BuildContext context) {
    final spots = scanTrendList.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.count.toDouble());
    }).toList();

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 3,
              color: Colors.blue, // fl_chart ใช้ color ไม่ใช่ colors
              dotData: FlDotData(show: true),
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < scanTrendList.length) {
                    return Text(scanTrendList[index].dayName ?? '');
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),
        ),
      ),
    );
  }
}
