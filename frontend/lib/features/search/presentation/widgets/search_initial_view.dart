// Path: frontend/lib/features/search/presentation/widgets/search_initial_view.dart
import 'package:flutter/material.dart';

class SearchInitialView extends StatelessWidget {
  const SearchInitialView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: theme.colorScheme.onBackground.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Start your search', // Changed to English
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onBackground.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Type a query to see results', // Changed to English
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onBackground.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
