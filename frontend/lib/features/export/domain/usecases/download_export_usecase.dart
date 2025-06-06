// Path: frontend/lib/features/export/domain/usecases/download_export_usecase.dart
import 'dart:io';
import 'package:path/path.dart' as path;
import '../entities/export_job_entity.dart';
import '../repositories/export_repository.dart';

class DownloadExportUseCase {
  final ExportRepository repository;

  DownloadExportUseCase(this.repository);

  /// Download export file to device storage
  Future<DownloadResult> execute({
    required int exportId,
    String? customFileName,
    String? customDirectory,
  }) async {
    try {
      // First check if export is ready for download
      final exportJob = await repository.getExportJobStatus(exportId);

      final validation = _validateDownload(exportJob);
      if (!validation.isValid) {
        return DownloadResult.failure(validation.errorMessage!);
      }

      // Download file to temporary location first
      final tempFilePath = await repository.downloadExportFile(exportId);

      // Process and move to final location
      final finalPath = await _processFinalFile(
        exportJob: exportJob,
        tempFilePath: tempFilePath,
        customFileName: customFileName,
        customDirectory: customDirectory,
      );

      return DownloadResult.success(
        filePath: finalPath,
        fileName: path.basename(finalPath),
        fileSize: await _getFileSize(finalPath),
        message: 'Export downloaded successfully',
      );
    } catch (e) {
      return DownloadResult.failure(
        'Failed to download export: ${e.toString()}',
      );
    }
  }

  /// Download with progress tracking
  Stream<DownloadProgress> downloadWithProgress({
    required int exportId,
    String? customFileName,
    String? customDirectory,
  }) async* {
    try {
      yield DownloadProgress.started();

      // Validate export
      yield DownloadProgress.validating();
      final exportJob = await repository.getExportJobStatus(exportId);

      final validation = _validateDownload(exportJob);
      if (!validation.isValid) {
        yield DownloadProgress.failed(validation.errorMessage!);
        return;
      }

      yield DownloadProgress.downloading();

      // Simulate download progress (in real implementation, this would come from HTTP client)
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        yield DownloadProgress.downloading(progress: i / 100);
      }

      // Download file
      final tempFilePath = await repository.downloadExportFile(exportId);

      yield DownloadProgress.processing();

      // Process final file
      final finalPath = await _processFinalFile(
        exportJob: exportJob,
        tempFilePath: tempFilePath,
        customFileName: customFileName,
        customDirectory: customDirectory,
      );

      yield DownloadProgress.completed(
        filePath: finalPath,
        fileName: path.basename(finalPath),
        fileSize: await _getFileSize(finalPath),
      );
    } catch (e) {
      yield DownloadProgress.failed('Download failed: ${e.toString()}');
    }
  }

  /// Download multiple exports in batch
  Future<BatchDownloadResult> downloadMultiple({
    required List<int> exportIds,
    String? baseDirectory,
  }) async {
    final results = <DownloadResult>[];
    final errors = <String>[];
    int successCount = 0;

    for (final exportId in exportIds) {
      try {
        final result = await execute(
          exportId: exportId,
          customDirectory: baseDirectory,
        );

        results.add(result);

        if (result.success) {
          successCount++;
        } else {
          errors.add('Export $exportId: ${result.errorMessage}');
        }

        // Small delay between downloads
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        final errorResult = DownloadResult.failure(
          'Export $exportId failed: ${e.toString()}',
        );
        results.add(errorResult);
        errors.add('Export $exportId: ${e.toString()}');
      }
    }

    return BatchDownloadResult(
      results: results,
      successCount: successCount,
      errorCount: errors.length,
      errors: errors,
    );
  }

  /// Share export file using system share dialog
  Future<ShareResult> shareExport(int exportId) async {
    try {
      final downloadResult = await execute(exportId: exportId);

      if (!downloadResult.success) {
        return ShareResult.failure(
          downloadResult.errorMessage ?? 'Download failed',
        );
      }

      // In real implementation, this would use share_plus package
      // await Share.shareXFiles([XFile(downloadResult.filePath!)]);

      return ShareResult.success(
        'Export shared successfully',
        downloadResult.filePath!,
      );
    } catch (e) {
      return ShareResult.failure('Failed to share export: ${e.toString()}');
    }
  }

  ValidationResult _validateDownload(ExportJobEntity exportJob) {
    if (!exportJob.isCompleted) {
      return ValidationResult.invalid(
        'Export is not completed yet. Current status: ${exportJob.statusLabel}',
      );
    }

    if (exportJob.isExpired) {
      return ValidationResult.invalid(
        'Export file has expired and is no longer available for download',
      );
    }

    if (!exportJob.canDownload) {
      return ValidationResult.invalid(
        'Export file is not available for download',
      );
    }

    return ValidationResult.valid();
  }

  Future<String> _processFinalFile({
    required ExportJobEntity exportJob,
    required String tempFilePath,
    String? customFileName,
    String? customDirectory,
  }) async {
    // Determine final file name
    final fileName = customFileName ?? _generateFileName(exportJob);

    // Determine final directory
    final directory = customDirectory ?? await _getDefaultDownloadDirectory();

    // Ensure directory exists
    final dir = Directory(directory);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // Create final file path
    final finalPath = path.join(directory, fileName);

    // Move file from temp to final location
    final tempFile = File(tempFilePath);
    await tempFile.copy(finalPath);
    await tempFile.delete(); // Clean up temp file

    return finalPath;
  }

  String _generateFileName(ExportJobEntity exportJob) {
    final timestamp = exportJob.createdAt
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('T', '_')
        .split('.')[0];

    final format = exportJob.downloadUrl?.contains('.xlsx') == true
        ? 'xlsx'
        : 'csv';

    return '${exportJob.exportType}_export_${timestamp}.$format';
  }

  Future<String> _getDefaultDownloadDirectory() async {
    // In real implementation, this would use path_provider
    // final directory = await getApplicationDocumentsDirectory();
    // return path.join(directory.path, 'exports');

    return '/storage/emulated/0/Download/AssetManagement';
  }

  Future<int> _getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      final stat = await file.stat();
      return stat.size;
    } catch (e) {
      return 0;
    }
  }
}

