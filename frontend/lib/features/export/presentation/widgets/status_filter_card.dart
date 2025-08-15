import 'package:flutter/material.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../app/theme/app_typography.dart';

class StatusFilterCard extends StatelessWidget {
  final bool isSelected;
  final String statusCode;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Function(String) onTap;
  final bool isMultiSelect;

  const StatusFilterCard({
    super.key,
    required this.isSelected,
    required this.statusCode,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isMultiSelect = true,
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
      onTap: () {
        onTap(statusCode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: screenWidth >= 1024 ? 140 : 120, // Fixed height for consistent card game look
        padding: cardPadding,
        decoration: _buildCardDecoration(theme),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : color,
                  size: iconSize,
                ),
                if (isMultiSelect) ...[
                  const Spacer(),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? Colors.white
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? Colors.white
                            : theme.colorScheme.outline.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            size: 12,
                            color: color,
                          )
                        : null,
                  ),
                ],
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTextStyles.button.copyWith(
                fontSize: screenWidth >= 1024 ? 15 : 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                fontSize: screenWidth >= 1024 ? 13 : 12,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.9)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
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