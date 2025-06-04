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

class ScanPageView extends StatelessWidget {
  const ScanPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RFID Scan'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        elevation: 1,
        actions: [
          BlocBuilder<ScanBloc, ScanState>(
            builder: (context, state) {
              if (state is ScanSuccess && state.scannedItems.isNotEmpty) {
                return IconButton(
                  onPressed: () {
                    context.read<ScanBloc>().add(const ClearScanResults());
                  },
                  icon: const Icon(Icons.clear_all),
                  tooltip: 'Clear Results',
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
          } else if (state is ScanSuccess) {
            Helpers.showSuccess(
              context,
              'Scanned ${state.scannedItems.length} items',
            );
          }
        },
        child: BlocBuilder<ScanBloc, ScanState>(
          builder: (context, state) {
            if (state is ScanInitial) {
              return _buildInitialView(context);
            } else if (state is ScanLoading) {
              return _buildLoadingView();
            } else if (state is ScanSuccess) {
              return ScanListView(
                scannedItems: state.scannedItems,
                onRefresh: () {
                  context.read<ScanBloc>().add(const RefreshScanResults());
                },
              );
            } else if (state is ScanError) {
              return _buildErrorView(context, state.message);
            }

            return _buildInitialView(context);
          },
        ),
      ),
      floatingActionButton: BlocBuilder<ScanBloc, ScanState>(
        builder: (context, state) {
          final isLoading = state is ScanLoading;

          return FloatingActionButton.extended(
            onPressed: isLoading
                ? null
                : () {
                    context.read<ScanBloc>().add(const StartScan());
                  },
            backgroundColor: const Color(0xFF4F46E5),
            foregroundColor: Colors.white,
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.qr_code_scanner),
            label: Text(isLoading ? 'Scanning...' : 'Start Scan'),
          );
        },
      ),
    );
  }

  Widget _buildInitialView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Scan Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.qr_code_scanner,
              color: Color(0xFF4F46E5),
              size: 60,
            ),
          ),

          const SizedBox(height: 32),

          // Title
          const Text(
            'RFID Scanner Ready',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            'Tap the scan button to start scanning\nRFID tags in the area',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 48),

          // Instructions
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '1. Ensure RFID reader is connected\n'
                  '2. Position tags within scanning range\n'
                  '3. Tap scan button to begin\n'
                  '4. Review scanned items',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated scanning icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: Color(0xFF4F46E5),
              strokeWidth: 3,
            ),
          ),

          const SizedBox(height: 32),

          const Text(
            'Scanning RFID Tags...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Please wait while we scan for assets',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
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

          const Text(
            'Scan Failed',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          ElevatedButton.icon(
            onPressed: () {
              context.read<ScanBloc>().add(const StartScan());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