class DownloadResult {
  final bool success;
  final String? filePath;
  final String? fileName;
  final int? fileSize;
  final String message;
  final String? errorMessage;

  const DownloadResult._({
    required this.success,
    this.filePath,
    this.fileName,
    this.fileSize,
    required this.message,
    this.errorMessage,
  });

  factory DownloadResult.success({
    required String filePath,
    required String fileName,
    required int fileSize,
    required String message,
  }) {
    return DownloadResult._(
      success: true,
      filePath: filePath,
      fileName: fileName,
      fileSize: fileSize,
      message: message,
    );
  }

  factory DownloadResult.failure(String errorMessage) {
    return DownloadResult._(
      success: false,
      message: 'Download failed',
      errorMessage: errorMessage,
    );
  }

  String get fileSizeFormatted {
    if (fileSize == null) return '-';

    if (fileSize! < 1024) return '${fileSize}B';
    if (fileSize! < 1024 * 1024)
      return '${(fileSize! / 1024).toStringAsFixed(1)}KB';
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  @override
  String toString() {
    return 'DownloadResult(success: $success, fileName: $fileName)';
  }
}

class DownloadProgress {
  final DownloadState state;
  final double? progress;
  final String? message;
  final String? filePath;
  final String? fileName;
  final int? fileSize;

  const DownloadProgress._({
    required this.state,
    this.progress,
    this.message,
    this.filePath,
    this.fileName,
    this.fileSize,
  });

  factory DownloadProgress.started() {
    return const DownloadProgress._(
      state: DownloadState.started,
      message: 'Starting download...',
    );
  }

  factory DownloadProgress.validating() {
    return const DownloadProgress._(
      state: DownloadState.validating,
      message: 'Validating export...',
    );
  }

  factory DownloadProgress.downloading({double? progress}) {
    return DownloadProgress._(
      state: DownloadState.downloading,
      progress: progress,
      message: progress != null
          ? 'Downloading... ${(progress * 100).toInt()}%'
          : 'Downloading...',
    );
  }

  factory DownloadProgress.processing() {
    return const DownloadProgress._(
      state: DownloadState.processing,
      message: 'Processing file...',
    );
  }

  factory DownloadProgress.completed({
    required String filePath,
    required String fileName,
    required int fileSize,
  }) {
    return DownloadProgress._(
      state: DownloadState.completed,
      filePath: filePath,
      fileName: fileName,
      fileSize: fileSize,
      message: 'Download completed',
    );
  }

  factory DownloadProgress.failed(String error) {
    return DownloadProgress._(state: DownloadState.failed, message: error);
  }

  bool get isCompleted => state == DownloadState.completed;
  bool get isFailed => state == DownloadState.failed;
  bool get isInProgress => [
    DownloadState.started,
    DownloadState.validating,
    DownloadState.downloading,
    DownloadState.processing,
  ].contains(state);
}

enum DownloadState {
  started,
  validating,
  downloading,
  processing,
  completed,
  failed,
}

class BatchDownloadResult {
  final List<DownloadResult> results;
  final int successCount;
  final int errorCount;
  final List<String> errors;

  const BatchDownloadResult({
    required this.results,
    required this.successCount,
    required this.errorCount,
    required this.errors,
  });

  bool get hasAnySuccess => successCount > 0;
  bool get hasAnyErrors => errorCount > 0;
  int get totalCount => results.length;
  double get successRate => totalCount > 0 ? successCount / totalCount : 0.0;

  @override
  String toString() {
    return 'BatchDownloadResult(total: $totalCount, success: $successCount, errors: $errorCount)';
  }
}

class ShareResult {
  final bool success;
  final String message;
  final String? filePath;

  const ShareResult._(this.success, this.message, this.filePath);

  factory ShareResult.success(String message, String filePath) {
    return ShareResult._(true, message, filePath);
  }

  factory ShareResult.failure(String message) {
    return ShareResult._(false, message, null);
  }
}

class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult._(this.isValid, this.errorMessage);

  factory ValidationResult.valid() {
    return const ValidationResult._(true, null);
  }

  factory ValidationResult.invalid(String errorMessage) {
    return ValidationResult._(false, errorMessage);
  }
}
