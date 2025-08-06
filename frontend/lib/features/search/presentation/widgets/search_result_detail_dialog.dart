// Path: frontend/lib/features/search/presentation/widgets/search_result_detail_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/app/theme/app_colors.dart';
import '../../../../l10n/features/search/search_localizations.dart';
import '../../domain/entities/search_result_entity.dart';
import '../../../scan/domain/entities/asset_image_entity.dart';
import '../../../scan/domain/usecases/get_asset_images_usecase.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../di/injection.dart';

class SearchResultDetailDialog extends StatefulWidget {
  final SearchResultEntity result;

  const SearchResultDetailDialog({super.key, required this.result});

  @override
  State<SearchResultDetailDialog> createState() => _SearchResultDetailDialogState();
}

class _SearchResultDetailDialogState extends State<SearchResultDetailDialog> {
  List<AssetImageEntity> _images = [];
  bool _isLoadingImages = false;
  late final GetAssetImagesUseCase _getAssetImagesUseCase;

  @override
  void initState() {
    super.initState();
    _getAssetImagesUseCase = getIt<GetAssetImagesUseCase>();
    _loadImagesIfAsset();
  }

  void _loadImagesIfAsset() async {
    if (widget.result.isAsset) {
      final assetNo = widget.result.data['asset_no']?.toString() ?? '';
      if (assetNo.isNotEmpty) {
        setState(() {
          _isLoadingImages = true;
        });
        
        try {
          final images = await _getAssetImagesUseCase.execute(assetNo);
          if (mounted) {
            setState(() {
              _images = images;
              _isLoadingImages = false;
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _isLoadingImages = false;
            });
          }
        }
      }
    }
  }

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

            // Content: Combined Grid Layout (Image + Sections)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildCombinedGridLayout(context, theme, l10n),
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
            widget.result.entityIcon,
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
                  widget.result.entityType.toUpperCase(),
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

