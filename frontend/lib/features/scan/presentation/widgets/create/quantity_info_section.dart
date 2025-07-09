// Path: frontend/lib/features/scan/presentation/pages/create_asset/widgets/quantity_info_section.dart
import 'package:flutter/material.dart';
import 'package:frontend/features/scan/domain/entities/master_data_entity.dart';
import '../../../../../../app/theme/app_colors.dart';

class QuantityInfoSection extends StatelessWidget {
  final String? selectedUnit;
  final TextEditingController quantityController;
  final TextEditingController serialController;
  final TextEditingController inventoryController;
  final List<UnitEntity> units;
  final ValueChanged<String?> onUnitChanged;
  final String? Function(String?)? unitValidator;
  final String? Function(String?)? quantityValidator;

  const QuantityInfoSection({
    super.key,
    this.selectedUnit,
    required this.quantityController,
    required this.serialController,
    required this.inventoryController,
    required this.units,
    required this.onUnitChanged,
    this.unitValidator,
    this.quantityValidator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Quantity Information Section
        _buildSectionCard(
          title: 'Quantity Information',
          icon: Icons.straighten,
          color: AppColors.warning,
          children: [
            Row(
              children: [
                // Unit Dropdown
                Expanded(
                  flex: 2,
                  child: _buildDropdownField<String>(
                    value: selectedUnit,
                    label: 'Unit',
                    icon: Icons.category,
                    isRequired: true,
                    items: units
                        .map(
                          (unit) => DropdownMenuItem(
                            value: unit.unitCode,
                            child: Text(unit.toString()),
                          ),
                        )
                        .toList(),
                    onChanged: onUnitChanged,
                    validator: unitValidator,
                  ),
                ),
                const SizedBox(width: 16),

                // Quantity
                Expanded(
                  child: _buildTextFormField(
                    controller: quantityController,
                    label: 'Quantity',
                    icon: Icons.numbers,
                    keyboardType: TextInputType.number,
                    validator: quantityValidator,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Optional Information Section
        _buildSectionCard(
          title: 'Optional Information',
          icon: Icons.info_outline,
          color: AppColors.textSecondary,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildTextFormField(
                    controller: serialController,
                    label: 'Serial Number',
                    icon: Icons.tag,
                    hint: 'Optional',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextFormField(
                    controller: inventoryController,
                    label: 'Inventory Number',
                    icon: Icons.inventory,
                    hint: 'Optional',
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionCard({
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
                  style: TextStyle(
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

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = false,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: AppColors.onBackground),
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        labelStyle: TextStyle(color: AppColors.textSecondary),
        hintStyle: TextStyle(color: AppColors.textTertiary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.error),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
    );
  }

  Widget _buildDropdownField<T>({
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
      style: TextStyle(color: AppColors.onBackground),
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        labelStyle: TextStyle(color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.error),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
      dropdownColor: AppColors.surface,
      icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
    );
  }
}

// Path: frontend/lib/features/scan/presentation/pages/create_asset/widgets/submit_button_section.dart
class SubmitButtonSection extends StatelessWidget {
  final VoidCallback onSubmit;

  const SubmitButtonSection({super.key, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.textTertiary.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onSubmit,
          icon: const Icon(Icons.save),
          label: const Text(
            'Create Asset',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
          ),
        ),
      ),
    );
  }
}
