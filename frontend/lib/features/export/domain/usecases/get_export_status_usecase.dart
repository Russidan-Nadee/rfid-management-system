// Path: frontend/lib/features/export/domain/usecases/get_export_status_usecase.dart
import 'dart:async';
import '../entities/export_job_entity.dart';
import '../repositories/export_repository.dart';

class GetExportStatusUseCase {
  final ExportRepository repository;

  GetExportStatusUseCase(this.repository);

  /// Get current status of export job
  Future<ExportStatusResult> execute(int exportId) async {
    try {
      final exportJob = await repository.getExportJobStatus(exportId);

      return ExportStatusResult.success(
        exportJob: exportJob,
        message: _getStatusMessage(exportJob),
      );
    } catch (e) {
      return ExportStatusResult.failure(
        'Failed to get export status: ${e.toString()}',
      );
    }
  }

  /// Start polling export status until completion or timeout
  Stream<ExportStatusResult> pollStatus({
    required int exportId,
    Duration interval = const Duration(seconds: 3),
    Duration timeout = const Duration(minutes: 10),
  }) async* {
    final startTime = DateTime.now();

    while (DateTime.now().difference(startTime) < timeout) {
      try {
        final result = await execute(exportId);
        yield result;

        // Stop polling if job is completed, failed, or cancelled
        if (result.success && result.exportJob != null) {
          final job = result.exportJob!;
          if (job.isCompleted || job.isFailed) {
            break;
          }
        }

        // Wait before next poll
        await Future.delayed(interval);
      } catch (e) {
        yield ExportStatusResult.failure('Polling error: ${e.toString()}');
        break;
      }
    }

    // Timeout reached
    yield ExportStatusResult.failure(
      'Export status polling timeout. Please check manually.',
    );
  }

  /// Get multiple export statuses efficiently
  Future<List<ExportStatusResult>> getMultipleStatuses(
    List<int> exportIds,
  ) async {
    final results = <ExportStatusResult>[];

    // Process in batches to avoid overwhelming the server
    const batchSize = 5;
    for (int i = 0; i < exportIds.length; i += batchSize) {
      final batch = exportIds.skip(i).take(batchSize);
      final batchResults = await Future.wait(batch.map((id) => execute(id)));
      results.addAll(batchResults);

      // Small delay between batches
      if (i + batchSize < exportIds.length) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    return results;
  }

  /// Check if export job needs user attention
  Future<ExportAttentionResult> checkAttentionRequired(int exportId) async {
    try {
      final statusResult = await execute(exportId);

      if (!statusResult.success || statusResult.exportJob == null) {
        return ExportAttentionResult.error('Cannot check export status');
      }

      final job = statusResult.exportJob!;

      // Check various attention scenarios
      if (job.isFailed) {
        return ExportAttentionResult.attention(
          type: AttentionType.failed,
          message: 'Export failed: ${job.errorMessage ?? 'Unknown error'}',
          priority: AttentionPriority.high,
        );
      }

      if (job.isCompleted && job.isExpired) {
        return ExportAttentionResult.attention(
          type: AttentionType.expired,
          message: 'Export file has expired and will be deleted soon',
          priority: AttentionPriority.medium,
        );
      }

      if (job.isCompleted && job.timeUntilExpiry.inHours < 24) {
        return ExportAttentionResult.attention(
          type: AttentionType.expiringSoon,
          message: 'Export will expire in ${job.timeUntilExpiry.inHours} hours',
          priority: AttentionPriority.low,
        );
      }

      if (job.isPending) {
        final timeSinceCreated = DateTime.now().difference(job.createdAt);
        if (timeSinceCreated.inMinutes > 15) {
          return ExportAttentionResult.attention(
            type: AttentionType.slowProcessing,
            message: 'Export is taking longer than expected',
            priority: AttentionPriority.low,
          );
        }
      }

      return ExportAttentionResult.noAttention();
    } catch (e) {
      return ExportAttentionResult.error(
        'Failed to check attention status: ${e.toString()}',
      );
    }
  }

  String _getStatusMessage(ExportJobEntity job) {
    switch (job.status.toUpperCase()) {
      case 'P':
        final elapsed = DateTime.now().difference(job.createdAt);
        if (elapsed.inMinutes < 1) {
          return 'Export started, preparing data...';
        } else if (elapsed.inMinutes < 5) {
          return 'Processing... (${elapsed.inMinutes}m elapsed)';
        } else {
          return 'Still processing... This may take a few more minutes';
        }

      case 'C':
        if (job.isExpired) {
          return 'Export completed but file has expired';
        } else if (job.timeUntilExpiry.inDays < 1) {
          return 'Export ready! File expires in ${job.timeUntilExpiry.inHours}h';
        } else {
          return 'Export completed successfully! ${job.totalRecords ?? 0} records exported';
        }

      case 'F':
        return 'Export failed: ${job.errorMessage ?? 'Unknown error occurred'}';

      default:
        return 'Export status: ${job.statusLabel}';
    }
  }
}

class ExportStatusResult {
  final bool success;
  final ExportJobEntity? exportJob;
  final String message;
  final String? errorMessage;

  const ExportStatusResult._({
    required this.success,
    this.exportJob,
    required this.message,
    this.errorMessage,
  });

  factory ExportStatusResult.success({
    required ExportJobEntity exportJob,
    required String message,
  }) {
    return ExportStatusResult._(
      success: true,
      exportJob: exportJob,
      message: message,
    );
  }

  factory ExportStatusResult.failure(String errorMessage) {
    return ExportStatusResult._(
      success: false,
      message: 'Failed to get export status',
      errorMessage: errorMessage,
    );
  }

  bool get hasExportJob => exportJob != null;
  bool get isCompleted => exportJob?.isCompleted ?? false;
  bool get canDownload => exportJob?.canDownload ?? false;

  @override
  String toString() {
    return 'ExportStatusResult(success: $success, status: ${exportJob?.status})';
  }
}

class ExportAttentionResult {
  final bool needsAttention;
  final AttentionType? type;
  final String? message;
  final AttentionPriority? priority;
  final bool isError;
  final String? errorMessage;

  const ExportAttentionResult._({
    required this.needsAttention,
    this.type,
    this.message,
    this.priority,
    this.isError = false,
    this.errorMessage,
  });

  factory ExportAttentionResult.attention({
    required AttentionType type,
    required String message,
    required AttentionPriority priority,
  }) {
    return ExportAttentionResult._(
      needsAttention: true,
      type: type,
      message: message,
      priority: priority,
    );
  }

  factory ExportAttentionResult.noAttention() {
    return const ExportAttentionResult._(needsAttention: false);
  }

  factory ExportAttentionResult.error(String errorMessage) {
    return ExportAttentionResult._(
      needsAttention: false,
      isError: true,
      errorMessage: errorMessage,
    );
  }

  bool get isHighPriority => priority == AttentionPriority.high;
  bool get isMediumPriority => priority == AttentionPriority.medium;
  bool get isLowPriority => priority == AttentionPriority.low;

  @override
  String toString() {
    return 'ExportAttentionResult(needsAttention: $needsAttention, type: $type)';
  }
}

enum AttentionType { failed, expired, expiringSoon, slowProcessing }

enum AttentionPriority { low, medium, high }
