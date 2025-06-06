// Path: frontend/lib/features/export/presentation/bloc/export_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/export_job_entity.dart';
import '../../domain/entities/export_config_entity.dart';
import '../../domain/repositories/export_repository.dart';
import '../../domain/usecases/create_export_job_usecase.dart';
import '../../domain/usecases/get_export_status_usecase.dart';
import '../../domain/usecases/download_export_usecase.dart';
import 'export_event.dart';
import 'export_state.dart';

class ExportBloc extends Bloc<ExportEvent, ExportState> {
  final CreateExportJobUseCase createExportJobUseCase;
  final GetExportStatusUseCase getExportStatusUseCase;
  final DownloadExportUseCase downloadExportUseCase;
  final ExportRepository exportRepository;

  // Internal state management
  StreamSubscription<ExportStatusResult>? _pollingSubscription;
  String _currentExportType = 'assets';
  ExportConfigEntity _currentConfig = ExportConfigEntity.defaultAssets();
  List<ExportJobEntity> _exportHistory = [];
  List<int> _selectedExportIds = [];
  ExportStatsEntity? _stats;

  ExportBloc({
    required this.createExportJobUseCase,
    required this.getExportStatusUseCase,
    required this.downloadExportUseCase,
    required this.exportRepository,
  }) : super(const ExportInitial()) {
    // Export Creation Events
    on<CreateExportJobRequested>(_onCreateExportJobRequested);
    on<QuickExportRequested>(_onQuickExportRequested);

    // Export Status Events
    on<GetExportStatusRequested>(_onGetExportStatusRequested);
    on<StartPollingExportStatus>(_onStartPollingExportStatus);
    on<StopPollingExportStatus>(_onStopPollingExportStatus);

    // Export History Events
    on<LoadExportHistory>(_onLoadExportHistory);
    on<RefreshExportHistory>(_onRefreshExportHistory);

    // Download Events
    on<DownloadExportRequested>(_onDownloadExportRequested);
    on<ShareExportRequested>(_onShareExportRequested);
    on<BatchDownloadRequested>(_onBatchDownloadRequested);

    // Management Events
    on<CancelExportRequested>(_onCancelExportRequested);
    on<DeleteExportRequested>(_onDeleteExportRequested);
    on<DeleteMultipleExportsRequested>(_onDeleteMultipleExportsRequested);

    // Configuration Events
    on<UpdateExportConfig>(_onUpdateExportConfig);
    on<ResetExportConfig>(_onResetExportConfig);
    on<UpdateExportFilters>(_onUpdateExportFilters);
    on<ClearAllFilters>(_onClearAllFilters);
    on<AddPlantFilter>(_onAddPlantFilter);
    on<RemovePlantFilter>(_onRemovePlantFilter);
    on<AddLocationFilter>(_onAddLocationFilter);
    on<RemoveLocationFilter>(_onRemoveLocationFilter);
    on<UpdateDateRangeFilter>(_onUpdateDateRangeFilter);
    on<ToggleStatusFilter>(_onToggleStatusFilter);

    // Statistics Events
    on<LoadExportStats>(_onLoadExportStats);
    on<RefreshExportStats>(_onRefreshExportStats);

    // Cleanup Events
    on<CleanupExpiredFilesRequested>(_onCleanupExpiredFilesRequested);

    // UI State Events
    on<ResetExportState>(_onResetExportState);
    on<ClearExportError>(_onClearExportError);
    on<ShowExportDetails>(_onShowExportDetails);
    on<HideExportDetails>(_onHideExportDetails);

    // Selection Events
    on<SelectExport>(_onSelectExport);
    on<DeselectExport>(_onDeselectExport);
    on<SelectAllExports>(_onSelectAllExports);
    on<DeselectAllExports>(_onDeselectAllExports);
    on<ToggleExportSelection>(_onToggleExportSelection);
  }

  @override
  Future<void> close() {
    _pollingSubscription?.cancel();
    return super.close();
  }

