// Path: frontend/lib/features/export/presentation/bloc/export_bloc.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tp_rfid/features/export/domain/entities/export_job_entity.dart';

import '../../domain/usecases/create_export_job_usecase.dart';
import '../../domain/usecases/get_export_status_usecase.dart';
import '../../domain/usecases/download_export_usecase.dart';
import '../../domain/usecases/get_export_history_usecase.dart';
import '../../domain/usecases/cancel_export_usecase.dart';
import '../../data/models/period_model.dart';
import 'export_event.dart';
import 'export_state.dart';

class ExportBloc extends Bloc<ExportEvent, ExportState> {
  final CreateExportJobUseCase createExportJobUseCase;
  final GetExportStatusUseCase getExportStatusUseCase;
  final DownloadExportUseCase downloadExportUseCase;
  final GetExportHistoryUseCase getExportHistoryUseCase;
  final CancelExportUseCase cancelExportUseCase;

  Timer? _statusTimer;
  int? _currentPollingExportId;

  ExportBloc({
    required this.createExportJobUseCase,
    required this.getExportStatusUseCase,
    required this.downloadExportUseCase,
    required this.getExportHistoryUseCase,
    required this.cancelExportUseCase,
  }) : super(const ExportInitial()) {
    on<CreateAssetExport>(_onCreateAssetExport);
    on<CheckExportStatus>(_onCheckExportStatus);
    on<DownloadExport>(_onDownloadExport);
    on<DownloadHistoryExport>(_onDownloadHistoryExport);
    on<LoadExportHistory>(_onLoadExportHistory);
    on<RefreshExportHistory>(_onRefreshExportHistory);
    on<CancelExport>(_onCancelExport);
    on<StartStatusPolling>(_onStartStatusPolling);
    on<StopStatusPolling>(_onStopStatusPolling);
    on<CheckPlatformSupport>(_onCheckPlatformSupport);
    on<LoadDatePeriods>(_onLoadDatePeriods);
  }

  /// Platform Support Check
  bool get isPlatformSupported {
    if (kIsWeb) return true;
    if (!kIsWeb) {
      return !Platform.isAndroid && !Platform.isIOS;
    }
    return false;
  }

  /// Create Asset Export
  Future<void> _onCreateAssetExport(
    CreateAssetExport event,
    Emitter<ExportState> emit,
  ) async {
    // Platform check
    if (!isPlatformSupported) {
      emit(const ExportPlatformNotSupported());
      return;
    }

    emit(const ExportLoading(message: 'Creating export job...'));

    try {
      // Use the complete configuration from UI
      final config = event.config;

      // Validate configuration
      if (!config.isValidFormat) {
        emit(
          const ExportError(
            'Invalid export format. Please select xlsx or csv.',
          ),
        );
        return;
      }

      // Log configuration for debugging (no date range anymore)
      print('🎯 Export Configuration:');
      print('   Format: ${config.format}');
      print('   Has Filters: ${config.hasFilters}');

      if (config.filters?.plantCodes?.isNotEmpty == true) {
        print('   Plants: ${config.filters!.plantCodes}');
      }
      if (config.filters?.locationCodes?.isNotEmpty == true) {
        print('   Locations: ${config.filters!.locationCodes}');
      }
      if (config.filters?.status?.isNotEmpty == true) {
        print('   Status: ${config.filters!.status}');
      }

      print('   Note: Exporting ALL data (no date restrictions)');

      // Call UseCase with complete configuration
      final result = await createExportJobUseCase.execute(
        exportType: 'assets',
        config: config,
      );

      result.fold((failure) => emit(ExportError(failure.message)), (exportJob) {
        emit(ExportJobCreated(exportJob));
        // Start polling for status updates
        add(StartStatusPolling(exportJob.exportId));
      });
    } catch (e) {
      emit(ExportError('Failed to create export: ${e.toString()}'));
    }
  }

