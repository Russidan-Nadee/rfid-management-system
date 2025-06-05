// Path: frontend/lib/features/scan/presentation/bloc/scan_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/scanned_item_entity.dart';
import '../../domain/repositories/scan_repository.dart';
import '../../domain/usecases/get_asset_details_usecase.dart';
import '../../domain/usecases/update_asset_status_usecase.dart';
import '../../../auth/domain/usecases/get_current_user_usecase.dart';
import 'scan_event.dart';
import 'scan_state.dart';

class ScanBloc extends Bloc<ScanEvent, ScanState> {
  final ScanRepository scanRepository;
  final GetAssetDetailsUseCase getAssetDetailsUseCase;
  final UpdateAssetStatusUseCase updateAssetStatusUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  ScanBloc({
    required this.scanRepository,
    required this.getAssetDetailsUseCase,
    required this.updateAssetStatusUseCase,
    required this.getCurrentUserUseCase,
  }) : super(const ScanInitial()) {
    on<StartScan>(_onStartScan);
    on<ClearScanResults>(_onClearScanResults);
    on<RefreshScanResults>(_onRefreshScanResults);
    on<UpdateAssetStatus>(_onUpdateAssetStatus);
    on<MarkAssetChecked>(_onMarkAssetChecked);
    on<LogAssetScanned>(_onLogAssetScanned);
  }

  Future<void> _onStartScan(StartScan event, Emitter<ScanState> emit) async {
    emit(const ScanLoading());

    try {
      // Generate mock asset numbers
      final assetNumbers = await scanRepository.generateMockAssetNumbers();

      // Get details for each asset
      final List<ScannedItemEntity> scannedItems = [];

      for (final assetNo in assetNumbers) {
        try {
          final item = await getAssetDetailsUseCase.execute(assetNo);
          scannedItems.add(item);

          // เพิ่มส่วนนี้ - Log การแสกน
          try {
            final userId = await getCurrentUserUseCase.execute();
            add(LogAssetScanned(assetNo: assetNo, scannedBy: userId));
          } catch (e) {
            print('Failed to get current user for logging: $e');
          }
        } catch (e) {
          // คืน existing error handling เดิม
          if (e.toString().contains('Asset not found') ||
              e.toString().contains('404') ||
              e.toString().contains('not found')) {
            scannedItems.add(ScannedItemEntity.unknown(assetNo));
          } else {
            print('Unexpected error for asset $assetNo: $e');
            scannedItems.add(ScannedItemEntity.unknown(assetNo));
          }
        }
      }

      emit(ScanSuccess(scannedItems: scannedItems));
    } catch (e) {
      emit(ScanError(message: 'Scan failed: ${e.toString()}'));
    }
  }

  Future<void> _onClearScanResults(
    ClearScanResults event,
    Emitter<ScanState> emit,
  ) async {
    emit(const ScanInitial());
  }

  Future<void> _onRefreshScanResults(
    RefreshScanResults event,
    Emitter<ScanState> emit,
  ) async {
    if (state is ScanSuccess) {
      add(const StartScan());
    }
  }

  Future<void> _onMarkAssetChecked(
    MarkAssetChecked event,
    Emitter<ScanState> emit,
  ) async {
    try {
      final userId = await getCurrentUserUseCase.execute();
      add(UpdateAssetStatus(assetNo: event.assetNo, updatedBy: userId));
    } catch (e) {
      emit(
        AssetStatusUpdateError(
          message: 'Failed to get current user: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onUpdateAssetStatus(
    UpdateAssetStatus event,
    Emitter<ScanState> emit,
  ) async {
    emit(AssetStatusUpdating(assetNo: event.assetNo));

    try {
      final updatedAsset = await updateAssetStatusUseCase.markAsChecked(
        event.assetNo,
        event.updatedBy,
      );

      // Always update the scan results if they exist
      if (state is ScanSuccess) {
        final currentState = state as ScanSuccess;
        final updatedItems = currentState.scannedItems.map((item) {
          if (item.assetNo == event.assetNo) {
            return updatedAsset;
          }
          return item;
        }).toList();

        emit(ScanSuccess(scannedItems: updatedItems));
      }

      // Always emit AssetStatusUpdated for AssetDetailPage
      emit(AssetStatusUpdated(updatedAsset: updatedAsset));
    } catch (e) {
      emit(AssetStatusUpdateError(message: e.toString()));
    }
  }

  Future<void> _onLogAssetScanned(
    LogAssetScanned event,
    Emitter<ScanState> emit,
  ) async {
    try {
      await scanRepository.logAssetScan(event.assetNo, event.scannedBy);
    } catch (e) {
      // Silent fail - ไม่ emit error state เพื่อไม่กระทบ scan process
      print('Failed to log asset scan: $e');
    }
  }
}
