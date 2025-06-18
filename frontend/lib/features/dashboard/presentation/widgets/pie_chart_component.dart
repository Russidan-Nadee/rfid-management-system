// Path: frontend/lib/features/dashboard/presentation/widgets/pie_chart_component.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart' as fl_chart; // เพิ่ม as fl_chart

class PieChartData {
  final String label;
  final double value;
  final double percentage;
  final Color color;
  final String? description;

  const PieChartData({
    required this.label,
    required this.value,
    required this.percentage,
    required this.color,
    this.description,
  });
}

class PieChartComponent extends StatefulWidget {
  final List<PieChartData> data;
  final double? size;
  final bool showPercentages;
  final bool showLabels;
  final bool showLegend;
  final double centerSpaceRadius;
  final double sectionsSpace;
  final TextStyle? labelStyle;
  final Color? backgroundColor;

  const PieChartComponent({
    super.key,
    required this.data,
    this.size,
    this.showPercentages = true,
    this.showLabels = true,
    this.showLegend = true,
    this.centerSpaceRadius = 30,
    this.sectionsSpace = 4,
    this.labelStyle,
    this.backgroundColor,
  });

  @override
  State<PieChartComponent> createState() => _PieChartComponentState();
}

class _PieChartComponentState extends State<PieChartComponent> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Pie Chart
        Expanded(flex: widget.showLegend ? 3 : 1, child: _buildPieChart()),

        // Legend
        if (widget.showLegend) ...[
          const SizedBox(height: 16),
          Expanded(flex: 1, child: _buildLegend()),
        ],
      ],
    );
  }

  Widget _buildPieChart() {
    return AspectRatio(
      aspectRatio: 1.0,
      child: fl_chart.PieChart(
        // เปลี่ยนเป็น fl_chart.PieChart
        fl_chart.PieChartData(
          // เปลี่ยนเป็น fl_chart.PieChartData
          sections: _buildSections(),
          centerSpaceRadius: widget.centerSpaceRadius,
          sectionsSpace: widget.sectionsSpace,
          pieTouchData: fl_chart.PieTouchData(
            // เปลี่ยนเป็น fl_chart.PieTouchData
            touchCallback: (fl_chart.FlTouchEvent event, pieTouchResponse) {
              // เปลี่ยนเป็น fl_chart.FlTouchEvent
              setState(() {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  touchedIndex = -1;
                  return;
                }
                touchedIndex =
                    pieTouchResponse.touchedSection!.touchedSectionIndex;
              });
            },
          ),
        ),
      ),
    );
  }

  List<fl_chart.PieChartSectionData> _buildSections() {
    // เปลี่ยนเป็น fl_chart.PieChartSectionData
    return widget.data.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final isTouched = index == touchedIndex;

      return fl_chart.PieChartSectionData(
        // เปลี่ยนเป็น fl_chart.PieChartSectionData
        color: data.color,
        value: data.value,
        title: _buildSectionTitle(data, isTouched),
        radius: isTouched ? 80 : 70,
        titleStyle: _buildTitleStyle(isTouched),
        badgeWidget: isTouched ? _buildBadge(data) : null,
        badgePositionPercentageOffset: 1.3,
      );
    }).toList();
  }

  String _buildSectionTitle(PieChartData data, bool isTouched) {
    if (!widget.showLabels && !widget.showPercentages) return '';

    if (isTouched) {
      if (widget.showLabels && widget.showPercentages) {
        return '${data.label}\n${data.percentage.toStringAsFixed(1)}%';
      } else if (widget.showPercentages) {
        return '${data.percentage.toStringAsFixed(1)}%';
      } else {
        return data.label;
      }
    } else {
      return widget.showPercentages
          ? '${data.percentage.toStringAsFixed(0)}%'
          : '';
    }
  }

  TextStyle _buildTitleStyle(bool isTouched) {
    final baseStyle =
        widget.labelStyle ??
        const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        );

    return baseStyle.copyWith(
      fontSize: isTouched ? 14 : baseStyle.fontSize,
      fontWeight: isTouched ? FontWeight.bold : baseStyle.fontWeight,
    );
  }

  Widget? _buildBadge(PieChartData data) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            data.value.toStringAsFixed(0),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: data.color,
            ),
          ),
          Text(
            'รายการ',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return SingleChildScrollView(
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: widget.data.map((data) => _buildLegendItem(data)).toList(),
      ),
    );
  }

  Widget _buildLegendItem(PieChartData data) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: data.color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data.label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${data.value.toStringAsFixed(0)} รายการ (${data.percentage.toStringAsFixed(1)}%)',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: widget.size ?? 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              color: Colors.grey.shade400,
              size: 48,
            ),
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