  /// Check Export Status
  Future<void> _onCheckExportStatus(
    CheckExportStatus event,
    Emitter<ExportState> emit,
  ) async {
    try {
      final result = await getExportStatusUseCase.execute(event.exportId);

      result.fold(
        (failure) {
          // Stop polling on error
          add(const StopStatusPolling());
          emit(ExportError(failure.message));
        },
        (exportJob) {
          if (exportJob.isCompleted) {
            // Stop polling when completed
            add(const StopStatusPolling());
            emit(ExportCompleted(exportJob));
          } else if (exportJob.isFailed) {
            // Stop polling on failure
            add(const StopStatusPolling());
            emit(ExportError(exportJob.errorMessage ?? 'Export failed'));
          } else {
            // Continue polling
            emit(ExportStatusUpdated(exportJob));
          }
        },
      );
    } catch (e) {
      add(const StopStatusPolling());
      emit(ExportError('Failed to check status: ${e.toString()}'));
    }
  }

  /// Download Export
  Future<void> _onDownloadExport(
    DownloadExport event,
    Emitter<ExportState> emit,
  ) async {
    // Platform check
    if (!isPlatformSupported) {
      emit(const ExportPlatformNotSupported());
      return;
    }

    emit(const ExportLoading(message: 'Downloading file...'));

    try {
      final result = await downloadExportUseCase.execute(event.exportId);

      result.fold(
        (failure) => emit(ExportError(failure.message)),
        (_) => emit(ExportDownloadSuccess(event.exportId)),
      );
    } catch (e) {
      emit(ExportError('Download failed: ${e.toString()}'));
    }
  }

  /// Download History Export (same as DownloadExport but maintains history state)
  Future<void> _onDownloadHistoryExport(
    DownloadHistoryExport event,
    Emitter<ExportState> emit,
  ) async {
    // Platform check
    if (!isPlatformSupported) {
      emit(const ExportPlatformNotSupported());
      return;
    }

    // Store current state
    final currentState = state;
    List<ExportJobEntity> currentExports = [];

    if (currentState is ExportHistoryLoaded) {
      currentExports = currentState.exports;
    }

    try {
      final result = await downloadExportUseCase.execute(event.exportId);

      result.fold((failure) => emit(ExportError(failure.message)), (_) {
        // Find the export job to get filename
        final exportJob = currentExports.firstWhere(
          (job) => job.exportId == event.exportId,
          orElse: () => ExportJobEntity(
            exportId: event.exportId,
            exportType: 'assets',
            status: 'C',
            createdAt: DateTime.now(),
            expiresAt: DateTime.now().add(const Duration(hours: 24)),
          ),
        );

        emit(
          ExportHistoryDownloadSuccess(
            exportJob.displayFilename,
            currentExports,
          ),
        );
      });
    } catch (e) {
      emit(ExportError('Download failed: ${e.toString()}'));
    }
  }

  /// Load Export History
  Future<void> _onLoadExportHistory(
    LoadExportHistory event,
    Emitter<ExportState> emit,
  ) async {
    emit(const ExportLoading(message: 'Loading export history...'));

    try {
      final params = GetExportHistoryParams(
        page: event.page,
        limit: event.limit,
        status: event.status,
      );

      final result = await getExportHistoryUseCase.execute(params);

      result.fold((failure) => emit(ExportError(failure.message)), (exports) {
        final hasMore = exports.length >= event.limit;
        emit(
          ExportHistoryLoaded(
            exports,
            hasMore: hasMore,
            currentPage: event.page,
          ),
        );
      });
    } catch (e) {
      emit(ExportError('Failed to load history: ${e.toString()}'));
    }
  }

  /// Refresh Export History
  Future<void> _onRefreshExportHistory(
    RefreshExportHistory event,
    Emitter<ExportState> emit,
  ) async {
    // Refresh is just loading page 1
    add(const LoadExportHistory(page: 1, limit: 20));
  }

