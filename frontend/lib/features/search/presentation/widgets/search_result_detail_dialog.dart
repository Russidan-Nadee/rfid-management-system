// Path: frontend/lib/features/search/presentation/widgets/search_result_detail_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/app/theme/app_colors.dart';
import '../../../../l10n/features/search/search_localizations.dart';
import '../../domain/entities/search_result_entity.dart';

class SearchResultDetailDialog extends StatelessWidget {
  final SearchResultEntity result;

  const SearchResultDetailDialog({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = SearchLocalizations.of(context);

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
            _buildHeader(context, theme, l10n),

            // Content: Grid Layout
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildGridLayout(context, theme, l10n),
              ),
            ),

            // Footer Buttons
            _buildFooter(context, theme, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    SearchLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurfaceVariant
            : theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            result.entityIcon,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkText
                : theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.itemDetails,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkText
                        : theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  result.entityType.toUpperCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextSecondary
                        : theme.colorScheme.primary.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkText
                  : theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridLayout(
    BuildContext context,
    ThemeData theme,
    SearchLocalizations l10n,
  ) {
    final sections = _groupFieldsBySection(l10n);
    final sectionWidgets = sections.entries
        .where((entry) => entry.value.isNotEmpty)
        .map(
          (entry) =>
              _buildSection(entry.key, entry.value, theme, context, l10n),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.completeInformation,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkText
                : theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        // Responsive Grid Layout
        LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final isMobile = availableWidth < 600;

            if (isMobile) {
              // Mobile: 1 column
              return Column(children: sectionWidgets);
            } else {
              // Desktop/Tablet: 2 columns with IntrinsicHeight
              return _buildTwoColumnGrid(sectionWidgets, theme, context);
            }
          },
        ),
      ],
    );
  }

  Widget _buildTwoColumnGrid(
    List<Widget> sections,
    ThemeData theme,
    BuildContext context,
  ) {
    final rows = <Widget>[];

    for (int i = 0; i < sections.length; i += 2) {
      final leftWidget = sections[i];
      final rightWidget = i + 1 < sections.length ? sections[i + 1] : null;

      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left column
              Expanded(flex: 1, child: leftWidget),
              const SizedBox(width: 12),
              // Right column
              Expanded(flex: 1, child: rightWidget ?? const SizedBox()),
            ],
          ),
        ),
      );
    }

    return Column(children: rows);
  }

  Widget _buildSection(
    String sectionTitle,
    List<MapEntry<String, String>> fields,
    ThemeData theme,
    BuildContext context,
    SearchLocalizations l10n,
  ) {
    if (fields.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Section header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkSurfaceVariant
                  : theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              sectionTitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkText
                    : theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Section content - แสดงข้อมูลทั้งหมด
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkSurface.withValues(alpha: 0.3)
                  : theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkBorder.withValues(alpha: 0.2)
                    : theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: fields.map((entry) {
                return _buildCompactInfoRow(
                  _formatFieldName(entry.key),
                  entry.value,
                  theme,
                  context,
                  l10n,
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
    SearchLocalizations l10n,
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
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value.isEmpty ? l10n.empty : value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: value.isEmpty
                    ? (Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkTextMuted
                          : theme.colorScheme.onSurface.withValues(alpha: 0.4))
                    : (Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkText
                          : theme.colorScheme.onSurface),
              ),
            ),
          ),
          // Smaller copy button
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label ${l10n.copied}'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.copy,
                size: 12,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextMuted
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(
    BuildContext context,
    ThemeData theme,
    SearchLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkBorder.withValues(alpha: 0.2)
                : theme.colorScheme.outline.withValues(alpha: 0.2),
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
            child: Text(
              l10n.close,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper methods for processing data

  /// จัดกลุ่ม fields เป็น sections ตามประเภท
  Map<String, List<MapEntry<String, String>>> _groupFieldsBySection(
    SearchLocalizations l10n,
  ) {
    final allFields = _getAllFields();
    final sections = <String, List<MapEntry<String, String>>>{
      l10n.assetInformation: [],
      l10n.locationAndPlant: [],
      l10n.department: [],
      l10n.userInformation: [],
      l10n.timestamps: [],
      l10n.otherInformation: [],
    };

    for (final entry in allFields.entries) {
      final fieldName = entry.key.toLowerCase();

      // เช็ค plant fields ก่อน (รวม plant_description)
      if (fieldName.contains('plant')) {
        sections[l10n.locationAndPlant]!.add(entry);
      }
      // เช็ค location fields
      else if (fieldName.contains('location')) {
        sections[l10n.locationAndPlant]!.add(entry);
      }
      // เช็ค department fields ก่อน (รวม dept_description)
      else if (fieldName.contains('dept')) {
        sections[l10n.department]!.add(entry);
      }
      // User Information
      else if (_isUserField(fieldName)) {
        sections[l10n.userInformation]!.add(entry);
      }
      // Timestamps
      else if (_isTimestampField(fieldName)) {
        sections[l10n.timestamps]!.add(entry);
      }
      // Asset Information (เช็คหลังสุด)
      else if (_isAssetField(fieldName)) {
        sections[l10n.assetInformation]!.add(entry);
      }
      // Other
      else {
        sections[l10n.otherInformation]!.add(entry);
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

      // ถ้าเป็น field "data" ที่มีข้อมูลรวมกัน ให้ parse แยกออกมา
      if (entry.key.toLowerCase() == 'data' && value.contains(',')) {
        final parsedData = _parseDataField(value);
        allFields.addAll(parsedData);
      } else {
        allFields[entry.key] = value;
      }
    }

    return allFields;
  }

  /// Parse ข้อมูลจาก field "data" ที่เป็น string รวมกัน
  Map<String, String> _parseDataField(String dataString) {
    final parsed = <String, String>{};

    // ทำความสะอาด string ก่อน parse
    String cleanedData = dataString
        .replaceAll(RegExp(r'^\(|\)$'), '') // ลบ parentheses หน้าหลัง
        .trim();

    // แยก data string ตาม pattern key: value (รองรับทั้งมี comma และไม่มี)
    final regex = RegExp(r'(\w+):\s*([^,]+?)(?:,\s*|\s*$)');
    final matches = regex.allMatches(cleanedData);

    for (final match in matches) {
      final key = match.group(1)?.trim() ?? '';
      final value = match.group(2)?.trim() ?? '';

      if (key.isNotEmpty && value.isNotEmpty && value != 'null') {
        parsed[key] = value;
      }
    }

    // ถ้า regex ไม่ได้ผลหรือได้น้อยเกินไป ให้ใช้วิธี split manual
    if (parsed.length <= 2) {
      return _manualParseDataField(cleanedData);
    }

    return parsed;
  }

  /// Parse แบบ manual เป็น fallback
  Map<String, String> _manualParseDataField(String dataString) {
    final parsed = <String, String>{};

    // แยกตาม comma แล้วหา pattern key: value
    final parts = dataString.split(',');

    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.contains(':')) {
        final colonIndex = trimmed.indexOf(':');
        final key = trimmed.substring(0, colonIndex).trim();
        final value = trimmed.substring(colonIndex + 1).trim();

        if (key.isNotEmpty && value.isNotEmpty && value != 'null') {
          parsed[key] = value;
        }
      }
    }

    return parsed;
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