/// Enhanced Pie Chart with additional features
class EnhancedPieChartComponent extends StatefulWidget {
  final List<PieChartData> data;
  final String? title;
  final String? subtitle;
  final Widget? centerWidget;
  final bool showValues;
  final bool showTooltips;
  final Function(PieChartData)? onSectionTap;
  final double animationDuration;

  const EnhancedPieChartComponent({
    super.key,
    required this.data,
    this.title,
    this.subtitle,
    this.centerWidget,
    this.showValues = true,
    this.showTooltips = true,
    this.onSectionTap,
    this.animationDuration = 1.0,
  });

  @override
  State<EnhancedPieChartComponent> createState() =>
      _EnhancedPieChartComponentState();
}

class _EnhancedPieChartComponentState extends State<EnhancedPieChartComponent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(
        milliseconds: (widget.animationDuration * 1000).round(),
      ),
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
    return Column(
      children: [
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          if (widget.subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              widget.subtitle!,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
          const SizedBox(height: 16),
        ],
        Expanded(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  fl_chart.PieChart(
                    // เปลี่ยนเป็น fl_chart.PieChart
                    fl_chart.PieChartData(
                      // เปลี่ยนเป็น fl_chart.PieChartData
                      sections: _buildAnimatedSections(),
                      centerSpaceRadius: 60,
                      sectionsSpace: 4,
                      pieTouchData: fl_chart.PieTouchData(
                        touchCallback: _handleTouch,
                      ), // เปลี่ยนเป็น fl_chart.PieTouchData
                    ),
                  ),
                  if (widget.centerWidget != null) widget.centerWidget!,
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildDetailedLegend(),
      ],
    );
  }

  List<fl_chart.PieChartSectionData> _buildAnimatedSections() {
    // เปลี่ยนเป็น fl_chart.PieChartSectionData
    return widget.data.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final isTouched = index == touchedIndex;
      final animatedValue = data.value * _animation.value;

      return fl_chart.PieChartSectionData(
        // เปลี่ยนเป็น fl_chart.PieChartSectionData
        color: data.color,
        value: animatedValue,
        title: isTouched && widget.showValues
            ? '${data.percentage.toStringAsFixed(1)}%'
            : '',
        radius: isTouched ? 85 : 75,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildDetailedLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: widget.data
            .map((data) => _buildDetailedLegendItem(data))
            .toList(),
      ),
    );
  }

  Widget _buildDetailedLegendItem(PieChartData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: data.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              data.label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '${data.value.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: data.color,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${data.percentage.toStringAsFixed(1)}%',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _handleTouch(
    fl_chart.FlTouchEvent event,
    fl_chart.PieTouchResponse? pieTouchResponse,
  ) {
    // เปลี่ยนเป็น fl_chart.FlTouchEvent และ fl_chart.PieTouchResponse
    setState(() {
      if (!event.isInterestedForInteractions ||
          pieTouchResponse == null ||
          pieTouchResponse.touchedSection == null) {
        touchedIndex = -1;
        return;
      }

      final newTouchedIndex =
          pieTouchResponse.touchedSection!.touchedSectionIndex;
      touchedIndex = newTouchedIndex;

      if (widget.onSectionTap != null && newTouchedIndex < widget.data.length) {
        widget.onSectionTap!(widget.data[newTouchedIndex]);
      }
    });
  }
}