  /// Cancel Export
  Future<void> _onCancelExport(
    CancelExport event,
    Emitter<ExportState> emit,
  ) async {
    emit(const ExportLoading(message: 'Cancelling export...'));

    try {
      final result = await cancelExportUseCase.execute(event.exportId);

      result.fold((failure) => emit(ExportError(failure.message)), (success) {
        if (success) {
          // Stop polling if we're cancelling the current job
          if (_currentPollingExportId == event.exportId) {
            add(const StopStatusPolling());
          }
          emit(ExportCancelled(event.exportId));
        } else {
          emit(const ExportError('Failed to cancel export'));
        }
      });
    } catch (e) {
      emit(ExportError('Failed to cancel export: ${e.toString()}'));
    }
  }

  /// Start Status Polling
  Future<void> _onStartStatusPolling(
    StartStatusPolling event,
    Emitter<ExportState> emit,
  ) async {
    // Stop existing polling
    _stopStatusPolling();

    // Start new polling
    _currentPollingExportId = event.exportId;
    _statusTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      add(CheckExportStatus(event.exportId));
    });
  }

  /// Stop Status Polling
  Future<void> _onStopStatusPolling(
    StopStatusPolling event,
    Emitter<ExportState> emit,
  ) async {
    _stopStatusPolling();
  }

  /// Check Platform Support
  Future<void> _onCheckPlatformSupport(
    CheckPlatformSupport event,
    Emitter<ExportState> emit,
  ) async {
    if (!isPlatformSupported) {
      emit(const ExportPlatformNotSupported());
    }
  }

  /// Load Date Periods
  Future<void> _onLoadDatePeriods(
    LoadDatePeriods event,
    Emitter<ExportState> emit,
  ) async {
    // Create localized date periods data with all periods
    final now = DateTime.now();
    final mockPeriods = [
      {'label': 'Today', 'value': 'today', 'start_date': now.toIso8601String().split('T')[0], 'end_date': now.toIso8601String().split('T')[0]},
      {'label': 'Last 7 days', 'value': 'last_7_days', 'start_date': now.subtract(const Duration(days: 6)).toIso8601String().split('T')[0], 'end_date': now.toIso8601String().split('T')[0]},
      {'label': 'Last 30 days', 'value': 'last_30_days', 'start_date': now.subtract(const Duration(days: 29)).toIso8601String().split('T')[0], 'end_date': now.toIso8601String().split('T')[0]},
      {'label': 'Last 90 days', 'value': 'last_90_days', 'start_date': now.subtract(const Duration(days: 89)).toIso8601String().split('T')[0], 'end_date': now.toIso8601String().split('T')[0]},
      {'label': 'Last 180 days', 'value': 'last_180_days', 'start_date': now.subtract(const Duration(days: 179)).toIso8601String().split('T')[0], 'end_date': now.toIso8601String().split('T')[0]},
      {'label': 'Last 365 days', 'value': 'last_365_days', 'start_date': now.subtract(const Duration(days: 364)).toIso8601String().split('T')[0], 'end_date': now.toIso8601String().split('T')[0]},
      {'label': 'Custom date range', 'value': 'custom'},
    ];

    final mockFields = [
      {'field': 'created_at', 'label': 'Created Date', 'description': 'When asset was created'},
      {'field': 'updated_at', 'label': 'Last Updated', 'description': 'When asset was last modified'},
      {'field': 'last_scan_date', 'label': 'Last Scan', 'description': 'When asset was last scanned'},
    ];

    final mockResponse = {
      'periods': mockPeriods,
      'available_fields': mockFields,
    };

    try {
      final datePeriodsData = DatePeriodsResponse.fromJson(mockResponse);
      // Date periods loaded successfully
      emit(DatePeriodsLoaded(datePeriodsData));
    } catch (e) {
      emit(ExportError('Failed to load date periods: ${e.toString()}'));
    }
  }

  /// Helper method to stop polling
  void _stopStatusPolling() {
    _statusTimer?.cancel();
    _statusTimer = null;
    _currentPollingExportId = null;
  }

  @override
  Future<void> close() {
    _stopStatusPolling();
    return super.close();
  }
}