  // Export Creation Event Handlers
  Future<void> _onCreateExportJobRequested(
    CreateExportJobRequested event,
    Emitter<ExportState> emit,
  ) async {
    emit(ExportCreating(exportType: event.exportType, config: event.config));

    try {
      final result = await createExportJobUseCase.execute(
        exportType: event.exportType,
        config: event.config,
      );

      if (result.success && result.exportJob != null) {
        emit(
          ExportJobCreated(
            exportJob: result.exportJob!,
            message: result.message,
          ),
        );

        // Start polling if export is pending
        if (result.exportJob!.isPending) {
          add(StartPollingExportStatus(result.exportJob!.exportId));
        }
      } else {
        emit(
          ExportError(
            message: result.errorMessage ?? 'Failed to create export job',
            errorType: ExportErrorType.unknown,
          ),
        );
      }
    } catch (e) {
      emit(
        ExportError(
          message: 'Failed to create export job: ${e.toString()}',
          errorType: ExportErrorType.unknown,
          originalError: e,
        ),
      );
    }
  }

  Future<void> _onQuickExportRequested(
    QuickExportRequested event,
    Emitter<ExportState> emit,
  ) async {
    final config = _getQuickExportConfig(event.type);
    add(
      CreateExportJobRequested(
        exportType: event.type.exportType,
        config: config,
      ),
    );
  }

  // Export Status Event Handlers
  Future<void> _onGetExportStatusRequested(
    GetExportStatusRequested event,
    Emitter<ExportState> emit,
  ) async {
    try {
      final result = await getExportStatusUseCase.execute(event.exportId);

      if (result.success && result.exportJob != null) {
        emit(
          ExportStatusUpdated(
            exportJob: result.exportJob!,
            isPolling: _pollingSubscription != null,
          ),
        );
      } else {
        emit(
          ExportError(
            message: result.errorMessage ?? 'Failed to get export status',
            errorType: ExportErrorType.unknown,
          ),
        );
      }
    } catch (e) {
      emit(
        ExportError(
          message: 'Failed to get export status: ${e.toString()}',
          errorType: ExportErrorType.unknown,
          originalError: e,
        ),
      );
    }
  }

  Future<void> _onStartPollingExportStatus(
    StartPollingExportStatus event,
    Emitter<ExportState> emit,
  ) async {
    // Cancel existing polling
    await _pollingSubscription?.cancel();

    emit(
      ExportPollingStarted(exportId: event.exportId, interval: event.interval),
    );

    _pollingSubscription = getExportStatusUseCase
        .pollStatus(exportId: event.exportId, interval: event.interval)
        .listen(
          (result) {
            if (result.success && result.exportJob != null) {
              emit(
                ExportStatusUpdated(
                  exportJob: result.exportJob!,
                  isPolling: true,
                ),
              );

              // Stop polling if completed or failed
              if (result.exportJob!.isCompleted || result.exportJob!.isFailed) {
                add(const StopPollingExportStatus());
              }
            } else {
              emit(
                ExportError(
                  message: result.errorMessage ?? 'Polling error',
                  errorType: ExportErrorType.network,
                ),
              );
              add(const StopPollingExportStatus());
            }
          },
          onError: (error) {
            emit(
              ExportError(
                message: 'Polling failed: ${error.toString()}',
                errorType: ExportErrorType.network,
                originalError: error,
              ),
            );
            add(const StopPollingExportStatus());
          },
        );
  }

  Future<void> _onStopPollingExportStatus(
    StopPollingExportStatus event,
    Emitter<ExportState> emit,
  ) async {
    await _pollingSubscription?.cancel();
    _pollingSubscription = null;

    emit(ExportPollingStopped(exportId: 0, reason: 'Polling stopped'));
  }

  // Export History Event Handlers
  Future<void> _onLoadExportHistory(
    LoadExportHistory event,
    Emitter<ExportState> emit,
  ) async {
    if (event.refresh || _exportHistory.isEmpty) {
      emit(ExportLoading(message: 'Loading export history...'));
    }

    try {
      final exports = await exportRepository.getExportHistory(
        page: event.page,
        limit: event.limit,
        status: event.statusFilter,
      );

      if (event.refresh || event.page == 1) {
        _exportHistory = exports;
      } else {
        _exportHistory.addAll(exports);
      }

      final meta = ExportHistoryMeta(
        currentPage: event.page,
        totalPages: 1, // This would come from API response
        totalItems: _exportHistory.length,
        itemsPerPage: event.limit,
        hasNextPage: exports.length >= event.limit,
        hasPrevPage: event.page > 1,
      );

      emit(
        ExportHistoryLoaded(
          exports: List.from(_exportHistory),
          meta: meta,
          selectedExportIds: List.from(_selectedExportIds),
        ),
      );
    } catch (e) {
      emit(
        ExportError(
          message: 'Failed to load export history: ${e.toString()}',
          errorType: _mapExceptionToErrorType(e),
          originalError: e,
        ),
      );
    }
  }

