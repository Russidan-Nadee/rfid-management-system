// Path: frontend/lib/features/scan/presentation/pages/scan_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../di/injection.dart';
import '../../../../l10n/features/scan/scan_localizations.dart';
import '../bloc/scan_bloc.dart';
import '../bloc/scan_event.dart';
import '../bloc/scan_state.dart';
import '../widgets/scan_list_view.dart';
import '../widgets/location_selection_widget.dart';

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ScanBloc>(),
      child: const ScanPageView(),
    );
  }
}

class ScanPageView extends StatefulWidget {
  const ScanPageView({super.key});

  @override
  State<ScanPageView> createState() => _ScanPageViewState();
}

class _ScanPageViewState extends State<ScanPageView> {
  @override
  void initState() {
    super.initState();
    print('ScanPage: initState called');
    // ลบ auto scan ออก - ไม่มี auto scan แล้ว
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ScanLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurface.withValues(
              alpha: 0.5,
            ) // Dark Mode: เหมือน settings
          : theme.colorScheme.background, // Light Mode: เดิม
      appBar: AppBar(
        title: Text(
          l10n.scanPageTitle,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors
                      .darkText // Dark Mode: สีขาว
                : AppColors.primary, // Light Mode: สีน้ำเงิน
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors
                  .darkText // Dark Mode: สีขาว
            : AppColors.primary, // Light Mode: สีน้ำเงิน
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          BlocBuilder<ScanBloc, ScanState>(
            builder: (context, state) {
              if (state is ScanSuccess && state.scannedItems.isNotEmpty) {
                return IconButton(
                  onPressed: () {
                    print('ScanPage: Refresh button pressed');
                    context.read<ScanBloc>().add(const StartScan());
                  },
                  icon: Icon(
                    Icons.refresh,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors
                              .darkText // Dark Mode: สีขาว
                        : AppColors.primary,
                  ), // Light Mode: สีน้ำเงิน
                  tooltip: l10n.scanAgain,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocListener<ScanBloc, ScanState>(
        listener: (context, state) {
          if (state is ScanError) {
            Helpers.showError(context, state.message);
          } else if (state is ScanSuccess && state is! ScanSuccessFiltered) {
            print(
              'ScanPage: Scan success - ${state.scannedItems.length} items',
            );
            Helpers.showSuccess(
              context,
              l10n.scannedItemsCount(state.scannedItems.length),
            );
          } else if (state is AssetStatusUpdateError) {
            Helpers.showError(context, state.message);
          }
        },
        child: BlocBuilder<ScanBloc, ScanState>(
          builder: (context, state) {
            print('ScanPage: Building UI for state ${state.runtimeType}');

            if (state is ScanInitial) {
              print('ScanPage: Showing ready state');
              return _buildReadyState(context, l10n);
            } else if (state is ScanLoading) {
              print('ScanPage: Showing loading view');
              return _buildLoadingView(context, l10n);
            } else if (state is ScanLocationSelection) {
              print('ScanPage: Showing location selection view');
              return _buildLocationSelectionView(context, state, l10n);
            } else if (state is ScanSuccess) {
              print(
                'ScanPage: Showing scan results, items count = ${state.scannedItems.length}',
              );

              return ScanListView(
                scannedItems: state.scannedItems,
                onRefresh: () {
                  print('ScanPage: Pull to refresh triggered');
                  context.read<ScanBloc>().add(const RefreshScanResults());
                },
              );
            } else if (state is ScanError) {
              print('ScanPage: Showing error view: ${state.message}');
              return _buildErrorView(context, state.message, l10n);
            } else if (state is AssetStatusUpdating) {
              print('ScanPage: Asset updating - showing loading');
              return _buildLoadingView(context, l10n);
            }

            print('ScanPage: Unknown state - fallback to ready: $state');
            return _buildReadyState(context, l10n);
          },
        ),
      ),
    );
  }

  // เพิ่ม method ใหม่สำหรับแสดง location selection
  Widget _buildLocationSelectionView(
    BuildContext context,
    ScanLocationSelection state,
    ScanLocalizations l10n,
  ) {
    return LocationSelectionWidget(
      locations: state.availableLocations,
      onLocationSelected: (selectedLocation) {
        print('ScanPage: Location selected: $selectedLocation');
        context.read<ScanBloc>().add(
          LocationSelected(selectedLocation: selectedLocation),
        );
      },
    );
  }

  Widget _buildReadyState(BuildContext context, ScanLocalizations l10n) {
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
                    ? AppColors.darkText.withValues(
                        alpha: 0.1,
                      ) // Dark Mode: พื้นหลังขาวโปร่งใส
                    : AppColors.primary.withValues(
                        alpha: 0.1,
                      ), // Light Mode: พื้นหลังน้ำเงินโปร่งใส
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkText.withValues(
                          alpha: 0.3,
                        ) // Dark Mode: ขอบขาวโปร่งใส
                      : AppColors.primary.withValues(
                          alpha: 0.3,
                        ), // Light Mode: ขอบน้ำเงินโปร่งใส
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.qr_code_scanner,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors
                          .darkText // Dark Mode: สีขาว
                    : AppColors.primary, // Light Mode: สีน้ำเงิน
                size: 60,
              ),
            ),

            AppSpacing.verticalSpaceXXL,

            Text(
              l10n.scannerReady,
              style: AppTextStyles.headline4.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors
                          .darkText // Dark Mode: สีขาว
                    : AppColors.primary, // Light Mode: สีน้ำเงิน
                fontWeight: FontWeight.bold,
              ),
            ),

            AppSpacing.verticalSpaceLG,

            Container(
              padding: AppSpacing.paddingMD,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.primary.withValues(
                        alpha: 0.1,
                      ) // Dark Mode: พื้นหลังโปร่งใส
                    : AppColors.primarySurface, // Light Mode: พื้นหลังอ่อน
                borderRadius: AppBorders.md,
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkText.withValues(
                          alpha: 0.2,
                        ) // Dark Mode: ขอบขาวโปร่งใส
                      : AppColors.primary.withValues(
                          alpha: 0.2,
                        ), // Light Mode: ขอบน้ำเงินโปร่งใส
                ),
              ),
              child: Text(
                l10n.scanInstructions,
                style: AppTextStyles.body2.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors
                            .darkText // Dark Mode: สีขาว
                      : AppColors.primary, // Light Mode: สีน้ำเงิน
                ),
                textAlign: TextAlign.center,
              ),
            ),

