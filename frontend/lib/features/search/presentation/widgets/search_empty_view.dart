// Path: frontend/lib/features/search/presentation/widgets/search_empty_view.dart
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/features/search/search_localizations.dart';

class SearchEmptyView extends StatelessWidget {
  final String query;

  const SearchEmptyView({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = SearchLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkTextSecondary
                  : theme.colorScheme.onBackground.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '${l10n.noResultsFound} "$query"',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkText
                    : theme.colorScheme.onBackground.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noResultsFoundMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : theme.colorScheme.onBackground.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
