// Path: frontend/lib/features/scan/presentation/widgets/create/category_brand_info_section.dart
import 'package:flutter/material.dart';
import 'package:tp_rfid/features/scan/domain/entities/master_data_entity.dart';
import '../../../../../../app/theme/app_colors.dart';
import '../../../../../../l10n/features/scan/scan_localizations.dart';

class CategoryBrandInfoSection extends StatelessWidget {
  final String? selectedCategory;
  final String? selectedBrand;
  final List<CategoryEntity> categories;
  final List<BrandEntity> brands;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onBrandChanged;

  const CategoryBrandInfoSection({
    super.key,
    this.selectedCategory,
    this.selectedBrand,
    required this.categories,
    required this.brands,
    required this.onCategoryChanged,
    required this.onBrandChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = ScanLocalizations.of(context);

    return _buildSectionCard(
      context: context,
      title: l10n.categoryBrandInformation,
      icon: Icons.category,
      color: AppColors.primary,
      children: [
        // Category Dropdown (Top Row)
        _buildDropdownField<String>(
          context: context,
          value: selectedCategory,
          label: l10n.category,
          icon: Icons.category,
          isRequired: false,
          items: categories
              .map(
                (category) => DropdownMenuItem(
                  value: category.categoryCode,
                  child: Text(category.toString()),
                ),
              )
              .toList(),
          onChanged: onCategoryChanged,
          validator: null, // Optional field
        ),

        const SizedBox(height: 16),

        // Brand Dropdown (Bottom Row)
        _buildDropdownField<String>(
          context: context,
          value: selectedBrand,
          label: l10n.brand,
          icon: Icons.branding_watermark,
          isRequired: false,
          items: brands
              .map(
                (brand) => DropdownMenuItem(
                  value: brand.brandCode,
                  child: Text(brand.toString()),
                ),
              )
              .toList(),
          onChanged: onBrandChanged,
          validator: null, // Optional field
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onBackground,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required BuildContext context,
    required T? value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    bool isRequired = false,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(color: AppColors.onBackground),
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
      dropdownColor: AppColors.surface,
      icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
    );
  }
}
