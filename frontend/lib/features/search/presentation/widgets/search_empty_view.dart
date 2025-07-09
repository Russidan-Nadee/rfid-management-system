// Path: frontend/lib/features/search/presentation/widgets/search_empty_view.dart
import 'package:flutter/material.dart';

class SearchEmptyView extends StatelessWidget {
  final String query;

  const SearchEmptyView({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.onBackground.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No results found for "$query"', // Changed to English
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onBackground.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term or check your spelling.', // Changed to English
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onBackground.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
