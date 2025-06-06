// Path: frontend/lib/features/export/presentation/bloc/export_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/export_job_entity.dart';
import '../../domain/entities/export_config_entity.dart';

abstract class ExportState extends Equatable {
  const ExportState();

  @override
  List<Object?> get props => [];
}

// Initial State
class ExportInitial extends ExportState {
  const ExportInitial();

  @override
  String toString() => 'ExportInitial';
}

// Loading States
class ExportLoading extends ExportState {
  final String? message;
  final double? progress;

  const ExportLoading({this.message, this.progress});

  @override
  List<Object?> get props => [message, progress];

  @override
  String toString() => 'ExportLoading(message: $message, progress: $progress)';
}

class ExportCreating extends ExportState {
  final String exportType;
  final ExportConfigEntity config;

  const ExportCreating({required this.exportType, required this.config});

  @override
  List<Object?> get props => [exportType, config];

  @override
  String toString() => 'ExportCreating(type: $exportType)';
}

class ExportDownloading extends ExportState {
  final int exportId;
  final String? fileName;
  final double? progress;

  const ExportDownloading({
    required this.exportId,
    this.fileName,
    this.progress,
  });

  @override
  List<Object?> get props => [exportId, fileName, progress];

  @override
  String toString() => 'ExportDownloading(id: $exportId, progress: $progress)';
}

// Success States
class ExportJobCreated extends ExportState {
  final ExportJobEntity exportJob;
  final String message;

  const ExportJobCreated({required this.exportJob, required this.message});

  @override
  List<Object?> get props => [exportJob, message];

  @override
  String toString() => 'ExportJobCreated(id: ${exportJob.exportId})';
}

class ExportStatusUpdated extends ExportState {
  final ExportJobEntity exportJob;
  final bool isPolling;

  const ExportStatusUpdated({required this.exportJob, this.isPolling = false});

  @override
  List<Object?> get props => [exportJob, isPolling];

  @override
  String toString() =>
      'ExportStatusUpdated(id: ${exportJob.exportId}, status: ${exportJob.status})';
}

class ExportDownloadCompleted extends ExportState {
  final String filePath;
  final String fileName;
  final int fileSize;
  final String message;

  const ExportDownloadCompleted({
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.message,
  });

  @override
  List<Object?> get props => [filePath, fileName, fileSize, message];

  @override
  String toString() => 'ExportDownloadCompleted(fileName: $fileName)';
}

class ExportShared extends ExportState {
  final String filePath;
  final String message;

  const ExportShared({required this.filePath, required this.message});

  @override
  List<Object?> get props => [filePath, message];

  @override
  String toString() => 'ExportShared(filePath: $filePath)';
}

class ExportDeleted extends ExportState {
  final int exportId;
  final String message;

  const ExportDeleted({required this.exportId, required this.message});

  @override
  List<Object?> get props => [exportId, message];

  @override
  String toString() => 'ExportDeleted(id: $exportId)';
}

class ExportCancelled extends ExportState {
  final int exportId;
  final String message;

  const ExportCancelled({required this.exportId, required this.message});

  @override
  List<Object?> get props => [exportId, message];

  @override
  String toString() => 'ExportCancelled(id: $exportId)';
}

// List/History States
class ExportHistoryLoaded extends ExportState {
  final List<ExportJobEntity> exports;
  final ExportHistoryMeta meta;
  final List<int> selectedExportIds;
  final ExportJobEntity? detailedExport;

  const ExportHistoryLoaded({
    required this.exports,
    required this.meta,
    this.selectedExportIds = const [],
    this.detailedExport,
  });

  @override
  List<Object?> get props => [exports, meta, selectedExportIds, detailedExport];

  bool get hasExports => exports.isNotEmpty;
  bool get hasSelections => selectedExportIds.isNotEmpty;
  bool get hasDetails => detailedExport != null;
  bool get canLoadMore => meta.hasNextPage;

  int get selectedCount => selectedExportIds.length;
  List<ExportJobEntity> get selectedExports => exports
      .where((export) => selectedExportIds.contains(export.exportId))
      .toList();

  ExportHistoryLoaded copyWith({
    List<ExportJobEntity>? exports,
    ExportHistoryMeta? meta,
    List<int>? selectedExportIds,
    ExportJobEntity? detailedExport,
  }) {
    return ExportHistoryLoaded(
      exports: exports ?? this.exports,
      meta: meta ?? this.meta,
      selectedExportIds: selectedExportIds ?? this.selectedExportIds,
      detailedExport: detailedExport,
    );
  }

  @override
  String toString() =>
      'ExportHistoryLoaded(count: ${exports.length}, selected: $selectedCount)';
}

// Configuration States
class ExportConfigUpdated extends ExportState {
  final String exportType;
  final ExportConfigEntity config;

  const ExportConfigUpdated({required this.exportType, required this.config});

  @override
  List<Object?> get props => [exportType, config];

  @override
  String toString() =>
      'ExportConfigUpdated(type: $exportType, filters: ${config.hasFilters})';
}

// Statistics States
class ExportStatsLoaded extends ExportState {
  final ExportStatsEntity stats;

  const ExportStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];

  @override
  String toString() => 'ExportStatsLoaded(total: ${stats.totalExports})';
}

