import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';

class SearchFiltersBar extends StatelessWidget {
  const SearchFiltersBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: const Text('All'),
            selected: true,
            onSelected: (val) {},
            backgroundColor: AppColors.background,
            selectedColor: AppColors.primary.withOpacity(0.2),
            labelStyle: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          FilterChip(
            label: const Text('Active'),
            selected: false,
            onSelected: (val) {},
            backgroundColor: AppColors.background,
            selectedColor: AppColors.primary.withOpacity(0.2),
            labelStyle: TextStyle(color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          FilterChip(
            label: const Text('Inactive'),
            selected: false,
            onSelected: (val) {},
            backgroundColor: AppColors.background,
            selectedColor: AppColors.primary.withOpacity(0.2),
            labelStyle: TextStyle(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
