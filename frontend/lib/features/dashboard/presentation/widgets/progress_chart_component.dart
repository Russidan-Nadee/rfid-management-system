// Path: frontend/lib/features/dashboard/presentation/widgets/progress_chart_component.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class ProgressChartComponent extends StatefulWidget {
  final double percentage;
  final String? centerValue;
  final String? centerLabel;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;
  final double size;
  final bool showAnimation;
  final Duration animationDuration;
  final Widget? customCenter;
  final TextStyle? centerValueStyle;
  final TextStyle? centerLabelStyle;

  const ProgressChartComponent({
    super.key,
    required this.percentage,
    this.centerValue,
    this.centerLabel,
    this.color = Colors.blue,
    this.backgroundColor = Colors.grey,
    this.strokeWidth = 12.0,
    this.size = 120.0,
    this.showAnimation = true,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.customCenter,
    this.centerValueStyle,
    this.centerLabelStyle,
  });

  @override
  State<ProgressChartComponent> createState() => _ProgressChartComponentState();
}

class _ProgressChartComponentState extends State<ProgressChartComponent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.percentage / 100).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.showAnimation) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ProgressChartComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentage != widget.percentage) {
      _animation =
          Tween<double>(
            begin: oldWidget.percentage / 100,
            end: widget.percentage / 100,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeInOut,
            ),
          );
      _animationController.reset();
      if (widget.showAnimation) {
        _animationController.forward();
      } else {
        _animationController.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _ProgressPainter(
              progress: _animation.value,
              color: widget.color,
              backgroundColor: widget.backgroundColor,
              strokeWidth: widget.strokeWidth,
            ),
            child: _buildCenter(),
          );
        },
      ),
    );
  }

  Widget _buildCenter() {
    if (widget.customCenter != null) {
      return Center(child: widget.customCenter!);
    }

    return Center(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final animatedPercentage = (_animation.value * 100).round();

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.centerValue != null)
                Text(
                  widget.centerValue!.replaceAll(
                    RegExp(r'\d+'),
                    animatedPercentage.toString(),
                  ),
                  style:
                      widget.centerValueStyle ??
                      TextStyle(
                        fontSize: widget.size * 0.2,
                        fontWeight: FontWeight.bold,
                        color: widget.color,
                      ),
                ),
              if (widget.centerLabel != null)
                Text(
                  widget.centerLabel!,
                  style:
                      widget.centerLabelStyle ??
                      TextStyle(
                        fontSize: widget.size * 0.1,
                        color: Colors.grey.shade600,
                      ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _ProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor.withOpacity(0.3)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;
      const startAngle = -math.pi / 2; // Start from top

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Enhanced Progress Chart with segments
class SegmentedProgressChartComponent extends StatefulWidget {
  final List<ProgressSegment> segments;
  final double size;
  final double strokeWidth;
  final String? centerText;
  final Widget? centerWidget;
  final bool showAnimation;
  final Duration animationDuration;

  const SegmentedProgressChartComponent({
    super.key,
    required this.segments,
    this.size = 120.0,
    this.strokeWidth = 12.0,
    this.centerText,
    this.centerWidget,
    this.showAnimation = true,
    this.animationDuration = const Duration(milliseconds: 2000),
  });

  @override
  State<SegmentedProgressChartComponent> createState() =>
      _SegmentedProgressChartComponentState();
}

class _SegmentedProgressChartComponentState
    extends State<SegmentedProgressChartComponent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.showAnimation) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _SegmentedProgressPainter(
              segments: widget.segments,
              strokeWidth: widget.strokeWidth,
              animationProgress: _animation.value,
            ),
            child: _buildCenter(),
          );
        },
      ),
    );
  }

  Widget _buildCenter() {
    if (widget.centerWidget != null) {
      return Center(child: widget.centerWidget!);
    }

    if (widget.centerText != null) {
      return Center(
        child: Text(
          widget.centerText!,
          style: TextStyle(
            fontSize: widget.size * 0.15,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Default: show total percentage
    final totalPercentage = widget.segments.fold(
      0.0,
      (sum, segment) => sum + segment.percentage,
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${(totalPercentage * _animation.value).round()}%',
            style: TextStyle(
              fontSize: widget.size * 0.2,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          Text(
            'รวม',
            style: TextStyle(
              fontSize: widget.size * 0.1,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentedProgressPainter extends CustomPainter {
  final List<ProgressSegment> segments;
  final double strokeWidth;
  final double animationProgress;

  _SegmentedProgressPainter({
    required this.segments,
    required this.strokeWidth,
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw segments
    double currentAngle = -math.pi / 2; // Start from top

    for (final segment in segments) {
      final segmentPaint = Paint()
        ..color = segment.color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final segmentAngle =
          2 * math.pi * (segment.percentage / 100) * animationProgress;

      if (segmentAngle > 0) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          currentAngle,
          segmentAngle,
          false,
          segmentPaint,
        );
      }

      currentAngle += segmentAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _SegmentedProgressPainter oldDelegate) {
    return oldDelegate.segments != segments ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.animationProgress != animationProgress;
  }
}

class ProgressSegment {
  final double percentage;
  final Color color;
  final String label;

  const ProgressSegment({
    required this.percentage,
    required this.color,
    required this.label,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProgressSegment &&
        other.percentage == percentage &&
        other.color == color &&
        other.label == label;
  }

  @override
  int get hashCode => percentage.hashCode ^ color.hashCode ^ label.hashCode;
}

/// Gauge-style progress chart
class GaugeProgressChartComponent extends StatefulWidget {
  final double percentage;
  final double size;
  final double strokeWidth;
  final Color color;
  final Color backgroundColor;
  final double startAngle;
  final double sweepAngle;
  final String? title;
  final String? subtitle;
  final bool showNeedle;

  const GaugeProgressChartComponent({
    super.key,
    required this.percentage,
    this.size = 160.0,
    this.strokeWidth = 20.0,
    this.color = Colors.green,
    this.backgroundColor = Colors.grey,
    this.startAngle = math.pi,
    this.sweepAngle = math.pi,
    this.title,
    this.subtitle,
    this.showNeedle = true,
  });

  @override
  State<GaugeProgressChartComponent> createState() =>
      _GaugeProgressChartComponentState();
}

class _GaugeProgressChartComponentState
    extends State<GaugeProgressChartComponent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.percentage / 100).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
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
        SizedBox(
          width: widget.size,
          height: widget.size * 0.6,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                painter: _GaugePainter(
                  progress: _animation.value,
                  color: widget.color,
                  backgroundColor: widget.backgroundColor,
                  strokeWidth: widget.strokeWidth,
                  startAngle: widget.startAngle,
                  sweepAngle: widget.sweepAngle,
                  showNeedle: widget.showNeedle,
                ),
                child: _buildGaugeCenter(),
              );
            },
          ),
        ),
        if (widget.title != null || widget.subtitle != null) ...[
          const SizedBox(height: 16),
          if (widget.title != null)
            Text(
              widget.title!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          if (widget.subtitle != null)
            Text(
              widget.subtitle!,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
        ],
      ],
    );
  }

  Widget _buildGaugeCenter() {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(bottom: widget.size * 0.1),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final animatedPercentage = (_animation.value * 100).round();
              return Text(
                '$animatedPercentage%',
                style: TextStyle(
                  fontSize: widget.size * 0.12,
                  fontWeight: FontWeight.bold,
                  color: widget.color,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;
  final double startAngle;
  final double sweepAngle;
  final bool showNeedle;

  _GaugePainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
    required this.startAngle,
    required this.sweepAngle,
    required this.showNeedle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - strokeWidth / 2;

    // Draw background arc
    final backgroundPaint = Paint()
      ..color = backgroundColor.withOpacity(0.3)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      backgroundPaint,
    );

    // Draw progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final progressSweep = sweepAngle * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        progressSweep,
        false,
        progressPaint,
      );
    }

    // Draw needle
    if (showNeedle && progress > 0) {
      final needlePaint = Paint()
        ..color = Colors.red
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final needleAngle = startAngle + (sweepAngle * progress);
      final needleLength = radius * 0.8;

      final needleEnd = Offset(
        center.dx + needleLength * math.cos(needleAngle),
        center.dy + needleLength * math.sin(needleAngle),
      );

      canvas.drawLine(center, needleEnd, needlePaint);

      // Draw center dot
      final centerDotPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, 4, centerDotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.startAngle != startAngle ||
        oldDelegate.sweepAngle != sweepAngle ||
        oldDelegate.showNeedle != showNeedle;
  }
}

/// Linear progress chart
class LinearProgressChartComponent extends StatefulWidget {
  final double percentage;
  final double height;
  final double? width;
  final Color color;
  final Color backgroundColor;
  final BorderRadius? borderRadius;
  final String? label;
  final bool showPercentage;
  final bool showAnimation;

  const LinearProgressChartComponent({
    super.key,
    required this.percentage,
    this.height = 20.0,
    this.width,
    this.color = Colors.blue,
    this.backgroundColor = Colors.grey,
    this.borderRadius,
    this.label,
    this.showPercentage = true,
    this.showAnimation = true,
  });

  @override
  State<LinearProgressChartComponent> createState() =>
      _LinearProgressChartComponentState();
}

class _LinearProgressChartComponentState
    extends State<LinearProgressChartComponent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.percentage / 100).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.showAnimation) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (widget.showPercentage)
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    final animatedPercentage = (_animation.value * 100).round();
                    return Text(
                      '$animatedPercentage%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: widget.color,
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor.withOpacity(0.3),
            borderRadius:
                widget.borderRadius ?? BorderRadius.circular(widget.height / 2),
          ),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _animation.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius:
                        widget.borderRadius ??
                        BorderRadius.circular(widget.height / 2),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
