// Path: frontend/lib/features/search/presentation/widgets/search_loading_view.dart
import 'package:flutter/material.dart';

class SearchLoadingView extends StatelessWidget {
  final String query;

  const SearchLoadingView({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('Searching for "$query"...', style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
