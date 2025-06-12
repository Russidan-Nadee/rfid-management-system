// Path: frontend/lib/features/dashboard/presentation/widgets/dashboard_card.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DashboardCard extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final List<Widget>? actions;
  final bool showBorder;
  final Color? backgroundColor;

  const DashboardCard({
    super.key,
    this.title,
    this.icon,
    required this.child,
    this.padding,
    this.onTap,
    this.actions,
    this.showBorder = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: showBorder
            ? BorderSide(color: AppColors.cardBorder, width: 1)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: backgroundColor ?? AppColors.surface,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null || icon != null || actions != null)
                _buildHeader(),
              if (title != null || icon != null || actions != null)
                const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
        ],
        if (title != null)
          Expanded(
            child: Text(
              title!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.onBackground,
              ),
            ),
          ),
        if (actions != null) ...actions!,
      ],
    );
  }
}

// Compact version for smaller content
class DashboardCardCompact extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final Widget child;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const DashboardCardCompact({
    super.key,
    this.title,
    this.icon,
    required this.child,
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppColors.cardBorder, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: backgroundColor ?? AppColors.surface,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null || icon != null) ...[
                Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                    ],
                    if (title != null)
                      Text(
                        title!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onBackground,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}

// Large version for hero content
class DashboardCardLarge extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? headerColor;

  const DashboardCardLarge({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    required this.child,
    this.padding,
    this.onTap,
    this.actions,
    this.backgroundColor,
    this.headerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.cardBorder, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: backgroundColor ?? AppColors.surface,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null ||
                  subtitle != null ||
                  icon != null ||
                  actions != null)
                _buildLargeHeader(),
              if (title != null ||
                  subtitle != null ||
                  icon != null ||
                  actions != null)
                const SizedBox(height: 20),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLargeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (headerColor ?? AppColors.primary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: headerColor ?? AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onBackground,
                      ),
                    ),
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
            if (actions != null) ...actions!,
          ],
        ),
      ],
    );
  }
}

// Section card with dividers
class DashboardSection extends StatelessWidget {
  final String title;
  final IconData? icon;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onViewAll;
  final String? viewAllText;

  const DashboardSection({
    super.key,
    required this.title,
    this.icon,
    required this.children,
    this.padding,
    this.onViewAll,
    this.viewAllText,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      padding: padding ?? const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onBackground,
                    ),
                  ),
                ],
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text(
                    viewAllText ?? 'View All >',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ...children.map(
            (child) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