// Batch Operation States
class BatchDownloadProgress extends ExportState {
  final int totalItems;
  final int completedItems;
  final List<String> errors;
  final String? currentItem;

  const BatchDownloadProgress({
    required this.totalItems,
    required this.completedItems,
    this.errors = const [],
    this.currentItem,
  });

  @override
  List<Object?> get props => [totalItems, completedItems, errors, currentItem];

  double get progress => totalItems > 0 ? completedItems / totalItems : 0.0;
  bool get isCompleted => completedItems >= totalItems;
  bool get hasErrors => errors.isNotEmpty;

  @override
  String toString() => 'BatchDownloadProgress($completedItems/$totalItems)';
}

class BatchDownloadCompleted extends ExportState {
  final int successCount;
  final int errorCount;
  final List<String> downloadedFiles;
  final List<String> errors;

  const BatchDownloadCompleted({
    required this.successCount,
    required this.errorCount,
    required this.downloadedFiles,
    required this.errors,
  });

  @override
  List<Object?> get props => [
    successCount,
    errorCount,
    downloadedFiles,
    errors,
  ];

  int get totalCount => successCount + errorCount;
  bool get hasAnySuccess => successCount > 0;
  bool get hasAnyErrors => errorCount > 0;

  @override
  String toString() =>
      'BatchDownloadCompleted(success: $successCount, errors: $errorCount)';
}

class MultipleExportsDeleted extends ExportState {
  final int deletedCount;
  final List<String> errors;

  const MultipleExportsDeleted({
    required this.deletedCount,
    this.errors = const [],
  });

  @override
  List<Object?> get props => [deletedCount, errors];

  bool get hasErrors => errors.isNotEmpty;

  @override
  String toString() =>
      'MultipleExportsDeleted(count: $deletedCount, errors: ${errors.length})';
}

// Cleanup States
class CleanupCompleted extends ExportState {
  final int deletedCount;
  final String message;

  const CleanupCompleted({required this.deletedCount, required this.message});

  @override
  List<Object?> get props => [deletedCount, message];

  @override
  String toString() => 'CleanupCompleted(deleted: $deletedCount)';
}

// Error States
class ExportError extends ExportState {
  final String message;
  final ExportErrorType errorType;
  final String? errorCode;
  final dynamic originalError;

  const ExportError({
    required this.message,
    required this.errorType,
    this.errorCode,
    this.originalError,
  });

  @override
  List<Object?> get props => [message, errorType, errorCode];

  bool get isNetworkError => errorType == ExportErrorType.network;
  bool get isAuthError => errorType == ExportErrorType.authentication;
  bool get isValidationError => errorType == ExportErrorType.validation;
  bool get isServerError => errorType == ExportErrorType.server;

  String get userFriendlyMessage {
    switch (errorType) {
      case ExportErrorType.network:
        return 'Please check your internet connection and try again';
      case ExportErrorType.authentication:
        return 'Please login again to continue';
      case ExportErrorType.validation:
        return message;
      case ExportErrorType.server:
        return 'Server error. Please try again later';
      case ExportErrorType.timeout:
        return 'Request timed out. Please try again';
      case ExportErrorType.permission:
        return 'You don\'t have permission to perform this action';
      case ExportErrorType.fileSystem:
        return 'File operation failed. Please check storage permissions';
      default:
        return 'An unexpected error occurred. Please try again';
    }
  }

  @override
  String toString() => 'ExportError(message: $message, type: $errorType)';
}

// Polling States
class ExportPollingStarted extends ExportState {
  final int exportId;
  final Duration interval;

  const ExportPollingStarted({required this.exportId, required this.interval});

  @override
  List<Object?> get props => [exportId, interval];

  @override
  String toString() => 'ExportPollingStarted(id: $exportId)';
}

class ExportPollingStopped extends ExportState {
  final int exportId;
  final String reason;

  const ExportPollingStopped({required this.exportId, required this.reason});

  @override
  List<Object?> get props => [exportId, reason];

  @override
  String toString() => 'ExportPollingStopped(id: $exportId, reason: $reason)';
}

// Helper Data Classes
class ExportHistoryMeta {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPrevPage;

  const ExportHistoryMeta({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  @override
  String toString() =>
      'ExportHistoryMeta(page: $currentPage/$totalPages, total: $totalItems)';
}

class ExportStatsEntity {
  final int totalExports;
  final int pendingExports;
  final int completedExports;
  final int failedExports;
  final int totalFilesSize;
  final DateTime? lastExportDate;

  const ExportStatsEntity({
    required this.totalExports,
    required this.pendingExports,
    required this.completedExports,
    required this.failedExports,
    required this.totalFilesSize,
    this.lastExportDate,
  });

  bool get hasAnyExports => totalExports > 0;
  bool get hasPendingExports => pendingExports > 0;
  double get successRate =>
      totalExports > 0 ? completedExports / totalExports : 0.0;

  @override
  String toString() =>
      'ExportStatsEntity(total: $totalExports, pending: $pendingExports)';
}

enum ExportErrorType {
  network,
  authentication,
  validation,
  server,
  timeout,
  permission,
  fileSystem,
  unknown,
}