            AppSpacing.verticalSpaceXXL,

            SizedBox(
              width: 250,
              child: ElevatedButton.icon(
                onPressed: () {
                  print('ScanPage: Start Scanning button pressed');
                  context.read<ScanBloc>().add(const StartScan());
                },
                icon: Icon(Icons.play_arrow, color: AppColors.onPrimary),
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
                  shape: RoundedRectangleBorder(borderRadius: AppBorders.md),
                  elevation: 3,
                ),
              ),
            ),

            AppSpacing.verticalSpaceLG,

            Container(
              padding: AppSpacing.paddingMD,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkSurfaceVariant.withValues(
                        alpha: 0.3,
                      ) // Dark Mode: พื้นหลังเทาเข้ม
                    : AppColors
                          .backgroundSecondary, // Light Mode: พื้นหลังเทาอ่อน
                borderRadius: AppBorders.md,
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkBorder.withValues(
                          alpha: 0.3,
                        ) // Dark Mode: ขอบเทา
                      : AppColors.divider.withValues(
                          alpha: 0.5,
                        ), // Light Mode: ขอบเทาอ่อน
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors
                              .darkTextSecondary // Dark Mode: สีเทาอ่อน
                        : AppColors.textSecondary, // Light Mode: สีเทา
                    size: 16,
                  ),
                  AppSpacing.horizontalSpaceSM,
                  Text(
                    l10n.ensureScannerConnected,
                    style: AppTextStyles.caption.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors
                                .darkTextSecondary // Dark Mode: สีเทาอ่อน
                          : AppColors.textSecondary, // Light Mode: สีเทา
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

  Widget _buildLoadingView(BuildContext context, ScanLocalizations l10n) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated scanning icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkText.withValues(
                        alpha: 0.1,
                      ) // Dark Mode: พื้นหลังขาวโปร่งใส
                    : AppColors.primary.withValues(
                        alpha: 0.1,
                      ), // Light Mode: พื้นหลังน้ำเงินโปร่งใส
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkText.withValues(
                          alpha: 0.2,
                        ) // Dark Mode: ขอบขาวโปร่งใส
                      : AppColors.primary.withValues(
                          alpha: 0.2,
                        ), // Light Mode: ขอบน้ำเงินโปร่งใส
                  width: 2,
                ),
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors
                                  .darkText // Dark Mode: สีขาว
                            : AppColors.primary, // Light Mode: สีน้ำเงิน
                        strokeWidth: 3,
                      ),
                    ),
                    Icon(
                      Icons.qr_code_scanner,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors
                                .darkText // Dark Mode: สีขาว
                          : AppColors.primary, // Light Mode: สีน้ำเงิน
                      size: 40,
                    ),
                  ],
                ),
              ),
            ),

            AppSpacing.verticalSpaceXXL,

            Text(
              l10n.scanningTags,
              style: AppTextStyles.headline4.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors
                          .darkText // Dark Mode: สีขาว
                    : AppColors.textPrimary, // Light Mode: สีเข้ม
                fontWeight: FontWeight.bold,
              ),
            ),

            AppSpacing.verticalSpaceLG,

            Container(
              padding: AppSpacing.paddingMD,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.primary.withValues(
                        alpha: 0.1,
                      ) // Dark Mode: พื้นหลังโปร่งใส
                    : AppColors.primarySurface, // Light Mode: พื้นหลังอ่อน
                borderRadius: AppBorders.md,
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkText.withValues(
                          alpha: 0.2,
                        ) // Dark Mode: ขอบขาวโปร่งใส
                      : AppColors.primary.withValues(
                          alpha: 0.2,
                        ), // Light Mode: ขอบน้ำเงินโปร่งใส
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors
                              .darkText // Dark Mode: สีขาว
                        : AppColors.primary, // Light Mode: สีน้ำเงิน
                    size: 16,
                  ),
                  AppSpacing.horizontalSpaceSM,
                  Text(
                    l10n.pleaseWaitScanning,
                    style: AppTextStyles.body2.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors
                                .darkText // Dark Mode: สีขาว
                          : AppColors.primary, // Light Mode: สีน้ำเงิน
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

  Widget _buildErrorView(
    BuildContext context,
    String message,
    ScanLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              padding: AppSpacing.paddingXXL,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.error.withValues(
                        alpha: 0.2,
                      ) // Dark Mode: พื้นหลังแดงโปร่งใส
                    : AppColors.errorLight, // Light Mode: พื้นหลังแดงอ่อน
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.error_outline,
                color: AppColors.error.withValues(alpha: 0.8),
                size: 60,
              ),
            ),

            AppSpacing.verticalSpaceXXL,

            Text(
              l10n.scanFailed,
              style: AppTextStyles.headline4.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors
                          .darkText // Dark Mode: สีขาว
                    : AppColors.textPrimary, // Light Mode: สีเข้ม
                fontWeight: FontWeight.bold,
              ),
            ),

            AppSpacing.verticalSpaceLG,

            Container(
              padding: AppSpacing.paddingLG,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.error.withValues(
                        alpha: 0.1,
                      ) // Dark Mode: พื้นหลังแดงโปร่งใส
                    : AppColors.errorLight, // Light Mode: พื้นหลังแดงอ่อน
                borderRadius: AppBorders.md,
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                message,
                style: AppTextStyles.body2.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors
                            .darkText // Dark Mode: สีขาว
                      : AppColors.error.withValues(alpha: 0.8),
                ), // Light Mode: สีแดง
                textAlign: TextAlign.center,
              ),
            ),

            AppSpacing.verticalSpaceXXL,

            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: () {
                  print('ScanPage: Try Again button pressed');
                  context.read<ScanBloc>().add(const StartScan());
                },
                icon: Icon(Icons.refresh, color: AppColors.onPrimary),
                label: Text(
                  l10n.tryAgain,
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: AppSpacing.buttonPaddingSymmetric,
                  shape: RoundedRectangleBorder(borderRadius: AppBorders.md),
                ),
              ),
            ),

            AppSpacing.verticalSpaceLG,

            Container(
              padding: AppSpacing.paddingMD,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkSurfaceVariant.withValues(
                        alpha: 0.3,
                      ) // Dark Mode: พื้นหลังเทาเข้ม
                    : AppColors
                          .backgroundSecondary, // Light Mode: พื้นหลังเทาอ่อน
                borderRadius: AppBorders.md,
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkBorder.withValues(
                          alpha: 0.3,
                        ) // Dark Mode: ขอบเทา
                      : AppColors.divider.withValues(
                          alpha: 0.5,
                        ), // Light Mode: ขอบเทาอ่อน
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.help_outline,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors
                              .darkTextSecondary // Dark Mode: สีเทาอ่อน
                        : AppColors.textSecondary, // Light Mode: สีเทา
                    size: 16,
                  ),
                  AppSpacing.horizontalSpaceSM,
                  Text(
                    l10n.ensureScannerConnected,
                    style: AppTextStyles.caption.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors
                                .darkTextSecondary // Dark Mode: สีเทาอ่อน
                          : AppColors.textSecondary, // Light Mode: สีเทา
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
