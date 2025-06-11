import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';

class SearchResultsView extends StatelessWidget {
  final List<String> results;
  const SearchResultsView({Key? key, required this.results}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = results[index];
        return ListTile(
          title: Text(
            item,
            style: TextStyle(
              color: AppColors.onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Icon(Icons.chevron_right, color: AppColors.primary),
          onTap: () {
            // TODO: Handle item tap
          },
        );
      },
    );
  }
}
