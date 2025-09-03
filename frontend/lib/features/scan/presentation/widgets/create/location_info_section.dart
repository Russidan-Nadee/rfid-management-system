// Path: frontend/lib/features/scan/presentation/widgets/create/location_info_section.dart
import 'package:flutter/material.dart';
import 'package:tp_rfid/features/scan/domain/entities/master_data_entity.dart';
import '../../../../../../app/theme/app_colors.dart';
import '../../../../../../l10n/features/scan/scan_localizations.dart';

class LocationInfoSection extends StatelessWidget {
  final String? selectedPlant;
  final String? selectedLocation;
  final String? selectedDepartment;
  final List<PlantEntity> plants;
  final List<LocationEntity> locations;
  final List<DepartmentEntity> departments;
  final ValueChanged<String?> onPlantChanged;
  final ValueChanged<String?> onLocationChanged;
  final ValueChanged<String?> onDepartmentChanged;
  final String? Function(String?)? plantValidator;
  final String? Function(String?)? locationValidator;

  const LocationInfoSection({
    super.key,
    this.selectedPlant,
    this.selectedLocation,
    this.selectedDepartment,
    required this.plants,
    required this.locations,
    required this.departments,
    required this.onPlantChanged,
    required this.onLocationChanged,
    required this.onDepartmentChanged,
    this.plantValidator,
    this.locationValidator,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = ScanLocalizations.of(context);

    return _buildSectionCard(
      context: context,
      title: l10n.locationInformation,
      icon: Icons.location_on,
      color: AppColors.primary,
      children: [
        // Plant Dropdown
        _buildDropdownField<String>(
          context: context,
          value: selectedPlant,
          label: l10n.plant,
          icon: Icons.business,
          isRequired: true,
          items: plants
              .map(
                (plant) => DropdownMenuItem(
                  value: plant.plantCode,
                  child: Text(plant.toString()),
                ),
              )
              .toList(),
          onChanged: onPlantChanged,
          validator: plantValidator,
        ),

        const SizedBox(height: 16),

        // Location Dropdown (เปลี่ยนจาก read-only เป็น dropdown)
        _buildDropdownField<String>(
          context: context,
          value: selectedLocation,
          label: l10n.location,
          icon: Icons.place,
          isRequired: true,
          items: locations
              .map(
                (location) => DropdownMenuItem(
                  value: location.locationCode,
                  child: Text(location.toString()),
                ),
              )
              .toList(),
          onChanged: onLocationChanged,
          validator: locationValidator,
        ),

        const SizedBox(height: 16),

        // Department Dropdown
        _buildDropdownField<String>(
          context: context,
          value: selectedDepartment,
          label: l10n.department,
          icon: Icons.corporate_fare,
          isRequired: false,
          items: departments
              .map(
                (department) => DropdownMenuItem(
                  value: department.deptCode,
                  child: Text(department.toString()),
                ),
              )
              .toList(),
          onChanged: onDepartmentChanged,
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
