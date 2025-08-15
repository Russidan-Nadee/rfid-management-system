import 'package:flutter/material.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../app/theme/app_typography.dart';

class DateFilterCard extends StatelessWidget {
  final bool isSelected;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final Widget child;

  const DateFilterCard({
    super.key,
    required this.isSelected,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive padding and sizing
    final cardPadding = screenWidth >= 1024
        ? AppSpacing.paddingXL
        : AppSpacing.paddingLG;

    final iconSize = screenWidth >= 1024 ? 28.0 : 24.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: screenWidth >= 1024 ? 140 : 120,
        padding: cardPadding,
        decoration: _buildCardDecoration(theme),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : color,
                  size: iconSize,
                ),
                const Spacer(),
                if (isSelected)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.check,
                      size: 12,
                      color: color,
                    ),
                  ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: AppTextStyles.button.copyWith(
                fontSize: screenWidth >= 1024 ? 15 : 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            SizedBox(height: AppSpacing.xs),
            Expanded(
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildCardDecoration(ThemeData theme) {
    if (isSelected) {
      return AppDecorations.custom(
        color: color,
        borderRadius: AppBorders.lg,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      );
    } else {
      return AppDecorations.custom(
        color: theme.colorScheme.surface,
        borderRadius: AppBorders.lg,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      );
    }
  }
}