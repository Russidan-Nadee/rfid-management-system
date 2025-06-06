// Path: frontend/lib/features/export/presentation/bloc/export_event.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/export_config_entity.dart';

abstract class ExportEvent extends Equatable {
  const ExportEvent();

  @override
  List<Object?> get props => [];
}

// Export Creation Events
class CreateExportJobRequested extends ExportEvent {
  final String exportType;
  final ExportConfigEntity config;

  const CreateExportJobRequested({
    required this.exportType,
    required this.config,
  });

  @override
  List<Object?> get props => [exportType, config];

  @override
  String toString() {
    return 'CreateExportJobRequested(type: $exportType, format: ${config.format})';
  }
}

class QuickExportRequested extends ExportEvent {
  final QuickExportType type;

  const QuickExportRequested(this.type);

  @override
  List<Object?> get props => [type];

  @override
  String toString() => 'QuickExportRequested($type)';
}

// Export Status Events
class GetExportStatusRequested extends ExportEvent {
  final int exportId;

  const GetExportStatusRequested(this.exportId);

  @override
  List<Object?> get props => [exportId];

  @override
  String toString() => 'GetExportStatusRequested($exportId)';
}

class StartPollingExportStatus extends ExportEvent {
  final int exportId;
  final Duration interval;

  const StartPollingExportStatus(
    this.exportId, {
    this.interval = const Duration(seconds: 3),
  });

  @override
  List<Object?> get props => [exportId, interval];

  @override
  String toString() => 'StartPollingExportStatus($exportId)';
}

class StopPollingExportStatus extends ExportEvent {
  const StopPollingExportStatus();
}

// Export History Events
class LoadExportHistory extends ExportEvent {
  final int page;
  final int limit;
  final String? statusFilter;
  final bool refresh;

