// Path: frontend/lib/features/scan/presentation/widgets/location_selection_widget.dart
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../l10n/features/scan/scan_localizations.dart';

class LocationSelectionWidget extends StatelessWidget {
  final List<String> locations;
  final Function(String) onLocationSelected;

  const LocationSelectionWidget({
    super.key,
    required this.locations,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ScanLocalizations.of(context);

    return Center(
      child: Padding(
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Location Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkText.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkText.withValues(alpha: 0.3)
                      : AppColors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.location_on,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkText
                    : AppColors.primary,
                size: 60,
              ),
            ),

            AppSpacing.verticalSpaceXXL,

            Text(
              l10n.selectCurrentLocation,
              style: AppTextStyles.headline4.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkText
                    : AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),

            AppSpacing.verticalSpaceLG,

            Container(
              padding: AppSpacing.paddingMD,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.primarySurface,
                borderRadius: AppBorders.md,
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkText.withValues(alpha: 0.2)
                      : AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                l10n.chooseLocationToVerify,
                style: AppTextStyles.body2.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkText
                      : AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            AppSpacing.verticalSpaceXXL,

            // Location List
            Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: locations.map((location) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildLocationCard(
                      context,
                      theme,
                      location,
                      onLocationSelected,
                      l10n,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(
    BuildContext context,
    ThemeData theme,
    String location,
    Function(String) onLocationSelected,
    ScanLocalizations l10n,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.brightness == Brightness.dark
          ? AppColors.darkSurface
          : theme.colorScheme.surface,
      child: InkWell(
        onTap: () => onLocationSelected(location),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Location Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.place, color: AppColors.primary, size: 24),
              ),

              const SizedBox(width: 16),

              // Location Name
              Expanded(
                child: Text(
                  location,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.brightness == Brightness.dark
                        ? AppColors.darkText
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),

              // Arrow Icon
              Icon(
                Icons.chevron_right,
                color: theme.brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
