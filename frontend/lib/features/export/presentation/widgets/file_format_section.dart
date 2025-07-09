// Path: frontend/lib/features/export/presentation/widgets/file_format_section.dart
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/app_constants.dart';
import 'file_format_card.dart';

class FileFormatSection extends StatelessWidget {
  final String selectedFormat;
  final Function(String) onFormatSelected;
  final bool? isLargeScreen; // เพิ่ม parameter ใหม่

  const FileFormatSection({
    super.key,
    required this.selectedFormat,
    required this.onFormatSelected,
    this.isLargeScreen, // optional parameter
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLarge =
        isLargeScreen ?? (screenWidth >= AppConstants.tabletBreakpoint);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, theme),
        SizedBox(
          height: AppSpacing.responsiveSpacing(
            context,
            mobile: AppSpacing.lg,
            tablet: AppSpacing.xl,
            desktop: AppSpacing.xl,
          ),
        ),
        _buildFormatCards(context, isLarge),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Icon(Icons.file_copy, color: AppColors.primary, size: 20),
        AppSpacing.horizontalSpaceSM,
        Text(
          'File Format',
          style: AppTextStyles.cardTitle.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildFormatCards(BuildContext context, bool isLarge) {
    if (isLarge) {
      return _buildLargeScreenLayout(context);
    } else {
      return _buildCompactLayout(context);
    }
  }

  Widget _buildLargeScreenLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: FileFormatCard(
                isSelected: selectedFormat == 'xlsx',
                format: 'xlsx',
                title: 'Excel (.xlsx)',
                subtitle: 'Spreadsheet with formatting',
                icon: Icons.table_chart,
                color: AppColors.excel,
                onTap: onFormatSelected,
              ),
            ),
            AppSpacing.horizontalSpaceLG,
            Expanded(
              child: FileFormatCard(
                isSelected: selectedFormat == 'csv',
                format: 'csv',
                title: 'CSV (.csv)',
                subtitle: 'Plain text, comma-separated',
                icon: Icons.text_snippet,
                color: AppColors.csv,
                onTap: onFormatSelected,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FileFormatCard(
            isSelected: selectedFormat == 'xlsx',
            format: 'xlsx',
            title: 'Excel (.xlsx)',
            subtitle: 'Spreadsheet with formatting',
            icon: Icons.table_chart,
            color: AppColors.excel,
            onTap: onFormatSelected,
          ),
        ),
        AppSpacing.horizontalSpaceLG,
        Expanded(
          child: FileFormatCard(
            isSelected: selectedFormat == 'csv',
            format: 'csv',
            title: 'CSV (.csv)',
            subtitle: 'Plain text, comma-separated',
            icon: Icons.text_snippet,
            color: AppColors.csv,
            onTap: onFormatSelected,
          ),
        ),
      ],
    );
  }
}
