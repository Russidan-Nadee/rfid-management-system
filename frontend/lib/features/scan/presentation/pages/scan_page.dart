// Path: frontend/lib/features/scan/presentation/pages/scan_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../app/theme/app_colors.dart';
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
    // Auto scan after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // print('ScanPage: Starting scan...');
        context.read<ScanBloc>().add(const StartScan());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'RFID Scan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.primary,
        elevation: 1,
        actions: [
          BlocBuilder<ScanBloc, ScanState>(
            builder: (context, state) {
              if (state is ScanSuccess && state.scannedItems.isNotEmpty) {
                return IconButton(
                  onPressed: () {
                    print('ScanPage: Refresh button pressed');
                    context.read<ScanBloc>().add(const StartScan());
                  },
                  icon: Icon(Icons.refresh, color: theme.colorScheme.primary),
                  tooltip: 'Scan Again',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      backgroundColor: theme.colorScheme.background,
      body: BlocListener<ScanBloc, ScanState>(
        listener: (context, state) {
          // print('ScanPage: State changed to ${state.runtimeType}');

          if (state is ScanError) {
            // print('ScanPage: Error occurred - ${state.message}');
            Helpers.showError(context, state.message);
          } else if (state is ScanSuccess && state is! ScanSuccessFiltered) {
            // แสดง success message เฉพาะเมื่อ scan จริงๆ (ไม่ใช่ filter)
            print(
              'ScanPage: Scan success - ${state.scannedItems.length} items',
            );
            Helpers.showSuccess(
              context,
              'Scanned ${state.scannedItems.length} items',
            );
          } else if (state is AssetStatusUpdateError) {
            // แสดง error message สำหรับ status update
            Helpers.showError(context, state.message);
          }
        },
        child: BlocBuilder<ScanBloc, ScanState>(
          builder: (context, state) {
            print('ScanPage: Building UI for state ${state.runtimeType}');

            if (state is ScanLoading || state is ScanInitial) {
              print('ScanPage: Showing loading view');
              return _buildLoadingView(theme);
            } else if (state is ScanSuccess) {
              print(
                'ScanPage: Showing scan results, items count = ${state.scannedItems.length}',
              );
              print(
                'ScanPage: Items status: ${state.scannedItems.map((e) => '${e.assetNo}:${e.status}').join(', ')}',
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
              return _buildErrorView(context, state.message, theme);
            } else if (state is AssetStatusUpdating) {
              print('ScanPage: Asset updating - showing loading');
              return _buildLoadingView(theme);
            }

            print('ScanPage: Unknown state - fallback to loading: $state');
            return _buildLoadingView(theme);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingView(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated scanning icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              color: theme.colorScheme.primary,
              strokeWidth: 3,
            ),
          ),

          const SizedBox(height: 32),

          Text(
            'Scanning RFID Tags...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onBackground,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Please wait while we scan for assets',
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(
    BuildContext context,
    String message,
    ThemeData theme,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline, color: AppColors.error, size: 60),
          ),

          const SizedBox(height: 32),

          Text(
            'Scan Failed',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 32),

          ElevatedButton.icon(
            onPressed: () {
              print('ScanPage: Try Again button pressed');
              context.read<ScanBloc>().add(const StartScan());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