  Future<void> _onRefreshExportHistory(
    RefreshExportHistory event,
    Emitter<ExportState> emit,
  ) async {
    add(LoadExportHistory(refresh: true));
  }

  // Download Event Handlers
  Future<void> _onDownloadExportRequested(
    DownloadExportRequested event,
    Emitter<ExportState> emit,
  ) async {
    emit(ExportDownloading(exportId: event.exportId));

    try {
      await emit.forEach(
        downloadExportUseCase.downloadWithProgress(
          exportId: event.exportId,
          customFileName: event.customFileName,
          customDirectory: event.customDirectory,
        ),
        onData: (progress) {
          if (progress.isCompleted) {
            return ExportDownloadCompleted(
              filePath: progress.filePath!,
              fileName: progress.fileName!,
              fileSize: progress.fileSize!,
              message: progress.message!,
            );
          } else if (progress.isFailed) {
            return ExportError(
              message: progress.message!,
              errorType: ExportErrorType.fileSystem,
            );
          } else {
            return ExportDownloading(
              exportId: event.exportId,
              fileName: progress.fileName,
              progress: progress.progress,
            );
          }
        },
      );
    } catch (e) {
      emit(
        ExportError(
          message: 'Download failed: ${e.toString()}',
          errorType: ExportErrorType.fileSystem,
          originalError: e,
        ),
      );
    }
  }

  Future<void> _onShareExportRequested(
    ShareExportRequested event,
    Emitter<ExportState> emit,
  ) async {
    emit(ExportLoading(message: 'Preparing to share...'));

    try {
      final result = await downloadExportUseCase.shareExport(event.exportId);

      if (result.success) {
        emit(ExportShared(filePath: result.filePath!, message: result.message));
      } else {
        emit(
          ExportError(
            message: result.message,
            errorType: ExportErrorType.fileSystem,
          ),
        );
      }
    } catch (e) {
      emit(
        ExportError(
          message: 'Share failed: ${e.toString()}',
          errorType: ExportErrorType.fileSystem,
          originalError: e,
        ),
      );
    }
  }

  Future<void> _onBatchDownloadRequested(
    BatchDownloadRequested event,
    Emitter<ExportState> emit,
  ) async {
    if (event.exportIds.isEmpty) {
      emit(
        ExportError(
          message: 'No exports selected for download',
          errorType: ExportErrorType.validation,
        ),
      );
      return;
    }

    emit(
      BatchDownloadProgress(
        totalItems: event.exportIds.length,
        completedItems: 0,
      ),
    );

    try {
      final result = await downloadExportUseCase.downloadMultiple(
        exportIds: event.exportIds,
        baseDirectory: event.baseDirectory,
      );

      emit(
        BatchDownloadCompleted(
          successCount: result.successCount,
          errorCount: result.errorCount,
          downloadedFiles: result.results
              .where((r) => r.success)
              .map((r) => r.fileName!)
              .toList(),
          errors: result.errors,
        ),
      );
    } catch (e) {
      emit(
        ExportError(
          message: 'Batch download failed: ${e.toString()}',
          errorType: ExportErrorType.fileSystem,
          originalError: e,
        ),
      );
    }
  }

  // Management Event Handlers
  Future<void> _onCancelExportRequested(
    CancelExportRequested event,
    Emitter<ExportState> emit,
  ) async {
    emit(ExportLoading(message: 'Cancelling export...'));

    try {
      final success = await exportRepository.cancelExportJob(event.exportId);

      if (success) {
        emit(
          ExportCancelled(
            exportId: event.exportId,
            message: 'Export cancelled successfully',
          ),
        );

        // Stop polling if this export was being polled
        add(const StopPollingExportStatus());

        // Refresh history
        add(RefreshExportHistory());
      } else {
        emit(
          ExportError(
            message: 'Failed to cancel export',
            errorType: ExportErrorType.unknown,
          ),
        );
      }
    } catch (e) {
      emit(
        ExportError(
          message: 'Cancel failed: ${e.toString()}',
          errorType: _mapExceptionToErrorType(e),
          originalError: e,
        ),
      );
    }
  }

