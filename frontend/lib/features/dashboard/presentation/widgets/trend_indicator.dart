// Path: frontend/lib/features/dashboard/presentation/widgets/trend_indicator.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum TrendIndicatorSize { tiny, small, medium, large }

class TrendIndicator extends StatelessWidget {
  final int changePercent;
  final String trend;
  final TrendIndicatorSize size;
  final bool showIcon;
  final bool showPercentage;

  const TrendIndicator({
    super.key,
    required this.changePercent,
    required this.trend,
    this.size = TrendIndicatorSize.small,
    this.showIcon = true,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(size);
    final trendData = _getTrendData(trend);

    if (!showIcon && !showPercentage) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: config.padding,
        vertical: config.padding / 2,
      ),
      decoration: BoxDecoration(
        color: trendData.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(config.borderRadius),
        border: Border.all(color: trendData.color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(trendData.icon, size: config.iconSize, color: trendData.color),
            if (showPercentage) SizedBox(width: config.spacing),
          ],
          if (showPercentage)
            Text(
              _formatPercentage(changePercent),
              style: TextStyle(
                fontSize: config.fontSize,
                fontWeight: FontWeight.w600,
                color: trendData.color,
              ),
            ),
        ],
      ),
    );
  }

  _TrendConfig _getConfig(TrendIndicatorSize size) {
    switch (size) {
      case TrendIndicatorSize.tiny:
        return const _TrendConfig(
          iconSize: 10,
          fontSize: 9,
          padding: 3,
          spacing: 2,
          borderRadius: 3,
        );
      case TrendIndicatorSize.small:
        return const _TrendConfig(
          iconSize: 12,
          fontSize: 11,
          padding: 4,
          spacing: 3,
          borderRadius: 4,
        );
      case TrendIndicatorSize.medium:
        return const _TrendConfig(
          iconSize: 14,
          fontSize: 12,
          padding: 6,
          spacing: 4,
          borderRadius: 6,
        );
      case TrendIndicatorSize.large:
        return const _TrendConfig(
          iconSize: 16,
          fontSize: 14,
          padding: 8,
          spacing: 5,
          borderRadius: 8,
        );
    }
  }

  _TrendData _getTrendData(String trend) {
    switch (trend.toLowerCase()) {
      case 'up':
        return _TrendData(color: AppColors.trendUp, icon: Icons.trending_up);
      case 'down':
        return _TrendData(
          color: AppColors.trendDown,
          icon: Icons.trending_down,
        );
      case 'stable':
      default:
        return _TrendData(
          color: AppColors.trendStable,
          icon: Icons.trending_flat,
        );
    }
  }

  String _formatPercentage(int percent) {
    if (percent > 0) {
      return '+$percent%';
    } else if (percent < 0) {
      return '$percent%';
    } else {
      return '0%';
    }
  }
}

class _TrendConfig {
  final double iconSize;
  final double fontSize;
  final double padding;
  final double spacing;
  final double borderRadius;

  const _TrendConfig({
    required this.iconSize,
    required this.fontSize,
    required this.padding,
    required this.spacing,
    required this.borderRadius,
  });
}

class _TrendData {
  final Color color;
  final IconData icon;

  const _TrendData({required this.color, required this.icon});
}

// Static constructors for common use cases
extension TrendIndicatorConstructors on TrendIndicator {
  static Widget iconOnly({
    required int changePercent,
    required String trend,
    TrendIndicatorSize size = TrendIndicatorSize.small,
  }) {
    return TrendIndicator(
      changePercent: changePercent,
      trend: trend,
      size: size,
      showIcon: true,
      showPercentage: false,
    );
  }

  static Widget percentageOnly({
    required int changePercent,
    required String trend,
    TrendIndicatorSize size = TrendIndicatorSize.small,
  }) {
    return TrendIndicator(
      changePercent: changePercent,
      trend: trend,
      size: size,
      showIcon: false,
      showPercentage: true,
    );
  }
}

// Simple trend badge without container
class TrendBadge extends StatelessWidget {
  final int changePercent;
  final String trend;
  final double fontSize;

  const TrendBadge({
    super.key,
    required this.changePercent,
    required this.trend,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getTrendColor(trend);

    return Text(
      changePercent >= 0 ? '+$changePercent%' : '$changePercent%',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}