  Widget _buildCombinedGridLayout(
    BuildContext context,
    ThemeData theme,
    SearchLocalizations l10n,
  ) {
    // Get data sections
    final sections = _groupFieldsBySection(l10n);
    final sectionWidgets = sections.entries
        .where((entry) => entry.value.isNotEmpty)
        .map(
          (entry) =>
              _buildSection(entry.key, entry.value, theme, context, l10n),
        )
        .toList();

    // Create combined widget list: [Image, ...sections]
    final allWidgets = <Widget>[
      if (widget.result.isAsset)
        _buildCompactImageSection(theme, l10n),
      ...sectionWidgets,
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final isMobile = availableWidth < 600;

        if (isMobile) {
          // Mobile: 1 column
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: allWidgets,
          );
        } else {
          // Desktop/Tablet: 2 columns grid (1 2, 3 4, 5 6, 7)
          return _buildTwoColumnGridWithImage(allWidgets, theme, context);
        }
      },
    );
  }

  Widget _buildCompactImageSection(ThemeData theme, SearchLocalizations l10n) {
    final assetNo = widget.result.data['asset_no']?.toString() ?? '';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? AppColors.darkSurface.withValues(alpha: 0.3)
            : theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? AppColors.darkBorder.withValues(alpha: 0.2)
              : theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? AppColors.darkSurfaceVariant
                  : theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.photo_library,
                  color: theme.brightness == Brightness.dark
                      ? AppColors.darkText
                      : theme.colorScheme.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.images,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.brightness == Brightness.dark
                        ? AppColors.darkText
                        : theme.colorScheme.primary,
                  ),
                ),
                if (_isLoadingImages) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
                const Spacer(),
                if (_images.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_images.length}',
                      style: TextStyle(
                        color: theme.brightness == Brightness.dark
                            ? AppColors.darkText
                            : theme.colorScheme.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Gallery Content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              child: _isLoadingImages
                  ? Center(
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : _buildProportionalImageWidget(assetNo, theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTwoColumnGridWithImage(
    List<Widget> allWidgets,
    ThemeData theme,
    BuildContext context,
  ) {
    final rows = <Widget>[];

    for (int i = 0; i < allWidgets.length; i += 2) {
      final leftWidget = allWidgets[i];
      final rightWidget = i + 1 < allWidgets.length ? allWidgets[i + 1] : null;

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left column (1, 3, 5, 7)
                Expanded(flex: 1, child: leftWidget),
                const SizedBox(width: 12),
                // Right column (2, 4, 6, empty)
                Expanded(
                  flex: 1, 
                  child: rightWidget ?? const SizedBox(),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
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

          // Section content
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
          // Copy button
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

  // Helper methods for processing data

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

      if (fieldName.contains('plant')) {
        sections[l10n.locationAndPlant]!.add(entry);
      } else if (fieldName.contains('location')) {
        sections[l10n.locationAndPlant]!.add(entry);
      } else if (fieldName.contains('dept')) {
        sections[l10n.department]!.add(entry);
      } else if (_isUserField(fieldName)) {
        sections[l10n.userInformation]!.add(entry);
      } else if (_isTimestampField(fieldName)) {
        sections[l10n.timestamps]!.add(entry);
      } else if (_isAssetField(fieldName)) {
        sections[l10n.assetInformation]!.add(entry);
      } else {
        sections[l10n.otherInformation]!.add(entry);
      }
    }

    for (final sectionName in sections.keys) {
      sections[sectionName]!.sort(
        (a, b) => _getFieldPriority(a.key).compareTo(_getFieldPriority(b.key)),
      );
    }

    return sections;
  }

  Map<String, String> _getAllFields() {
    final allFields = <String, String>{};

    for (final entry in widget.result.data.entries) {
      final value = entry.value?.toString().trim() ?? '';

      if (value.isEmpty || value == 'null') continue;

      if (entry.key.toLowerCase() == 'data' && value.contains(',')) {
        final parsedData = _parseDataField(value);
        allFields.addAll(parsedData);
      } else {
        allFields[entry.key] = value;
      }
    }

    return allFields;
  }

  Map<String, String> _parseDataField(String dataString) {
    final parsed = <String, String>{};

    String cleanedData = dataString
        .replaceAll(RegExp(r'^\(|\)$'), '')
        .trim();

    final regex = RegExp(r'(\w+):\s*([^,]+?)(?:,\s*|\s*$)');
    final matches = regex.allMatches(cleanedData);

    for (final match in matches) {
      final key = match.group(1)?.trim() ?? '';
      final value = match.group(2)?.trim() ?? '';

      if (key.isNotEmpty && value.isNotEmpty && value != 'null') {
        parsed[key] = value;
      }
    }

    if (parsed.length <= 2) {
      return _manualParseDataField(cleanedData);
    }

    return parsed;
  }

  Map<String, String> _manualParseDataField(String dataString) {
    final parsed = <String, String>{};

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

  int _getFieldPriority(String fieldName) {
    final name = fieldName.toLowerCase();

    if (name.contains('description')) return 1;
    if (name.contains('id') || name.contains('no')) return 2;
    if (name.contains('title') || name.contains('name')) return 3;
    if (name.contains('code')) return 4;
    if (name.contains('status')) return 5;
    if (name.contains('type')) return 6;
    if (name.contains('date') || name.contains('time')) return 7;
    if (name.contains('created') || name.contains('updated')) return 8;

    return 9;
  }

  String _formatFieldName(String fieldName) {
    return fieldName
        .split('_')
        .map(
          (word) => word.isEmpty
              ? ''
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  Widget _buildProportionalImageWidget(String assetNo, ThemeData theme) {
    if (_images.isEmpty) {
      return _buildEmptyImageState(theme);
    }

    final displayImage = _images.firstWhere(
      (img) => img.isPrimary,
      orElse: () => _images.first,
    );

    return _buildScalableImageCard(displayImage, theme);
  }

  Widget _buildEmptyImageState(ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? AppColors.darkSurface.withValues(alpha: 0.1)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? AppColors.darkBorder.withValues(alpha: 0.3)
              : theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 40,
            color: theme.brightness == Brightness.dark
                ? AppColors.darkTextSecondary
                : theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'No Images',
            style: TextStyle(
              fontSize: 12,
              color: theme.brightness == Brightness.dark
                  ? AppColors.darkTextSecondary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScalableImageCard(AssetImageEntity image, ThemeData theme) {
    final thumbnailUrl = '${ApiConstants.baseUrl}${ApiConstants.serveImage(image.id)}?size=thumb';

    return GestureDetector(
      onTap: () => _showFullImageDialog(image),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: image.isPrimary
                ? theme.colorScheme.primary
                : (theme.brightness == Brightness.dark
                      ? AppColors.darkBorder
                      : theme.colorScheme.outline.withValues(alpha: 0.3)),
            width: image.isPrimary ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Container(
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: thumbnailUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Container(
                    width: double.infinity,
                    color: theme.brightness == Brightness.dark
                        ? AppColors.darkSurface
                        : theme.colorScheme.surface,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: double.infinity,
                    color: theme.brightness == Brightness.dark
                        ? AppColors.darkSurface
                        : theme.colorScheme.surface,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          color: theme.brightness == Brightness.dark
                              ? AppColors.darkTextSecondary
                              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          size: 40,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Failed to load',
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.brightness == Brightness.dark
                                ? AppColors.darkTextSecondary
                                : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (image.isPrimary)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'PRIMARY',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            if (_images.length > 1)
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.photo_library, color: Colors.white, size: 10),
                      const SizedBox(width: 2),
                      Text(
                        '${_images.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Positioned.fill(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.zoom_in,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullImageDialog(AssetImageEntity image) {
    showDialog(
      context: context,
      builder: (context) => _FullImageDialog(image: image),
    );
  }
}

class _FullImageDialog extends StatelessWidget {
  final AssetImageEntity image;

  const _FullImageDialog({required this.image});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fullImageUrl = '${ApiConstants.baseUrl}${ApiConstants.serveImage(image.id)}';

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            ),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.image, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            image.displayName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: theme.brightness == Brightness.dark
                                  ? AppColors.darkText
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 40,
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                    ),
                    child: CachedNetworkImage(
                      imageUrl: fullImageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Container(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_not_supported, size: 64),
                            Text('Failed to load image'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}