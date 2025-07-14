// Path: frontend/lib/features/export/presentation/bloc/export_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/export_job_entity.dart';

abstract class ExportState extends Equatable {
  const ExportState();

  @override
  List<Object?> get props => [];
}

/// Initial State (คล้ายเดิม)
class ExportInitial extends ExportState {
  const ExportInitial();

  @override
  String toString() => 'ExportInitial()';
}

/// Loading State (คล้ายเดิม)
class ExportLoading extends ExportState {
  final String message;

  const ExportLoading({this.message = 'Processing...'});

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'ExportLoading(message: $message)';
}

/// Export Job Created State (คล้ายเดิม)
class ExportJobCreated extends ExportState {
  final ExportJobEntity exportJob;

  const ExportJobCreated(this.exportJob);

  @override
  List<Object?> get props => [exportJob];

  @override
  String toString() => 'ExportJobCreated(exportId: ${exportJob.exportId})';
}

/// Export Status Updated State (ใหม่ - สำหรับ polling)
class ExportStatusUpdated extends ExportState {
  final ExportJobEntity exportJob;

  const ExportStatusUpdated(this.exportJob);

  @override
  List<Object?> get props => [exportJob];

  @override
  String toString() =>
      'ExportStatusUpdated(exportId: ${exportJob.exportId}, status: ${exportJob.status})';
}

/// Export Completed State (คล้ายเดิม แต่เปลี่ยน property)
class ExportCompleted extends ExportState {
  final ExportJobEntity exportJob;

  const ExportCompleted(this.exportJob);

  @override
  List<Object?> get props => [exportJob];

  @override
  String toString() => 'ExportCompleted(exportId: ${exportJob.exportId})';
}

/// Export Download Success State (ใหม่)
class ExportDownloadSuccess extends ExportState {
  final int exportId;
  final String? fileName;

  const ExportDownloadSuccess(this.exportId, {this.fileName});

  @override
  List<Object?> get props => [exportId, fileName];

  @override
  String toString() =>
      'ExportDownloadSuccess(exportId: $exportId, fileName: $fileName)';
}

/// Export History Loaded State (คล้ายเดิม)
class ExportHistoryLoaded extends ExportState {
  final List<ExportJobEntity> exports;
  final bool hasMore;
  final int currentPage;

  const ExportHistoryLoaded(
    this.exports, {
    this.hasMore = false,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [exports, hasMore, currentPage];

  @override
  String toString() =>
      'ExportHistoryLoaded(count: ${exports.length}, hasMore: $hasMore)';
}

/// Export History Download Success State (คล้ายเดิม)
class ExportHistoryDownloadSuccess extends ExportState {
  final String fileName;
  final List<ExportJobEntity> exports;

  const ExportHistoryDownloadSuccess(this.fileName, this.exports);

  @override
  List<Object?> get props => [fileName, exports];

  @override
  String toString() => 'ExportHistoryDownloadSuccess(fileName: $fileName)';
}

/// Export Cancelled State (ใหม่)
class ExportCancelled extends ExportState {
  final int exportId;

  const ExportCancelled(this.exportId);

  @override
  List<Object?> get props => [exportId];

  @override
  String toString() => 'ExportCancelled(exportId: $exportId)';
}

/// Platform Not Supported State (ใหม่)
class ExportPlatformNotSupported extends ExportState {
  final String message;

  const ExportPlatformNotSupported({
    this.message =
        'Export feature is only available on web browser or desktop. Please use the web version.',
  });

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'ExportPlatformNotSupported(message: $message)';
}

/// Export Error State (คล้ายเดิม)
class ExportError extends ExportState {
  final String message;
  final String? errorCode;

  const ExportError(this.message, {this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];

  @override
  String toString() => 'ExportError(message: $message, errorCode: $errorCode)';
}
