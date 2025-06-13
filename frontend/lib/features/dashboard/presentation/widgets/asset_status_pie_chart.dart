// Path: frontend/lib/features/dashboard/presentation/widgets/asset_status_pie_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/asset_status_pie.dart';

class AssetStatusPieChart extends StatelessWidget {
  final AssetStatusPie assetStatusPie;
  final double? radius;
  final bool showLegend;
  final bool showPercentages;

  const AssetStatusPieChart({
    super.key,
    required this.assetStatusPie,
    this.radius,
    this.showLegend = true,
    this.showPercentages = true,
  });

  @override
  Widget build(BuildContext context) {
    if (assetStatusPie.total == 0) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        const SizedBox(height: 40),
        SizedBox(
          height: radius != null ? radius! * 2 : 200,
          child: PieChart(
            PieChartData(
              sections: _buildPieSections(),
              centerSpaceRadius: (radius ?? 100) * 0.4,
              sectionsSpace: 2,
              startDegreeOffset: -90,
            ),
          ),
        ),
        if (showLegend) ...[const SizedBox(height: 60), _buildLegend()],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: radius != null ? radius! * 2 : 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pie_chart_outline,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            'No asset data available',
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

  List<PieChartSectionData> _buildPieSections() {
    final List<_ChartSegment> segments = [];

    if (assetStatusPie.active > 0) {
      segments.add(
        _ChartSegment(
          value: assetStatusPie.active.toDouble(),
          color: AppColors.assetActive,
          label: 'Active',
          count: assetStatusPie.active,
        ),
      );
    }

    if (assetStatusPie.inactive > 0) {
      segments.add(
        _ChartSegment(
          value: assetStatusPie.inactive.toDouble(),
          color: AppColors.assetInactive,
          label: 'Inactive',
          count: assetStatusPie.inactive,
        ),
      );
    }

    if (assetStatusPie.created > 0) {
      segments.add(
        _ChartSegment(
          value: assetStatusPie.created.toDouble(),
          color: AppColors.assetCreated,
          label: 'Created',
          count: assetStatusPie.created,
        ),
      );
    }

    return segments.map((segment) {
      final percentage = (segment.value / assetStatusPie.total) * 100;

      return PieChartSectionData(
        value: segment.value,
        color: segment.color,
        title: showPercentages ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: radius ?? 100,
        titleStyle: TextStyle(
          fontSize: showPercentages ? 12 : 0,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        badgeWidget: !showPercentages ? null : _buildBadge(segment),
        badgePositionPercentageOffset: 0.8,
      );
    }).toList();
  }

  Widget _buildBadge(_ChartSegment segment) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: segment.color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Text(
        segment.count.toString(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    final List<_ChartSegment> segments = [
      if (assetStatusPie.active > 0)
        _ChartSegment(
          value: assetStatusPie.active.toDouble(),
          color: AppColors.assetActive,
          label: 'Active',
          count: assetStatusPie.active,
        ),
      if (assetStatusPie.inactive > 0)
        _ChartSegment(
          value: assetStatusPie.inactive.toDouble(),
          color: AppColors.assetInactive,
          label: 'Inactive',
          count: assetStatusPie.inactive,
        ),
      if (assetStatusPie.created > 0)
        _ChartSegment(
          value: assetStatusPie.created.toDouble(),
          color: AppColors.assetCreated,
          label: 'Created',
          count: assetStatusPie.created,
        ),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: segments.map((segment) => _buildLegendItem(segment)).toList(),
    );
  }

  Widget _buildLegendItem(_ChartSegment segment) {
    final percentage = (segment.value / assetStatusPie.total) * 100;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: segment.color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '${segment.label} (${segment.count})',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.onBackground,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _ChartSegment {
  final double value;
  final Color color;
  final String label;
  final int count;

  const _ChartSegment({
    required this.value,
    required this.color,
    required this.label,
    required this.count,
  });
}

// Compact version for smaller spaces
class AssetStatusPieChartCompact extends StatelessWidget {
  final AssetStatusPie assetStatusPie;
  final double size;

  const AssetStatusPieChartCompact({
    super.key,
    required this.assetStatusPie,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    if (assetStatusPie.total == 0) {
      return SizedBox(
        width: size,
        height: size,
        child: Icon(
          Icons.pie_chart_outline,
          size: size * 0.6,
          color: AppColors.textTertiary,
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: PieChart(
        PieChartData(
          sections: _buildCompactSections(),
          centerSpaceRadius: size * 0.3,
          sectionsSpace: 1,
          startDegreeOffset: -90,
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildCompactSections() {
    final List<_ChartSegment> segments = [];

    if (assetStatusPie.active > 0) {
      segments.add(
        _ChartSegment(
          value: assetStatusPie.active.toDouble(),
          color: AppColors.assetActive,
          label: 'Active',
          count: assetStatusPie.active,
        ),
      );
    }

    if (assetStatusPie.inactive > 0) {
      segments.add(
        _ChartSegment(
          value: assetStatusPie.inactive.toDouble(),
          color: AppColors.assetInactive,
          label: 'Inactive',
          count: assetStatusPie.inactive,
        ),
      );
    }

    if (assetStatusPie.created > 0) {
      segments.add(
        _ChartSegment(
          value: assetStatusPie.created.toDouble(),
          color: AppColors.assetCreated,
          label: 'Created',
          count: assetStatusPie.created,
        ),
      );
    }

    return segments.map((segment) {
      return PieChartSectionData(
        value: segment.value,
        color: segment.color,
        title: '',
        radius: size * 0.35,
      );
    }).toList();
  }
}
