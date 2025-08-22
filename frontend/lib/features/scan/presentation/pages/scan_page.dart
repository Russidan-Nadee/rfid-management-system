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
import '../widgets/scan_ready_widget.dart';
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
  // ✅ เก็บ last ScanSuccess state - moved to widget level for global access
  ScanSuccess? _lastScanSuccess;
  bool _hasScannedItems = false; // ✅ Track if we have any scanned items

  @override
  void initState() {
    super.initState();
  }

  // ✅ Method to update scan state - call this from all BlocBuilders
  void _updateScanState(ScanState state) {
    if (state is ScanSuccess) {
      _lastScanSuccess = state;
      _hasScannedItems = state.scannedItems.isNotEmpty;
    }
    // Keep track of scanned items even in other states
    else if (_lastScanSuccess != null) {
      _hasScannedItems = _lastScanSuccess!.scannedItems.isNotEmpty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ScanLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurface.withValues(alpha: 0.5)
          : theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.scanPageTitle,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkText
                : AppColors.primary,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkText
            : AppColors.primary,
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          BlocBuilder<ScanBloc, ScanState>(
            builder: (context, state) {
              // ✅ Update our widget-level state tracking
              _updateScanState(state);

              // ✅ Show refresh button based on whether we have scanned items
              if (_hasScannedItems) {
                return IconButton(
                  onPressed: () {
                    context.read<ScanBloc>().add(const StartScan());
                  },
                  icon: Icon(
                    Icons.refresh,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkText
                        : AppColors.primary,
                  ),
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
            // ✅ Update our widget-level state tracking
            _updateScanState(state);

            if (state is ScanInitial) {
              return const ScanReadyWidget();
            } else if (state is ScanLoading) {
              // Don't clear _lastScanSuccess here - wait for new ScanSuccess
              return _buildLoadingView(context, l10n);
            } else if (state is ScanLocationSelection) {
              return LocationSelectionWidget(
                locations: state.availableLocations,
                onLocationSelected: (selectedLocation) {
                  context.read<ScanBloc>().add(
                    LocationSelected(selectedLocation: selectedLocation),
                  );
                },
              );
            } else if (state is ScanSuccess || state is ScanSuccessFiltered) {
              final scanState = state as ScanSuccess;
              final itemsToShow = scanState.filteredItems;

              return ScanListView(
                scannedItems: itemsToShow,
                onRefresh: () {
                  context.read<ScanBloc>().add(const RefreshScanResults());
                },
              );
            } else if (state is ScanError) {
              return _buildErrorView(context, state.message, l10n);
            } else if (state is AssetStatusUpdating) {
              // ใช้ _lastScanSuccess ที่เก็บไว้ (เฉพาะเมื่อไม่ได้อยู่ในระหว่าง scan ใหม่)
              if (_lastScanSuccess != null) {
                return ScanListView(
                  scannedItems:
                      _lastScanSuccess!.filteredItems, // Use filtered items
                  isLoading: true, // แสดง loading indicator
                  onRefresh: () {
                    context.read<ScanBloc>().add(const RefreshScanResults());
                  },
                );
              }
              return _buildLoadingView(context, l10n);
            }
            // ✅ Handle AssetImages states (ไม่เปลี่ยนหน้า) - ต้องมาก่อน else
            else if (state is AssetImagesLoading ||
                state is AssetImagesLoaded ||
                state is AssetImagesError) {
              // Image states ไม่ควรเปลี่ยน main UI - ใช้ _lastScanSuccess ที่เก็บไว้
              if (_lastScanSuccess != null) {
                return ScanListView(
                  scannedItems:
                      _lastScanSuccess!.filteredItems, // Use filtered items
                  onRefresh: () {
                    context.read<ScanBloc>().add(const RefreshScanResults());
                  },
                );
              }
              return const ScanReadyWidget();
            }
            // ✅ แก้ไข: เพิ่ม state handlers ที่ขาดหาย
            else if (state is AssetStatusUpdated) {
              // State นี้ไม่ควรเกิดขึ้น เพราะ bloc ควร emit ScanSuccess แทน
              // แต่เก็บไว้เป็น fallback
              if (_lastScanSuccess != null) {
                return ScanListView(
                  scannedItems:
                      _lastScanSuccess!.filteredItems, // Use filtered items
                  onRefresh: () {
                    context.read<ScanBloc>().add(const RefreshScanResults());
                  },
                );
              }
              return const ScanReadyWidget();
            }

            // ✅ แก้ไข: ถ้าเคยสแกนแล้วให้แสดง ScanListView เสมอ
            if (_lastScanSuccess != null &&
                _lastScanSuccess!.scannedItems.isNotEmpty) {
              return ScanListView(
                scannedItems:
                    _lastScanSuccess!.filteredItems, // Use filtered items
                onRefresh: () {
                  context.read<ScanBloc>().add(const RefreshScanResults());
                },
              );
            }
            return const ScanReadyWidget();
          },
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
                    ? AppColors.darkText.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkText.withValues(alpha: 0.2)
                      : AppColors.primary.withValues(alpha: 0.2),
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
                            ? AppColors.darkText
                            : AppColors.primary,
                        strokeWidth: 3,
                      ),
                    ),
                    Icon(
                      Icons.qr_code_scanner,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkText
                          : AppColors.primary,
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
                    ? AppColors.darkText
                    : AppColors.textPrimary,
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkText
                        : AppColors.primary,
                    size: 16,
                  ),
                  AppSpacing.horizontalSpaceSM,
                  Text(
                    l10n.pleaseWaitScanning,
                    style: AppTextStyles.body2.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkText
                          : AppColors.primary,
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
                    ? AppColors.error.withValues(alpha: 0.2)
                    : AppColors.errorLight,
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
                    ? AppColors.darkText
                    : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),

            AppSpacing.verticalSpaceLG,

            Container(
              padding: AppSpacing.paddingLG,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.error.withValues(alpha: 0.1)
                    : AppColors.errorLight,
                borderRadius: AppBorders.md,
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                message,
                style: AppTextStyles.body2.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkText
                      : AppColors.error.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ),

            AppSpacing.verticalSpaceXXL,

            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<ScanBloc>().add(const StartScan());
                },
                icon: const Icon(Icons.refresh, color: AppColors.onPrimary),
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
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppBorders.md,
                  ),
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
                    Icons.help_outline,
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
