// Path: frontend/lib/features/search/presentation/widgets/search_result_card.dart
import 'package:flutter/material.dart';
import '../../domain/entities/search_result_entity.dart';

class SearchResultCard extends StatelessWidget {
  final SearchResultEntity result;
  final VoidCallback? onTapped;
  final Color Function(String entityType) getEntityColor;
  final Color Function(String status) getStatusColor;

  const SearchResultCard({
    super.key,
    required this.result,
    this.onTapped,
    required this.getEntityColor,
    required this.getStatusColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ดึง asset_no จาก data
    final assetNo = result.data['asset_no']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: theme.colorScheme.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: theme.colorScheme.onBackground.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTapped,
        borderRadius: BorderRadius.circular(8),
        highlightColor: theme.colorScheme.primary.withValues(alpha: 0.05),
        splashColor: theme.colorScheme.primary.withValues(alpha: 0.03),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Row(
            children: [
              // แสดง 2 บรรทัด: Description + Asset No
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // บรรทัดแรก: Description (จาก title)
                    Text(
                      result.title.isNotEmpty ? result.title : 'No description',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // บรรทัดที่สอง: Asset No
                    Text(
                      assetNo.isNotEmpty ? assetNo : 'No asset number',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              // ลูกศรเล็กๆ แสดงว่าแตะได้
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
