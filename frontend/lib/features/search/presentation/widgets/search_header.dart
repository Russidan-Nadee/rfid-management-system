import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';

class SearchHeader extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const SearchHeader({Key? key, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search assets...',
        prefixIcon: Icon(Icons.search, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
