// Path: frontend/lib/features/search/presentation/widgets/search_result_detail_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/search_result_entity.dart';

class SearchResultDetailDialog extends StatelessWidget {
  final SearchResultEntity result;

  const SearchResultDetailDialog({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            // Header
            _buildHeader(context, theme),

            // Content: All Fields (No duplicates)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildAllFieldsSection(context, theme),
              ),
            ),

            // Footer Buttons
            _buildFooter(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(result.entityIcon, color: theme.colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Item Details',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  result.entityType.toUpperCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close, color: theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildAllFieldsSection(BuildContext context, ThemeData theme) {
    // แยกข้อมูลเป็น sections
    final sections = _groupFieldsBySection();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📊 Complete Information',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        // แสดงแต่ละ section
        ...sections.entries.map((sectionEntry) {
          return _buildSection(
            sectionEntry.key,
            sectionEntry.value,
            theme,
            context,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSection(
    String sectionTitle,
    List<MapEntry<String, String>> fields,
    ThemeData theme,
    BuildContext context,
  ) {
    if (fields.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              sectionTitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Section content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: fields.map((entry) {
                return _buildCompactInfoRow(
                  _formatFieldName(entry.key),
                  entry.value,
                  theme,
                  context,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactInfoRow(
    String label,
    String value,
    ThemeData theme,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value.isEmpty ? '(empty)' : value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: value.isEmpty
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
          // Smaller copy button
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label copied'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.copy,
                size: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Close',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper methods for processing data

  /// จัดกลุ่ม fields เป็น sections ตามประเภท
  Map<String, List<MapEntry<String, String>>> _groupFieldsBySection() {
    final allFields = _getAllFields();
    final sections = <String, List<MapEntry<String, String>>>{
      '📦 Asset Information': [],
      '🏭 Location & Plant': [],
      '🏢 Department': [],
      '👤 User Information': [],
      '📅 Timestamps': [],
      '📋 Other Information': [],
    };

    for (final entry in allFields.entries) {
      final fieldName = entry.key.toLowerCase();

      // เช็ค plant fields ก่อน (รวม plant_description)
      if (fieldName.contains('plant')) {
        sections['🏭 Location & Plant']!.add(entry);
      }
      // เช็ค location fields
      else if (fieldName.contains('location')) {
        sections['🏭 Location & Plant']!.add(entry);
      }
      // เช็ค department fields ก่อน (รวม dept_description)
      else if (fieldName.contains('dept')) {
        sections['🏢 Department']!.add(entry);
      }
      // User Information
      else if (_isUserField(fieldName)) {
        sections['👤 User Information']!.add(entry);
      }
      // Timestamps
      else if (_isTimestampField(fieldName)) {
        sections['📅 Timestamps']!.add(entry);
      }
      // Asset Information (เช็คหลังสุด)
      else if (_isAssetField(fieldName)) {
        sections['📦 Asset Information']!.add(entry);
      }
      // Other
      else {
        sections['📋 Other Information']!.add(entry);
      }
    }
    // เรียงลำดับ fields ใน section
    for (final sectionName in sections.keys) {
      sections[sectionName]!.sort(
        (a, b) => _getFieldPriority(a.key).compareTo(_getFieldPriority(b.key)),
      );
    }

    return sections;
  }

  /// แสดงทุก fields ที่มีข้อมูล
  Map<String, String> _getAllFields() {
    final allFields = <String, String>{};

    for (final entry in result.data.entries) {
      final value = entry.value?.toString().trim() ?? '';

      // ข้ามแค่ field ที่ไม่มีค่าหรือเป็น null เท่านั้น
      if (value.isEmpty || value == 'null') continue;

      allFields[entry.key] = value;
    }

    return allFields;
  }

  /// ตรวจสอบประเภท field
  bool _isAssetField(String fieldName) {
    return fieldName.contains('asset') ||
        fieldName.contains('description') ||
        fieldName.contains('serial') ||
        fieldName.contains('inventory') ||
        fieldName.contains('quantity') ||
        fieldName.contains('unit') ||
        fieldName.contains('status');
  }

  bool _isUserField(String fieldName) {
    return fieldName.contains('created_by') ||
        fieldName.contains('user') ||
        fieldName.contains('role');
  }

  bool _isTimestampField(String fieldName) {
    return fieldName.contains('created_at') ||
        fieldName.contains('updated_at') ||
        fieldName.contains('deactivated_at') ||
        fieldName.contains('date') ||
        fieldName.contains('time');
  }

  /// กำหนด priority สำหรับการเรียงลำดับ fields
  int _getFieldPriority(String fieldName) {
    final name = fieldName.toLowerCase();

    // Fields สำคัญแสดงก่อน
    if (name.contains('description')) return 1; // Description ก่อน Code
    if (name.contains('id') || name.contains('no')) return 2;
    if (name.contains('title') || name.contains('name')) return 3;
    if (name.contains('code')) return 4; // Code หลัง Description
    if (name.contains('status')) return 5;
    if (name.contains('type')) return 6;
    if (name.contains('date') || name.contains('time')) return 7;
    if (name.contains('created') || name.contains('updated')) return 8;

    // Fields อื่นๆ
    return 9;
  }

  /// แปลง field name ให้อ่านง่ายขึ้น
  String _formatFieldName(String fieldName) {
    // แปลง snake_case เป็น Title Case
    return fieldName
        .split('_')
        .map(
          (word) => word.isEmpty
              ? ''
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }
}
