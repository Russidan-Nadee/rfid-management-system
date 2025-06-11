import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';

class SearchEmptyState extends StatelessWidget {
  const SearchEmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No results found',
        style: TextStyle(
          color: AppColors.onBackground.withOpacity(0.5),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