  Future<void> _onDeleteExportRequested(
    DeleteExportRequested event,
    Emitter<ExportState> emit,
  ) async {
    emit(ExportLoading(message: 'Deleting export...'));

    try {
      final success = await exportRepository.deleteExportJob(event.exportId);

      if (success) {
        emit(
          ExportDeleted(
            exportId: event.exportId,
            message: 'Export deleted successfully',
          ),
        );

        // Remove from selection if selected
        _selectedExportIds.remove(event.exportId);

        // Refresh history
        add(RefreshExportHistory());
      } else {
        emit(
          ExportError(
            message: 'Failed to delete export',
            errorType: ExportErrorType.unknown,
          ),
        );
      }
    } catch (e) {
      emit(
        ExportError(
          message: 'Delete failed: ${e.toString()}',
          errorType: _mapExceptionToErrorType(e),
          originalError: e,
        ),
      );
    }
  }

  Future<void> _onDeleteMultipleExportsRequested(
    DeleteMultipleExportsRequested event,
    Emitter<ExportState> emit,
  ) async {
    if (event.exportIds.isEmpty) return;

    emit(ExportLoading(message: 'Deleting selected exports...'));

    int deletedCount = 0;
    final errors = <String>[];

    for (final exportId in event.exportIds) {
      try {
        final success = await exportRepository.deleteExportJob(exportId);
        if (success) {
          deletedCount++;
          _selectedExportIds.remove(exportId);
        } else {
          errors.add('Failed to delete export $exportId');
        }
      } catch (e) {
        errors.add('Export $exportId: ${e.toString()}');
      }
    }

    emit(MultipleExportsDeleted(deletedCount: deletedCount, errors: errors));

    // Refresh history
    add(RefreshExportHistory());
  }

  // Configuration Event Handlers
  Future<void> _onUpdateExportConfig(
    UpdateExportConfig event,
    Emitter<ExportState> emit,
  ) async {
    _currentConfig = event.config;
    emit(
      ExportConfigUpdated(
        exportType: _currentExportType,
        config: _currentConfig,
      ),
    );
  }

  Future<void> _onResetExportConfig(
    ResetExportConfig event,
    Emitter<ExportState> emit,
  ) async {
    _currentExportType = event.exportType;
    _currentConfig = _getDefaultConfig(event.exportType);
    emit(
      ExportConfigUpdated(
        exportType: _currentExportType,
        config: _currentConfig,
      ),
    );
  }

  Future<void> _onUpdateExportFilters(
    UpdateExportFilters event,
    Emitter<ExportState> emit,
  ) async {
    _currentConfig = _currentConfig.copyWith(filters: event.filters);
    emit(
      ExportConfigUpdated(
        exportType: _currentExportType,
        config: _currentConfig,
      ),
    );
  }

  Future<void> _onClearAllFilters(
    ClearAllFilters event,
    Emitter<ExportState> emit,
  ) async {
    _currentConfig = _currentConfig.copyWith(filters: ExportFiltersEntity());
    emit(
      ExportConfigUpdated(
        exportType: _currentExportType,
        config: _currentConfig,
      ),
    );
  }

  // Filter Event Handlers
  Future<void> _onAddPlantFilter(
    AddPlantFilter event,
    Emitter<ExportState> emit,
  ) async {
    final currentFilters = _currentConfig.filters ?? ExportFiltersEntity();
    final plantCodes = List<String>.from(currentFilters.plantCodes ?? []);

    if (!plantCodes.contains(event.plantCode)) {
      plantCodes.add(event.plantCode);
      final updatedFilters = currentFilters.copyWith(plantCodes: plantCodes);
      _currentConfig = _currentConfig.copyWith(filters: updatedFilters);

      emit(
        ExportConfigUpdated(
          exportType: _currentExportType,
          config: _currentConfig,
        ),
      );
    }
  }

  Future<void> _onRemovePlantFilter(
    RemovePlantFilter event,
    Emitter<ExportState> emit,
  ) async {
    final currentFilters = _currentConfig.filters ?? ExportFiltersEntity();
    final plantCodes = List<String>.from(currentFilters.plantCodes ?? []);

    plantCodes.remove(event.plantCode);
    final updatedFilters = currentFilters.copyWith(
      plantCodes: plantCodes.isEmpty ? null : plantCodes,
    );
    _currentConfig = _currentConfig.copyWith(filters: updatedFilters);

    emit(
      ExportConfigUpdated(
        exportType: _currentExportType,
        config: _currentConfig,
      ),
    );
  }

