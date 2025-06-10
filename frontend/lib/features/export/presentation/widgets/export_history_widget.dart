// Path: frontend/lib/features/export/presentation/widgets/export_history_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/export_job_entity.dart';
import '../bloc/export_bloc.dart';
import '../bloc/export_event.dart';
import '../bloc/export_state.dart';
import 'export_item_card.dart';

class ExportHistoryWidget extends StatelessWidget {
  const ExportHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExportBloc, ExportState>(
      listener: (context, state) {
        if (state is ExportHistoryDownloadSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File shared: ${state.fileName}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is ExportError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: BlocBuilder<ExportBloc, ExportState>(
        builder: (context, state) {
          if (state is ExportLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ExportHistoryLoaded) {
            return _buildHistoryList(context, state.exports);
          } else if (state is ExportHistoryDownloadSuccess) {
            // เพิ่มบรรทัดนี้: แสดง export list หลัง download สำเร็จ
            return _buildHistoryList(context, state.exports);
          } else if (state is ExportError) {
            return _buildErrorState(context, state.message);
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    List<ExportJobEntity> exports,
  ) {
    if (exports.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ExportBloc>().add(const LoadExportHistory());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: exports.length,
        itemBuilder: (context, index) {
          return ExportItemCard(
            export: exports[index],
            onTap: () {
              // ใช้ event ใหม่สำหรับ History
              context.read<ExportBloc>().add(
                DownloadHistoryExport(exports[index].exportId),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No export history',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first export to see it here',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading history',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<ExportBloc>().add(const LoadExportHistory());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
