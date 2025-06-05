// Path: frontend/lib/features/scan/presentation/pages/scan_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/helpers.dart';
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
    // Auto scan after widget is built
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
          if (state is ScanError) {
            Helpers.showError(context, state.message);
          } else if (state is ScanSuccess) {
            Helpers.showSuccess(
              context,
              'Scanned ${state.scannedItems.length} items',
            );
          }
        },
        child: BlocBuilder<ScanBloc, ScanState>(
          builder: (context, state) {
            if (state is ScanLoading || state is ScanInitial) {
              return _buildLoadingView(theme);
            } else if (state is ScanSuccess) {
              return ScanListView(
                scannedItems: state.scannedItems,
                onRefresh: () {
                  context.read<ScanBloc>().add(const RefreshScanResults());
                },
              );
            } else if (state is ScanError) {
              return _buildErrorView(context, state.message, theme);
            }

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
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.error_outline, color: Colors.red, size: 60),
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
