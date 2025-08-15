// Path: frontend/lib/features/export/presentation/bloc/export_event.dart
import 'package:equatable/equatable.dart';
import '../../data/models/export_config_model.dart';

abstract class ExportEvent extends Equatable {
  const ExportEvent();

  @override
  List<Object?> get props => [];
}

/// Create Asset Export Event - Updated to accept complete configuration
class CreateAssetExport extends ExportEvent {
  final ExportConfigModel config;

  const CreateAssetExport(this.config);

  @override
  List<Object?> get props => [config];

  @override
  String toString() =>
      'CreateAssetExport(format: ${config.format}, hasFilters: ${config.hasFilters})';
}

/// Check Export Status Event
class CheckExportStatus extends ExportEvent {
  final int exportId;

  const CheckExportStatus(this.exportId);

  @override
  List<Object?> get props => [exportId];

  @override
  String toString() => 'CheckExportStatus(exportId: $exportId)';
}

/// Download Export Event
class DownloadExport extends ExportEvent {
  final int exportId;

  const DownloadExport(this.exportId);

  @override
  List<Object?> get props => [exportId];

  @override
  String toString() => 'DownloadExport(exportId: $exportId)';
}

/// Download History Export Event
class DownloadHistoryExport extends ExportEvent {
  final int exportId;

  const DownloadHistoryExport(this.exportId);

  @override
  List<Object?> get props => [exportId];

  @override
  String toString() => 'DownloadHistoryExport(exportId: $exportId)';
}

/// Load Export History Event
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

/// Cancel Export Event
class CancelExport extends ExportEvent {
  final int exportId;

  const CancelExport(this.exportId);

  @override
  List<Object?> get props => [exportId];

  @override
  String toString() => 'CancelExport(exportId: $exportId)';
}

/// Start Status Polling Event
class StartStatusPolling extends ExportEvent {
  final int exportId;

  const StartStatusPolling(this.exportId);

  @override
  List<Object?> get props => [exportId];

  @override
  String toString() => 'StartStatusPolling(exportId: $exportId)';
}

/// Stop Status Polling Event
class StopStatusPolling extends ExportEvent {
  const StopStatusPolling();

  @override
  String toString() => 'StopStatusPolling()';
}

/// Refresh Export History Event
class RefreshExportHistory extends ExportEvent {
  const RefreshExportHistory();

  @override
  String toString() => 'RefreshExportHistory()';
}

/// Check Platform Support Event
class CheckPlatformSupport extends ExportEvent {
  const CheckPlatformSupport();

  @override
  String toString() => 'CheckPlatformSupport()';
}

/// Load Master Data Event - New event for loading filter options
class LoadMasterData extends ExportEvent {
  const LoadMasterData();

  @override
  String toString() => 'LoadMasterData()';
}

/// Load Date Periods Event - New event for loading date period options
class LoadDatePeriods extends ExportEvent {
  const LoadDatePeriods();

  @override
  String toString() => 'LoadDatePeriods()';
}
