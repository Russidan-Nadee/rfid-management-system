// Path: frontend/lib/features/search/presentation/widgets/search_result_card.dart
import 'package:flutter/material.dart';
import '../../domain/entities/search_result_entity.dart'; // Ensure this path is correct

class SearchResultCard extends StatelessWidget {
  final SearchResultEntity result;
  final VoidCallback? onTapped;
  final Color Function(String entityType)
  getEntityColor; // Function passed from parent
  final Color Function(String status)
  getStatusColor; // Function passed from parent

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
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.colorScheme.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.onBackground.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTapped,
        borderRadius: BorderRadius.circular(12),
        highlightColor: theme.colorScheme.primary.withOpacity(0.1),
        splashColor: theme.colorScheme.primary.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: getEntityColor(result.entityType),
                child: Icon(
                  // <<< ตรงนี้แหละครับที่ต้องเปลี่ยนจาก Text เป็น Icon
                  result
                      .entityIcon, // ตอนนี้ result.entityIcon เป็น IconData แล้ว
                  size: 24, // กำหนดขนาดไอคอน
                  color: theme
                      .colorScheme
                      .onPrimary, // สีไอคอนบนพื้นหลัง CircleAvatar
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: getEntityColor(
                              result.entityType,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            result.entityType.toUpperCase(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: getEntityColor(result.entityType),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (result.status != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: getStatusColor(
                                result.status!,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              result.statusLabel,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: getStatusColor(result.status!),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
