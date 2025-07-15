// Path: frontend/lib/features/export/presentation/widgets/create_export_button.dart
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../app/theme/app_typography.dart';

class CreateExportButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? loadingMessage;
  final String? label;
  final IconData? icon;

  const CreateExportButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.loadingMessage,
    this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = !isLoading && onPressed != null;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: _buildContainerDecoration(theme, isEnabled),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: AppBorders.lg,
          child: Container(
            padding: AppSpacing.buttonPaddingSymmetric,
            child: _buildContent(context, theme),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildContainerDecoration(ThemeData theme, bool isEnabled) {
    if (isLoading) {
      return AppDecorations.buttonSecondary.copyWith(
        color: theme.colorScheme.surfaceVariant,
      );
    }

    if (isEnabled) {
      return AppDecorations.buttonPrimary.copyWith(
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      );
    }

    return AppDecorations.buttonSecondary.copyWith(
      color: theme.colorScheme.surfaceVariant,
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme) {
    if (isLoading) {
      return _buildLoadingContent(theme);
    }

    return _buildNormalContent(theme);
  }

  Widget _buildLoadingContent(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        if (loadingMessage != null) ...[
          AppSpacing.horizontalSpaceLG,
          Flexible(
            child: Text(
              loadingMessage!,
              style: AppTextStyles.button.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNormalContent(ThemeData theme) {
    final isEnabled = onPressed != null;
    final buttonLabel = label ?? 'Export File';
    final buttonIcon = icon ?? Icons.upload;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          buttonIcon,
          color: isEnabled
              ? AppColors.onPrimary
              : theme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
        AppSpacing.horizontalSpaceSM,
        Text(
          buttonLabel,
          style: AppTextStyles.button.copyWith(
            color: isEnabled
                ? AppColors.onPrimary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Specialized version for Export functionality
class ExportActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? loadingMessage;
  final String format;
  final bool hasDateRange;
  final bool hasFilters;

  const ExportActionButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.loadingMessage,
    required this.format,
    this.hasDateRange = false,
    this.hasFilters = false,
  });

  @override
  Widget build(BuildContext context) {
    final label = _buildLabel();

    return CreateExportButton(
      onPressed: onPressed,
      isLoading: isLoading,
      loadingMessage: loadingMessage,
      label: label,
      icon: _getFormatIcon(),
    );
  }

  String _buildLabel() {
    final formatLabel = format.toUpperCase();

    if (hasDateRange && hasFilters) {
      return 'Export $formatLabel (Filtered)';
    } else if (hasDateRange) {
      return 'Export $formatLabel (Date Range)';
    } else if (hasFilters) {
      return 'Export $formatLabel (Filtered)';
    } else {
      return 'Export $formatLabel';
    }
  }

  IconData _getFormatIcon() {
    switch (format.toLowerCase()) {
      case 'xlsx':
        return Icons.table_chart;
      case 'csv':
        return Icons.text_snippet;
      default:
        return Icons.upload;
    }
  }
}

/// Compact version for small spaces
class CompactExportButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const CompactExportButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = !isLoading && onPressed != null;

    return Container(
      width: 120,
      height: 40,
      decoration: BoxDecoration(
        color: isEnabled ? AppColors.primary : theme.colorScheme.surfaceVariant,
        borderRadius: AppBorders.md,
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: AppBorders.md,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.upload,
                  color: isEnabled
                      ? AppColors.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                  size: 16,
                ),
              AppSpacing.horizontalSpaceXS,
              Text(
                'Export',
                style: AppTextStyles.caption.copyWith(
                  color: isEnabled
                      ? AppColors.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