  const LoadExportHistory({
    this.page = 1,
    this.limit = 20,
    this.statusFilter,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [page, limit, statusFilter, refresh];

  @override
  String toString() {
    return 'LoadExportHistory(page: $page, limit: $limit, status: $statusFilter, refresh: $refresh)';
  }
}

class RefreshExportHistory extends ExportEvent {
  const RefreshExportHistory();
}

// Export Download Events
class DownloadExportRequested extends ExportEvent {
  final int exportId;
  final String? customFileName;
  final String? customDirectory;

  const DownloadExportRequested(
    this.exportId, {
    this.customFileName,
    this.customDirectory,
  });

  @override
  List<Object?> get props => [exportId, customFileName, customDirectory];

  @override
  String toString() => 'DownloadExportRequested($exportId)';
}

class ShareExportRequested extends ExportEvent {
  final int exportId;

  const ShareExportRequested(this.exportId);

  @override
  List<Object?> get props => [exportId];

  @override
  String toString() => 'ShareExportRequested($exportId)';
}

class BatchDownloadRequested extends ExportEvent {
  final List<int> exportIds;
  final String? baseDirectory;

  const BatchDownloadRequested(this.exportIds, {this.baseDirectory});

  @override
  List<Object?> get props => [exportIds, baseDirectory];

  @override
  String toString() => 'BatchDownloadRequested(${exportIds.length} items)';
}

// Export Management Events
class CancelExportRequested extends ExportEvent {
  final int exportId;

  const CancelExportRequested(this.exportId);

  @override
  List<Object?> get props => [exportId];

  @override
  String toString() => 'CancelExportRequested($exportId)';
}

class DeleteExportRequested extends ExportEvent {
  final int exportId;

  const DeleteExportRequested(this.exportId);

  @override
  List<Object?> get props => [exportId];

  @override
  String toString() => 'DeleteExportRequested($exportId)';
}

class DeleteMultipleExportsRequested extends ExportEvent {
  final List<int> exportIds;

  const DeleteMultipleExportsRequested(this.exportIds);

  @override
  List<Object?> get props => [exportIds];

  @override
  String toString() =>
      'DeleteMultipleExportsRequested(${exportIds.length} items)';
}

// Configuration Events
class UpdateExportConfig extends ExportEvent {
  final ExportConfigEntity config;

  const UpdateExportConfig(this.config);

  @override
  List<Object?> get props => [config];

  @override
  String toString() => 'UpdateExportConfig(${config.format})';
}

class ResetExportConfig extends ExportEvent {
  final String exportType;

  const ResetExportConfig(this.exportType);

  @override
  List<Object?> get props => [exportType];

  @override
  String toString() => 'ResetExportConfig($exportType)';
}

class UpdateExportFilters extends ExportEvent {
  final ExportFiltersEntity filters;

  const UpdateExportFilters(this.filters);

  @override
  List<Object?> get props => [filters];

  @override
  String toString() => 'UpdateExportFilters(${filters.filterCount} filters)';
}

class ClearAllFilters extends ExportEvent {
  const ClearAllFilters();
}

class AddPlantFilter extends ExportEvent {
  final String plantCode;

  const AddPlantFilter(this.plantCode);

  @override
  List<Object?> get props => [plantCode];

  @override
  String toString() => 'AddPlantFilter($plantCode)';
}

class RemovePlantFilter extends ExportEvent {
  final String plantCode;

  const RemovePlantFilter(this.plantCode);

  @override
  List<Object?> get props => [plantCode];

  @override
  String toString() => 'RemovePlantFilter($plantCode)';
}

class AddLocationFilter extends ExportEvent {
  final String locationCode;

  const AddLocationFilter(this.locationCode);

  @override
  List<Object?> get props => [locationCode];

  @override
  String toString() => 'AddLocationFilter($locationCode)';
}

class RemoveLocationFilter extends ExportEvent {
  final String locationCode;

  const RemoveLocationFilter(this.locationCode);

  @override
  List<Object?> get props => [locationCode];

  @override
  String toString() => 'RemoveLocationFilter($locationCode)';
}

class UpdateDateRangeFilter extends ExportEvent {
  final DateRangeEntity? dateRange;

  const UpdateDateRangeFilter(this.dateRange);

  @override
  List<Object?> get props => [dateRange];

  @override
  String toString() => 'UpdateDateRangeFilter($dateRange)';
}

class ToggleStatusFilter extends ExportEvent {
  final String status;

  const ToggleStatusFilter(this.status);

  @override
  List<Object?> get props => [status];

  @override
  String toString() => 'ToggleStatusFilter($status)';
}

// Statistics Events
class LoadExportStats extends ExportEvent {
  const LoadExportStats();
}

class RefreshExportStats extends ExportEvent {
  const RefreshExportStats();
}

// Cleanup Events
class CleanupExpiredFilesRequested extends ExportEvent {
  const CleanupExpiredFilesRequested();
}

// UI State Events
class ResetExportState extends ExportEvent {
  const ResetExportState();
}

class ClearExportError extends ExportEvent {
  const ClearExportError();
}

class ShowExportDetails extends ExportEvent {
  final int exportId;

  const ShowExportDetails(this.exportId);

  @override
  List<Object?> get props => [exportId];

  @override
  String toString() => 'ShowExportDetails($exportId)';
}

class HideExportDetails extends ExportEvent {
  const HideExportDetails();
}

// Selection Events (for multi-select operations)
class SelectExport extends ExportEvent {
  final int exportId;

  const SelectExport(this.exportId);

  @override
  List<Object?> get props => [exportId];

  @override
  String toString() => 'SelectExport($exportId)';
}

class DeselectExport extends ExportEvent {
  final int exportId;

  const DeselectExport(this.exportId);

  @override
  List<Object?> get props => [exportId];

  @override
  String toString() => 'DeselectExport($exportId)';
}

class SelectAllExports extends ExportEvent {
  const SelectAllExports();
}

class DeselectAllExports extends ExportEvent {
  const DeselectAllExports();
}

class ToggleExportSelection extends ExportEvent {
  final int exportId;

  const ToggleExportSelection(this.exportId);

  @override
  List<Object?> get props => [exportId];

  @override
  String toString() => 'ToggleExportSelection($exportId)';
}

// Navigation Events
class NavigateToExportHistory extends ExportEvent {
  const NavigateToExportHistory();
}

class NavigateToExportConfig extends ExportEvent {
  final String exportType;

  const NavigateToExportConfig(this.exportType);

  @override
  List<Object?> get props => [exportType];

  @override
  String toString() => 'NavigateToExportConfig($exportType)';
}

// Enums for event types
enum QuickExportType {
  allActiveAssets,
  recentScans,
  monthlyReport,
  customRange,
}

extension QuickExportTypeExtension on QuickExportType {
  String get displayName {
    switch (this) {
      case QuickExportType.allActiveAssets:
        return 'All Active Assets';
      case QuickExportType.recentScans:
        return 'Recent Scans (7 days)';
      case QuickExportType.monthlyReport:
        return 'Monthly Report';
      case QuickExportType.customRange:
        return 'Custom Date Range';
    }
  }

  String get description {
    switch (this) {
      case QuickExportType.allActiveAssets:
        return 'Export all active assets with basic information';
      case QuickExportType.recentScans:
        return 'Export scan logs from the last 7 days';
      case QuickExportType.monthlyReport:
        return 'Export this month\'s status changes and activity';
      case QuickExportType.customRange:
        return 'Configure custom filters and date range';
    }
  }

  String get exportType {
    switch (this) {
      case QuickExportType.allActiveAssets:
        return 'assets';
      case QuickExportType.recentScans:
        return 'scan_logs';
      case QuickExportType.monthlyReport:
        return 'status_history';
      case QuickExportType.customRange:
        return 'assets'; // Default
    }
  }
}
