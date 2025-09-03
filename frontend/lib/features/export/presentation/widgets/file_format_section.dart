import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/app_constants.dart';
import 'file_format_card.dart';
import 'package:tp_rfid/l10n/features/export/export_localizations.dart';

class FileFormatSection extends StatelessWidget {
  final String selectedFormat;
  final Function(String) onFormatSelected;
  final bool? isLargeScreen; // optional parameter

  const FileFormatSection({
    super.key,
    required this.selectedFormat,
    required this.onFormatSelected,
    this.isLargeScreen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ExportLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLarge =
        isLargeScreen ?? (screenWidth >= AppConstants.tabletBreakpoint);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, theme, l10n),
        SizedBox(
          height: AppSpacing.responsiveSpacing(
            context,
            mobile: AppSpacing.lg,
            tablet: AppSpacing.xl,
            desktop: AppSpacing.xl,
          ),
        ),
        _buildFormatCards(context, isLarge, l10n),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    ThemeData theme,
    ExportLocalizations l10n,
  ) {
    return Row(
      children: [
        const Icon(Icons.file_copy, color: AppColors.primary, size: 20),
        AppSpacing.horizontalSpaceSM,
        Text(
          l10n.exportFormat, // แปลว่า "File Format" หรือข้อความที่กำหนดใน localization
          style: AppTextStyles.cardTitle.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildFormatCards(
    BuildContext context,
    bool isLarge,
    ExportLocalizations l10n,
  ) {
    if (isLarge) {
      return _buildLargeScreenLayout(context, l10n);
    } else {
      return _buildCompactLayout(context, l10n);
    }
  }

  Widget _buildLargeScreenLayout(
    BuildContext context,
    ExportLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: FileFormatCard(
                isSelected: selectedFormat == 'xlsx',
                format: 'xlsx',
                title: l10n.excelFormat, // 'Excel (.xlsx)'
                subtitle: l10n
                    .excelFormatDescription, // 'Spreadsheet with formatting'
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
                title: l10n.csvFormat, // 'CSV (.csv)'
                subtitle:
                    l10n.csvFormatDescription, // 'Plain text, comma-separated'
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

  Widget _buildCompactLayout(BuildContext context, ExportLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: FileFormatCard(
            isSelected: selectedFormat == 'xlsx',
            format: 'xlsx',
            title: l10n.excelFormat,
            subtitle: l10n.excelFormatDescription,
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
            title: l10n.csvFormat,
            subtitle: l10n.csvFormatDescription,
            icon: Icons.text_snippet,
            color: AppColors.csv,
            onTap: onFormatSelected,
          ),
        ),
      ],
    );
  }
}
