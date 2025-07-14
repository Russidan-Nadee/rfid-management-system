// Path: frontend/lib/features/export/presentation/bloc/export_event.dart
import 'package:equatable/equatable.dart';

abstract class ExportEvent extends Equatable {
  const ExportEvent();

  @override
  List<Object?> get props => [];
}

/// Create Asset Export Event (คล้ายเดิม)
class CreateAssetExport extends ExportEvent {
  final String format;

  const CreateAssetExport(this.format);

  @override
  List<Object?> get props => [format];

  @override
  String toString() => 'CreateAssetExport(format: $format)';
}

/// Check Export Status Event (คล้ายเดิม)
class CheckExportStatus extends ExportEvent {
  final int exportId;

  const CheckExportStatus(this.exportId);

  @override
  List<Object?> get props => [exportId];

  @override
  String toString() => 'CheckExportStatus(exportId: $exportId)';
}

/// Download Export Event (คล้ายเดิม)
class DownloadExport extends ExportEvent {
  final int exportId;

  const DownloadExport(this.exportId);

  @override
  List<Object?> get props => [exportId];

  @override
  String toString() => 'DownloadExport(exportId: $exportId)';
}

/// Download History Export Event (คล้ายเดิม)
class DownloadHistoryExport extends ExportEvent {
  final int exportId;

  const DownloadHistoryExport(this.exportId);

  @override
  List<Object?> get props => [exportId];

  @override
  String toString() => 'DownloadHistoryExport(exportId: $exportId)';
}

/// Load Export History Event (คล้ายเดิม)
class LoadExportHistory extends ExportEvent {
  final int page;
  final int limit;
  final String? status;

  const LoadExportHistory({this.page = 1, this.limit = 20, this.status});

  @override
  List<Object?> get props => [page, limit, status];

  @override
  String toString() =>
      'LoadExportHistory(page: $page, limit: $limit, status: $status)';
}

/// Cancel Export Event (ใหม่)
class CancelExport extends ExportEvent {
  final int exportId;

  const CancelExport(this.exportId);

  @override
  List<Object?> get props => [exportId];

  @override
  String toString() => 'CancelExport(exportId: $exportId)';
}

/// Start Status Polling Event (ใหม่ - สำหรับ real-time update)
class StartStatusPolling extends ExportEvent {
  final int exportId;

  const StartStatusPolling(this.exportId);

  @override
  List<Object?> get props => [exportId];

  @override
  String toString() => 'StartStatusPolling(exportId: $exportId)';
}

/// Stop Status Polling Event (ใหม่)
class StopStatusPolling extends ExportEvent {
  const StopStatusPolling();

  @override
  String toString() => 'StopStatusPolling()';
}

/// Refresh Export History Event (ใหม่ - สำหรับ pull-to-refresh)
class RefreshExportHistory extends ExportEvent {
  const RefreshExportHistory();

  @override
  String toString() => 'RefreshExportHistory()';
}

/// Check Platform Support Event (ใหม่ - เช็ค mobile ไม่ได้ใช้)
class CheckPlatformSupport extends ExportEvent {
  const CheckPlatformSupport();

  @override
  String toString() => 'CheckPlatformSupport()';
}
