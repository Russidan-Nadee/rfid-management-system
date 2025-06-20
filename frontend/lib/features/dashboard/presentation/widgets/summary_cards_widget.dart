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
      return _buildLoadingCards(context);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // คำนวณจำนวน columns ตามขนาดหน้าจอ
          final screenWidth = constraints.maxWidth;
          int crossAxisCount;
          double childAspectRatio;

          if (screenWidth > 800) {
            // Desktop/Tablet landscape - 4 columns
            crossAxisCount = 4;
            childAspectRatio = 1.3;
          } else if (screenWidth > 600) {
            // Tablet portrait - 2 columns
            crossAxisCount = 2;
            childAspectRatio = 1.4;
          } else {
            // Mobile - 2 columns
            crossAxisCount = 2;
            childAspectRatio = 1.2;
          }

          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _SummaryCard(
                icon: LucideIcons.boxes,
                iconColor: AppColors.primary,
                label: 'All Assets',
                labelColor: AppColors.primary,
                value: Helpers.formatNumber(stats.overview.totalAssets.value),
                valueColor: AppColors.primary,
                trend: stats.overview.totalAssets.trend,
              ),
              _SummaryCard(
                icon: LucideIcons.badgeCheck,
                iconColor: AppColors.assetActive,
                labelColor: AppColors.assetActive,
                label: 'Active',
                value: Helpers.formatNumber(stats.overview.activeAssets.value),
                valueColor: AppColors.assetActive,
                trend: stats.overview.activeAssets.trend,
              ),
              _SummaryCard(
                icon: LucideIcons.badgeX,
                label: 'Inactive',
                iconColor: AppColors.assetInactive,
                labelColor: AppColors.assetInactive,
                value: Helpers.formatNumber(
                  stats.overview.inactiveAssets.value,
                ),
                valueColor: AppColors.assetInactive,
                trend: stats.overview.inactiveAssets.trend,
              ),
              _SummaryCard(
                icon: LucideIcons.packagePlus,
                iconColor: AppColors.assetCreated,
                labelColor: AppColors.assetCreated,
                label: 'New Assets',
                value: Helpers.formatNumber(stats.overview.createdAssets.value),
                valueColor: AppColors.assetCreated,
                trend: stats.overview.createdAssets.trend,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          int crossAxisCount;
          double childAspectRatio;

          if (screenWidth > 800) {
            crossAxisCount = 4;
            childAspectRatio = 1.1;
          } else if (screenWidth > 600) {
            crossAxisCount = 2;
            childAspectRatio = 1.2;
          } else {
            crossAxisCount = 2;
            childAspectRatio = 1.0;
          }

          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: List.generate(4, (index) => _LoadingSummaryCard()),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final Color? iconColor;
  final Color? labelColor;
  final String trend;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.iconColor,
    this.labelColor,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: iconColor),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: labelColor,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LoadingSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Spacer(),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: 60,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 80,
            height: 13,
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
