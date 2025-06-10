// File: file_format_section.dart
import 'package:flutter/material.dart';
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
            Icon(Icons.file_copy, color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'File Format',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FileFormatCard(
                isSelected: selectedFormat == 'xlsx',
                format: 'xlsx',
                title: 'Excel (.xlsx)',
                subtitle: 'Spreadsheet with formatting',
                icon: Icons.table_chart,
                color: Colors.green,
                onTap: onFormatSelected,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FileFormatCard(
                isSelected: selectedFormat == 'csv',
                format: 'csv',
                title: 'CSV (.csv)',
                subtitle: 'Plain text, comma-separated',
                icon: Icons.text_snippet,
                color: Colors.orange,
                onTap: onFormatSelected,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
