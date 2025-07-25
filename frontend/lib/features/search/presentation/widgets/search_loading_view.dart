// Path: frontend/lib/features/search/presentation/widgets/search_loading_view.dart
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/features/search/search_localizations.dart';

class SearchLoadingView extends StatelessWidget {
  final String query;

  const SearchLoadingView({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = SearchLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).brightness == Brightness.dark
                ? theme.colorScheme.onSurface
                : theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            '${l10n.searchingFor} "$query"...',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkText
                  : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
