// Path: frontend/lib/features/scan/presentation/widgets/create/basic_info_section.dart
import 'package:flutter/material.dart';
import '../../../../../../app/theme/app_colors.dart';

class BasicInfoSection extends StatelessWidget {
  final String epcCode; // ← เปลี่ยนเป็น EPC Code (read-only)
  final TextEditingController
  assetNoController; // ← เพิ่ม Asset Number controller
  final TextEditingController descriptionController;
  final String? Function(String?)?
  assetNoValidator; // ← เพิ่ม validator สำหรับ Asset Number
  final String? Function(String?)? descriptionValidator;

  const BasicInfoSection({
    super.key,
    required this.epcCode, // ← EPC Code จากการสแกน
    required this.assetNoController, // ← Asset Number ให้ user กรอก
    required this.descriptionController,
    this.assetNoValidator,
    this.descriptionValidator,
  });

  @override
  Widget build(BuildContext context) {
    return _buildSectionCard(
      title: 'Basic Information',
      icon: Icons.inventory_2_outlined,
      color: AppColors.primary,
      children: [
        // EPC Code (Read-only)
        _buildReadOnlyField(
          label: 'EPC Code',
          value: epcCode,
          icon: Icons.qr_code,
        ),
        const SizedBox(height: 16),

        // Asset Number (Input field)
        _buildTextFormField(
          controller: assetNoController,
          label: 'Asset Number',
          icon: Icons.tag,
          isRequired: true,
          validator: assetNoValidator,
          hint: 'Enter asset number (e.g., A001234)',
        ),
        const SizedBox(height: 16),

        // Description
        _buildTextFormField(
          controller: descriptionController,
          label: 'Description',
          icon: Icons.description,
          isRequired: true,
          validator: descriptionValidator,
          hint: 'Enter asset description',
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

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.onBackground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
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
}
