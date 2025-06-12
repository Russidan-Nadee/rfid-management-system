// Path: frontend/lib/features/dashboard/presentation/widgets/asset_status_pie_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/features/dashboard/domain/entities/asset_status_pie.dart';

class AssetStatusPieChart extends StatelessWidget {
  final AssetStatusPie assetStatusPie;

  const AssetStatusPieChart({required this.assetStatusPie, super.key});

  @override
  Widget build(BuildContext context) {
    final segments = [
      _Segment('Active', assetStatusPie.active, Colors.green),
      _Segment('Inactive', assetStatusPie.inactive, Colors.orange),
      _Segment('Created', assetStatusPie.created, Colors.blue),
    ];

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: segments.map((seg) {
            final value = seg.value.toDouble();
            return PieChartSectionData(
              value: value,
              color: seg.color,
              title: '${seg.label}\n${seg.value}',
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _Segment {
  final String label;
  final int value;
  final Color color;

  _Segment(this.label, this.value, this.color);
}
