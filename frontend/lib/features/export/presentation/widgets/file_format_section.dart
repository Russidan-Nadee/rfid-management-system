// Path: frontend/lib/features/export/presentation/widgets/file_format_section.dart
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import 'file_format_card.dart';

class FileFormatSection extends StatelessWidget {
  final String selectedFormat;
  final Function(String) onFormatSelected;

  const FileFormatSection({
    super.key,
    required this.selectedFormat,
    required this.onFormatSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
        ),
        AppSpacing.verticalSpaceLG,
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
}
