// Path: frontend/lib/features/search/presentation/widgets/search_input_bar.dart
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/features/search/search_localizations.dart';

class SearchInputBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  const SearchInputBar({
    super.key,
    required this.searchController,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = SearchLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.colorScheme.surface,
      child: TextField(
        controller: searchController,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: l10n.searchPlaceholder,
          hintStyle: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkTextMuted
                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          filled: true,
          fillColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkSurfaceVariant
              : theme.colorScheme.primary.withValues(alpha: 0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: Theme.of(context).brightness == Brightness.dark
                ? BorderSide(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  )
                : BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : theme.colorScheme.primary,
              width: 2,
            ),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkTextSecondary
                : theme.colorScheme.primary,
          ),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextSecondary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  onPressed: onClear,
                )
              : null,
        ),
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkText
              : theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
