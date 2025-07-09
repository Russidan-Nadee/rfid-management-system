// Path: frontend/lib/features/scan/presentation/pages/scan_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../di/injection.dart';
import '../bloc/scan_bloc.dart';
import '../bloc/scan_event.dart';
import '../bloc/scan_state.dart';
import '../widgets/scan_list_view.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ScanBloc>().add(const StartScan());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'RFID Scan',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: AppColors.primary,
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
                  icon: Icon(Icons.refresh, color: AppColors.primary),
                  tooltip: 'Scan Again',
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
              'Scanned ${state.scannedItems.length} items',
            );
          } else if (state is AssetStatusUpdateError) {
            Helpers.showError(context, state.message);
          }
        },
        child: BlocBuilder<ScanBloc, ScanState>(
          builder: (context, state) {
            print('ScanPage: Building UI for state ${state.runtimeType}');

            if (state is ScanLoading || state is ScanInitial) {
              print('ScanPage: Showing loading view');
              return _buildLoadingView(context);
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
              return _buildErrorView(context, state.message);
            } else if (state is AssetStatusUpdating) {
              print('ScanPage: Asset updating - showing loading');
              return _buildLoadingView(context);
            }

            print('ScanPage: Unknown state - fallback to loading: $state');
            return _buildLoadingView(context);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingView(BuildContext context) {
    final theme = Theme.of(context);

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
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
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
                        color: AppColors.primary,
                        strokeWidth: 3,
                      ),
                    ),
                    Icon(
                      Icons.qr_code_scanner,
                      color: AppColors.primary,
                      size: 40,
                    ),
                  ],
                ),
              ),
            ),

            AppSpacing.verticalSpaceXXL,

            Text(
              'Scanning RFID Tags...',
              style: AppTextStyles.headline4.copyWith(
                color: theme.brightness == Brightness.dark
                    ? AppColors.onBackground
                    : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),

            AppSpacing.verticalSpaceLG,

            Container(
              padding: AppSpacing.paddingMD,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: AppBorders.md,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary, size: 16),
                  AppSpacing.horizontalSpaceSM,
                  Text(
                    'Please wait while we scan for assets',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.primary,
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

  Widget _buildErrorView(BuildContext context, String message) {
    final theme = Theme.of(context);

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
                color: AppColors.errorLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 60,
              ),
            ),

            AppSpacing.verticalSpaceXXL,

            Text(
              'Scan Failed',
              style: AppTextStyles.headline4.copyWith(
                color: theme.brightness == Brightness.dark
                    ? AppColors.onBackground
                    : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),

            AppSpacing.verticalSpaceLG,

            Container(
              padding: AppSpacing.paddingLG,
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: AppBorders.md,
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                message,
                style: AppTextStyles.body2.copyWith(color: AppColors.error),
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
                  'Try Again',
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
                color: AppColors.backgroundSecondary,
                borderRadius: AppBorders.md,
                border: Border.all(
                  color: AppColors.divider.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.help_outline,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
                  AppSpacing.horizontalSpaceSM,
                  Text(
                    'Make sure RFID scanner is connected',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
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
