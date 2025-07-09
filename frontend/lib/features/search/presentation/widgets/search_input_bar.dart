// Path: frontend/lib/features/search/presentation/widgets/search_input_bar.dart
import 'package:flutter/material.dart';

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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color:
          theme.colorScheme.surface, // Background color for the search bar area
      child: TextField(
        controller: searchController,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: 'Search...', // Placeholder text
          hintStyle: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          filled: true,
          // Decoration: TextField fill color is a very light primary color
          fillColor: theme.colorScheme.primary.withValues(
            alpha: 0.05,
          ), // Light blue fill for the search field
          border: OutlineInputBorder(
            // No border for the TextField
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(
            Icons.search,
            color:
                theme.colorScheme.primary, // Primary color for the search icon
          ),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: theme.colorScheme.onSurface.withValues(
                      alpha: 0.6,
                    ), // Clear icon color
                  ),
                  onPressed: onClear,
                )
              : null,
        ),
        style: TextStyle(
          color: theme.colorScheme.onSurface, // Text color in the input field
        ),
      ),
    );
  }
}
