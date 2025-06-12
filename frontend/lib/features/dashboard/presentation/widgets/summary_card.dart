// Path: frontend/lib/features/dashboard/presentation/widgets/summary_card.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'trend_indicator.dart';

class SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final int? changePercent;
  final String? trend;
  final VoidCallback? onTap;

  const SummaryCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.changePercent,
    this.trend,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.surface,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Icon and trend
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 20, color: color),
                  ),
                  const Spacer(),
                  if (changePercent != null && trend != null)
                    TrendIndicator(
                      changePercent: changePercent!,
                      trend: trend!,
                      size: TrendIndicatorSize.small,
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Value
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // Label
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Compact version for smaller spaces
class SummaryCardCompact extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final int? changePercent;
  final String? trend;

  const SummaryCardCompact({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.changePercent,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (changePercent != null && trend != null)
                        TrendIndicator(
                          changePercent: changePercent!,
                          trend: trend!,
                          size: TrendIndicatorSize.tiny,
                        ),
                    ],
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Large version for hero metrics
class SummaryCardLarge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? subtitle;
  final int? changePercent;
  final String? trend;
  final VoidCallback? onTap;

  const SummaryCardLarge({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.subtitle,
    this.changePercent,
    this.trend,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.surface,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 28, color: color),
                  ),
                  const Spacer(),
                  if (changePercent != null && trend != null)
                    TrendIndicator(
                      changePercent: changePercent!,
                      trend: trend!,
                      size: TrendIndicatorSize.medium,
                    ),
                ],
              ),

              const SizedBox(height: 20),

              // Value
              Text(
                value,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),

              const SizedBox(height: 8),

              // Label
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onBackground,
                ),
              ),

              // Subtitle
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
