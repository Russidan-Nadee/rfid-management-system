// Path: frontend/lib/features/scan/presentation/widgets/scan_ready_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../l10n/features/scan/scan_localizations.dart';
import '../bloc/scan_bloc.dart';
import '../bloc/scan_event.dart';

class ScanReadyWidget extends StatelessWidget {
  const ScanReadyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = ScanLocalizations.of(context);

    return Center(
      child: Padding(
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // RFID Scanner Icon
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
                Icons.qr_code_scanner,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkText
                    : AppColors.primary,
                size: 60,
              ),
            ),

            AppSpacing.verticalSpaceXXL,

            Text(
              l10n.scannerReady,
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
                l10n.scanInstructions,
                style: AppTextStyles.body2.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkText
                      : AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            AppSpacing.verticalSpaceXXL,

            SizedBox(
              width: 250,
              child: ElevatedButton.icon(
                onPressed: () {
                  print('🔍 ScanReadyWidget: Start Scanning button pressed');
                  context.read<ScanBloc>().add(const StartScan());
                },
                icon: const Icon(Icons.play_arrow, color: AppColors.onPrimary),
                label: Text(
                  l10n.startScanning,
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 32,
                  ),
                  shape: const RoundedRectangleBorder(borderRadius: AppBorders.md),
                  elevation: 3,
                ),
              ),
            ),

            AppSpacing.verticalSpaceLG,

            Container(
              padding: AppSpacing.paddingMD,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkSurfaceVariant.withValues(alpha: 0.3)
                    : AppColors.backgroundSecondary,
                borderRadius: AppBorders.md,
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkBorder.withValues(alpha: 0.3)
                      : AppColors.divider.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    size: 16,
                  ),
                  AppSpacing.horizontalSpaceSM,
                  Text(
                    l10n.ensureScannerConnected,
                    style: AppTextStyles.caption.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