  Future<void> _onAddLocationFilter(
    AddLocationFilter event,
    Emitter<ExportState> emit,
  ) async {
    final currentFilters = _currentConfig.filters ?? ExportFiltersEntity();
    final locationCodes = List<String>.from(currentFilters.locationCodes ?? []);

    if (!locationCodes.contains(event.locationCode)) {
      locationCodes.add(event.locationCode);
      final updatedFilters = currentFilters.copyWith(
        locationCodes: locationCodes,
      );
      _currentConfig = _currentConfig.copyWith(filters: updatedFilters);

      emit(
        ExportConfigUpdated(
          exportType: _currentExportType,
          config: _currentConfig,
        ),
      );
    }
  }

  Future<void> _onRemoveLocationFilter(
    RemoveLocationFilter event,
    Emitter<ExportState> emit,
  ) async {
    final currentFilters = _currentConfig.filters ?? ExportFiltersEntity();
    final locationCodes = List<String>.from(currentFilters.locationCodes ?? []);

    locationCodes.remove(event.locationCode);
    final updatedFilters = currentFilters.copyWith(
      locationCodes: locationCodes.isEmpty ? null : locationCodes,
    );
    _currentConfig = _currentConfig.copyWith(filters: updatedFilters);

    emit(
      ExportConfigUpdated(
        exportType: _currentExportType,
        config: _currentConfig,
      ),
    );
  }

  Future<void> _onUpdateDateRangeFilter(
    UpdateDateRangeFilter event,
    Emitter<ExportState> emit,
  ) async {
    final currentFilters = _currentConfig.filters ?? ExportFiltersEntity();
    final updatedFilters = currentFilters.copyWith(dateRange: event.dateRange);
    _currentConfig = _currentConfig.copyWith(filters: updatedFilters);

    emit(
      ExportConfigUpdated(
        exportType: _currentExportType,
        config: _currentConfig,
      ),
    );
  }

  Future<void> _onToggleStatusFilter(
    ToggleStatusFilter event,
    Emitter<ExportState> emit,
  ) async {
    final currentFilters = _currentConfig.filters ?? ExportFiltersEntity();
    final status = List<String>.from(currentFilters.status ?? []);

    if (status.contains(event.status)) {
      status.remove(event.status);
    } else {
      status.add(event.status);
    }

    final updatedFilters = currentFilters.copyWith(
      status: status.isEmpty ? null : status,
    );
    _currentConfig = _currentConfig.copyWith(filters: updatedFilters);

    emit(
      ExportConfigUpdated(
        exportType: _currentExportType,
        config: _currentConfig,
      ),
    );
  }

  // Statistics Event Handlers
  Future<void> _onLoadExportStats(
    LoadExportStats event,
    Emitter<ExportState> emit,
  ) async {
    if (_stats == null) {
      emit(ExportLoading(message: 'Loading statistics...'));
    }

    try {
      _stats = await exportRepository.getExportStats();
      emit(ExportStatsLoaded(_stats!));
    } catch (e) {
      emit(
        ExportError(
          message: 'Failed to load statistics: ${e.toString()}',
          errorType: _mapExceptionToErrorType(e),
          originalError: e,
        ),
      );
    }
  }

  Future<void> _onRefreshExportStats(
    RefreshExportStats event,
    Emitter<ExportState> emit,
  ) async {
    _stats = null;
    add(LoadExportStats());
  }

  // Cleanup Event Handlers
  Future<void> _onCleanupExpiredFilesRequested(
    CleanupExpiredFilesRequested event,
    Emitter<ExportState> emit,
  ) async {
    emit(ExportLoading(message: 'Cleaning up expired files...'));

    try {
      final deletedCount = await exportRepository.cleanupExpiredFiles();
      emit(
        CleanupCompleted(
          deletedCount: deletedCount,
          message: '$deletedCount expired files cleaned up',
        ),
      );

      // Refresh stats and history
      add(RefreshExportStats());
      add(RefreshExportHistory());
    } catch (e) {
      emit(
        ExportError(
          message: 'Cleanup failed: ${e.toString()}',
          errorType: _mapExceptionToErrorType(e),
          originalError: e,
        ),
      );
    }
  }

  // UI State Event Handlers
  Future<void> _onResetExportState(
    ResetExportState event,
    Emitter<ExportState> emit,
  ) async {
    await _pollingSubscription?.cancel();
    _pollingSubscription = null;
    _selectedExportIds.clear();
    emit(ExportInitial());
  }

  Future<void> _onClearExportError(
    ClearExportError event,
    Emitter<ExportState> emit,
  ) async {
    if (state is ExportError) {
      emit(ExportInitial());
    }
  }

