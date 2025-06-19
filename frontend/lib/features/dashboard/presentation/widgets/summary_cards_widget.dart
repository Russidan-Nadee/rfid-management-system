// Path: frontend/lib/features/dashboard/presentation/widgets/summary_cards_widget.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/helpers.dart';
import '../../domain/entities/dashboard_stats.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SummaryCardsWidget extends StatelessWidget {
  final DashboardStats stats;
  final bool isLoading;

  const SummaryCardsWidget({
    super.key,
    required this.stats,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingCards();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _SummaryCard(
            icon: LucideIcons.boxes,
            iconColor: AppColors.primary,
            label: 'All Assets',
            labelColor: AppColors.primary,
            value: Helpers.formatNumber(stats.overview.totalAssets.value),
            subtext: _formatTrendText(stats.overview.totalAssets),
            valueColor: AppColors.primary,
            trend: stats.overview.totalAssets.trend,
          ),
          _SummaryCard(
            icon: LucideIcons.badgeCheck,
            iconColor: AppColors.assetActive,
            labelColor: AppColors.assetActive,
            label: 'Active',
            value: Helpers.formatNumber(stats.overview.activeAssets.value),
            subtext: _formatTrendText(stats.overview.activeAssets),
            valueColor: AppColors.assetActive,
            trend: stats.overview.activeAssets.trend,
          ),
          _SummaryCard(
            icon: LucideIcons.badgeX,
            label: 'Inactive',
            iconColor: AppColors.assetInactive,
            labelColor: AppColors.assetInactive,
            value: Helpers.formatNumber(stats.overview.inactiveAssets.value),
            subtext: _formatTrendText(stats.overview.inactiveAssets),
            valueColor: AppColors.assetInactive,
            trend: stats.overview.inactiveAssets.trend,
          ),
          _SummaryCard(
            icon: LucideIcons.packagePlus,
            iconColor: AppColors.assetCreated,
            labelColor: AppColors.assetCreated,
            label: 'New Assets',
            value: Helpers.formatNumber(stats.overview.createdAssets.value),
            subtext: _formatTrendText(stats.overview.createdAssets),
            valueColor: AppColors.assetCreated,
            trend: stats.overview.createdAssets.trend,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCards() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(4, (index) => _LoadingSummaryCard()),
    );
  }

  String _formatTrendText(AssetCount assetCount) {
    final sign = assetCount.changePercent > 0 ? '+' : '';
    return '$sign${assetCount.changePercent}%';
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtext;
  final Color? valueColor;
  final Color? iconColor;
  final Color? labelColor;
  final String trend;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    this.subtext,
    this.valueColor,
    this.iconColor,
    this.labelColor,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 28, color: iconColor ?? theme.primaryColor),
              const Spacer(),
              _buildTrendIcon(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtext != null) ...[
            const SizedBox(height: 4),
            Text(
              subtext!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.getTrendColor(trend),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: labelColor ?? theme.textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendIcon() {
    IconData trendIcon;
    Color trendColor;

    switch (trend) {
      case 'up':
        trendIcon = Icons.trending_up;
        trendColor = AppColors.trendUp;
        break;
      case 'down':
        trendIcon = Icons.trending_down;
        trendColor = AppColors.trendDown;
        break;
      default:
        trendIcon = Icons.trending_flat;
        trendColor = AppColors.trendStable;
    }

    return Icon(trendIcon, size: 20, color: trendColor);
  }
}

class _LoadingSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 160,
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Spacer(),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: 80,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 60,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 100,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
