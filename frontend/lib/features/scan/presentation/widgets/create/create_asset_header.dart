// Path: frontend/lib/features/scan/presentation/widgets/create/create_asset_header.dart
import 'package:flutter/material.dart';
import '../../../../../../app/theme/app_colors.dart';

class CreateAssetHeader extends StatelessWidget {
  final String epcCode;
  const CreateAssetHeader({super.key, required this.epcCode});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.add_circle, color: AppColors.onPrimary, size: 48),
          const SizedBox(height: 12),
          Text(
            'Creating Unknown Asset',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.onPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.onPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              epcCode,
              style: TextStyle(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