  Future<void> _onShowExportDetails(
    ShowExportDetails event,
    Emitter<ExportState> emit,
  ) async {
    if (state is ExportHistoryLoaded) {
      final currentState = state as ExportHistoryLoaded;
      final detailedExport = currentState.exports.firstWhere(
        (export) => export.exportId == event.exportId,
      );

      emit(currentState.copyWith(detailedExport: detailedExport));
    }
  }

  Future<void> _onHideExportDetails(
    HideExportDetails event,
    Emitter<ExportState> emit,
  ) async {
    if (state is ExportHistoryLoaded) {
      final currentState = state as ExportHistoryLoaded;
      emit(currentState.copyWith(detailedExport: null));
    }
  }

  // Selection Event Handlers
  Future<void> _onSelectExport(
    SelectExport event,
    Emitter<ExportState> emit,
  ) async {
    if (!_selectedExportIds.contains(event.exportId)) {
      _selectedExportIds.add(event.exportId);
      _emitUpdatedHistoryState(emit);
    }
  }

  Future<void> _onDeselectExport(
    DeselectExport event,
    Emitter<ExportState> emit,
  ) async {
    _selectedExportIds.remove(event.exportId);
    _emitUpdatedHistoryState(emit);
  }

  Future<void> _onSelectAllExports(
    SelectAllExports event,
    Emitter<ExportState> emit,
  ) async {
    _selectedExportIds = _exportHistory.map((e) => e.exportId).toList();
    _emitUpdatedHistoryState(emit);
  }

  Future<void> _onDeselectAllExports(
    DeselectAllExports event,
    Emitter<ExportState> emit,
  ) async {
    _selectedExportIds.clear();
    _emitUpdatedHistoryState(emit);
  }

  Future<void> _onToggleExportSelection(
    ToggleExportSelection event,
    Emitter<ExportState> emit,
  ) async {
    if (_selectedExportIds.contains(event.exportId)) {
      _selectedExportIds.remove(event.exportId);
    } else {
      _selectedExportIds.add(event.exportId);
    }
    _emitUpdatedHistoryState(emit);
  }

  // Helper Methods
  void _emitUpdatedHistoryState(Emitter<ExportState> emit) {
    if (state is ExportHistoryLoaded) {
      final currentState = state as ExportHistoryLoaded;
      emit(
        currentState.copyWith(selectedExportIds: List.from(_selectedExportIds)),
      );
    }
  }

  ExportConfigEntity _getQuickExportConfig(QuickExportType type) {
    switch (type) {
      case QuickExportType.allActiveAssets:
        return ExportConfigEntity.quickAllAssets();
      case QuickExportType.recentScans:
        return ExportConfigEntity.recentScans();
      case QuickExportType.monthlyReport:
        return ExportConfigEntity(
          format: 'xlsx',
          filters: ExportFiltersEntity(
            dateRange: DateRangeEntity(
              from: DateTime(2023, 11, 1), // This month
              to: DateTime(2023, 11, 30),
            ),
          ),
        );
      case QuickExportType.customRange:
        return ExportConfigEntity.defaultAssets();
    }
  }

  ExportConfigEntity _getDefaultConfig(String exportType) {
    switch (exportType) {
      case 'assets':
        return ExportConfigEntity.defaultAssets();
      case 'scan_logs':
        return ExportConfigEntity.recentScans();
      case 'status_history':
        return ExportConfigEntity(
          format: 'xlsx',
          filters: ExportFiltersEntity(
            dateRange: DateRangeEntity(
              from: DateTime(2023, 11, 1),
              to: DateTime(2023, 11, 30),
            ),
          ),
        );
      default:
        return ExportConfigEntity.defaultAssets();
    }
  }

  ExportErrorType _mapExceptionToErrorType(dynamic exception) {
    final errorString = exception.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      return ExportErrorType.network;
    }
    if (errorString.contains('timeout')) {
      return ExportErrorType.timeout;
    }
    if (errorString.contains('auth') || errorString.contains('401')) {
      return ExportErrorType.authentication;
    }
    if (errorString.contains('permission') || errorString.contains('403')) {
      return ExportErrorType.permission;
    }
    if (errorString.contains('validation') || errorString.contains('400')) {
      return ExportErrorType.validation;
    }
    if (errorString.contains('server') || errorString.contains('500')) {
      return ExportErrorType.server;
    }
    if (errorString.contains('file') || errorString.contains('storage')) {
      return ExportErrorType.fileSystem;
    }

    return ExportErrorType.unknown;
  }
}
