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

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: theme.colorScheme.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: theme.colorScheme.onBackground.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTapped,
        borderRadius: BorderRadius.circular(8),
        highlightColor: theme.colorScheme.primary.withOpacity(0.05),
        splashColor: theme.colorScheme.primary.withOpacity(0.03),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Row(
            children: [
              // แสดงแค่ description
              Expanded(
                child: Text(
                  result.subtitle.isNotEmpty ? result.subtitle : result.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // ลูกศรเล็กๆ แสดงว่าแตะได้
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
