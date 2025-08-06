// Path: frontend/lib/features/scan/presentation/bloc/scan_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/scanned_item_entity.dart';
import '../../domain/entities/asset_image_entity.dart';
import '../../domain/repositories/scan_repository.dart';
import '../../domain/usecases/get_asset_details_usecase.dart';
import '../../domain/usecases/update_asset_status_usecase.dart';
import '../../domain/usecases/get_assets_by_location_usecase.dart';
import '../../domain/usecases/get_asset_images_usecase.dart';
import '../../../auth/domain/usecases/get_current_user_usecase.dart';
import 'scan_event.dart';
import 'scan_state.dart';

class ScanBloc extends Bloc<ScanEvent, ScanState> {
  final ScanRepository scanRepository;
  final GetAssetDetailsUseCase getAssetDetailsUseCase;
  final UpdateAssetStatusUseCase updateAssetStatusUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final GetAssetsByLocationUseCase getAssetsByLocationUseCase;
  final GetAssetImagesUseCase getAssetImagesUseCase;

  // Keep track of last valid ScanSuccess state for status updates
  ScanSuccess? _lastScanSuccess;

  ScanBloc({
    required this.scanRepository,
    required this.getAssetDetailsUseCase,
    required this.updateAssetStatusUseCase,
    required this.getCurrentUserUseCase,
    required this.getAssetsByLocationUseCase,
    required this.getAssetImagesUseCase,
  }) : super(const ScanInitial()) {
    on<StartScan>(_onStartScan);
    on<LocationSelected>(_onLocationSelected);
    on<ClearScanResults>(_onClearScanResults);
    on<RefreshScanResults>(_onRefreshScanResults);
    on<UpdateAssetStatus>(_onUpdateAssetStatus);
    on<MarkAssetChecked>(_onMarkAssetChecked);
    on<LogAssetScanned>(_onLogAssetScanned);
    on<AssetCreatedFromUnknown>(_onAssetCreatedFromUnknown);
    on<FilterChanged>(_onFilterChanged);
    on<LocationFilterChanged>(_onLocationFilterChanged);
    on<LoadExpectedCounts>(_onLoadExpectedCounts);
    on<LoadAssetImages>(_onLoadAssetImages);
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
          // แก้ส่วนนี้ - ส่ง cached location data ไปใน unknown item
          if (e.toString().contains('Asset not found') ||
              e.toString().contains('404') ||
              e.toString().contains('not found')) {
            final unknownItem = ScannedItemEntity(
              assetNo: assetNo,
              description: 'Unknown Item',
              status: 'Unknown',
              isUnknown: true,
            );

            scannedItems.add(unknownItem);
          } else {
            print('Unexpected error for asset $assetNo: $e');
            final unknownItem = ScannedItemEntity(
              assetNo: assetNo,
              description: 'Unknown Item',
              status: 'Unknown',
              isUnknown: true,
            );

            scannedItems.add(unknownItem);
          }
        }
      }

      // หาก locations ที่ unique
      final uniqueLocations = scannedItems
          .where(
            (item) =>
                item.locationName != null && item.locationName!.isNotEmpty,
          )
          .map((item) => item.locationName!)
          .toSet()
          .toList();

      uniqueLocations.sort();

      // Logic ใหม่: ถ้ามี location เดียว -> auto select
      if (uniqueLocations.length <= 1) {
        final selectedLocation = uniqueLocations.isNotEmpty
            ? uniqueLocations.first
            : 'Unknown Location';

        final scanSuccess = ScanSuccess(
          scannedItems: scannedItems,
          selectedFilter: 'All',
          selectedLocation: 'All Locations',
          currentLocation:
              selectedLocation, // บันทึก location ที่ auto select
        );
        _lastScanSuccess = scanSuccess; // Store reference
        emit(scanSuccess);
      } else {
        // ถ้ามีหลาย locations -> แสดง selection
        emit(
          ScanLocationSelection(
            scannedItems: scannedItems,
            availableLocations: uniqueLocations,
          ),
        );
      }
    } catch (e) {
      emit(ScanError(message: 'Scan failed: ${e.toString()}'));
    }
  }

  // Handler ใหม่สำหรับเลือก location
  Future<void> _onLocationSelected(
    LocationSelected event,
    Emitter<ScanState> emit,
  ) async {
    if (state is ScanLocationSelection) {
      final currentState = state as ScanLocationSelection;

      final scanSuccess = ScanSuccess(
        scannedItems: currentState.scannedItems,
        selectedFilter: 'All',
        selectedLocation: 'All Locations',
        currentLocation:
            event.selectedLocation, // บันทึก location ที่ user เลือก
      );
      _lastScanSuccess = scanSuccess; // Store reference
      emit(scanSuccess);
    }
  }

  Future<void> _onClearScanResults(
    ClearScanResults event,
    Emitter<ScanState> emit,
  ) async {
    _lastScanSuccess = null; // Clear reference
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
    print('DEBUG: MarkAssetChecked event received for ${event.assetNo}');

    try {
      final userId = await getCurrentUserUseCase.execute();
      print('DEBUG: Got current user: $userId');

      add(UpdateAssetStatus(assetNo: event.assetNo, updatedBy: userId));
      print('DEBUG: UpdateAssetStatus event added');
    } catch (e) {
      print('DEBUG: Error getting current user: $e');
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
    print('DEBUG: UpdateAssetStatus called for ${event.assetNo}');
    print('DEBUG: Current state: ${state.runtimeType}');

    // เก็บ previous scan results ไว้ก่อน
    List<ScannedItemEntity>? previousScannedItems;
    String currentFilter = 'All';
    String currentLocation = 'All Locations';
    String? selectedCurrentLocation;
    Map<String, int> currentExpectedCounts = {};

    // Use current state if it's ScanSuccess, otherwise use last saved state
    if (state is ScanSuccess) {
      final currentState = state as ScanSuccess;
      previousScannedItems = currentState.scannedItems;
      currentFilter = currentState.selectedFilter;
      currentLocation = currentState.selectedLocation;
      selectedCurrentLocation = currentState.currentLocation;
      currentExpectedCounts = currentState.expectedCounts;
      _lastScanSuccess = currentState; // Update reference

      print('DEBUG: Previous state captured from current - ${previousScannedItems.length} items');
    } else if (_lastScanSuccess != null) {
      // Fallback to last known ScanSuccess state
      previousScannedItems = _lastScanSuccess!.scannedItems;
      currentFilter = _lastScanSuccess!.selectedFilter;
      currentLocation = _lastScanSuccess!.selectedLocation;
      selectedCurrentLocation = _lastScanSuccess!.currentLocation;
      currentExpectedCounts = _lastScanSuccess!.expectedCounts;

      print('DEBUG: Previous state captured from cached - ${previousScannedItems.length} items');
    }

    print('DEBUG: Emitting AssetStatusUpdating');
    emit(AssetStatusUpdating(assetNo: event.assetNo));

    try {
      print('DEBUG: Calling API to mark asset as checked');
      final updatedAsset = await updateAssetStatusUseCase.markAsChecked(
        event.assetNo,
        event.updatedBy,
      );

      print('DEBUG: Asset updated successfully');
      print('DEBUG: Updated asset status: ${updatedAsset.status}');

      if (previousScannedItems != null) {
        print('DEBUG: Updating scanned items list');

        final updatedItems = previousScannedItems.map((item) {
          if (item.assetNo == event.assetNo) {
            print('DEBUG: Updated item ${item.assetNo} from ${item.status} to ${updatedAsset.status}');
            return updatedAsset;
          }
          return item;
        }).toList();

        print('DEBUG: Emitting new ScanSuccess with updated items');
        final newScanSuccess = ScanSuccess(
          scannedItems: updatedItems,
          selectedFilter: currentFilter,
          selectedLocation: currentLocation,
          currentLocation: selectedCurrentLocation,
          expectedCounts: currentExpectedCounts,
        );
        _lastScanSuccess = newScanSuccess; // Update reference
        emit(newScanSuccess);
        print('DEBUG: New ScanSuccess state emitted');
      } else {
        print('DEBUG: No previous scanned items to update');
      }
    } catch (e) {
      print('DEBUG: Error updating asset: $e');

      // ถ้า error ให้กลับไป previous state
      if (previousScannedItems != null) {
        print('🔍 ScanBloc: Restoring previous state due to error');
        final restoredScanSuccess = ScanSuccess(
          scannedItems: previousScannedItems,
          selectedFilter: currentFilter,
          selectedLocation: currentLocation,
          currentLocation: selectedCurrentLocation,
          expectedCounts: currentExpectedCounts,
        );
        _lastScanSuccess = restoredScanSuccess; // Update reference
        emit(restoredScanSuccess);
      }

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
    }
  }

  Future<void> _onAssetCreatedFromUnknown(
    AssetCreatedFromUnknown event,
    Emitter<ScanState> emit,
  ) async {
    print('🔍 ScanBloc: _onAssetCreatedFromUnknown called');
    print('🔍 ScanBloc: Created asset details:');
    print('🔍 ScanBloc: - Asset No: ${event.createdAsset.assetNo}');
    print('🔍 ScanBloc: - Description: ${event.createdAsset.description}');
    print('🔍 ScanBloc: - Status: ${event.createdAsset.status}');
    print('🔍 ScanBloc: - Is Unknown: ${event.createdAsset.isUnknown}');
    print('🔍 ScanBloc: - Original EPC Code: ${event.originalEpcCode}');
    print('🔍 ScanBloc: Current state: ${state.runtimeType}');

    // Use current state if it's ScanSuccess, otherwise use last saved state
    ScanSuccess? currentScanSuccess;
    
    if (state is ScanSuccess) {
      currentScanSuccess = state as ScanSuccess;
      _lastScanSuccess = currentScanSuccess; // Update reference
      print(
        '🔍 ScanBloc: Using current ScanSuccess with ${currentScanSuccess.scannedItems.length} items',
      );
    } else if (_lastScanSuccess != null) {
      currentScanSuccess = _lastScanSuccess;
      print(
        '🔍 ScanBloc: Using cached ScanSuccess with ${currentScanSuccess!.scannedItems.length} items',
      );
    }

    if (currentScanSuccess != null) {
      // หา unknown item โดยใช้ original EPC code
      bool itemFound = false;
      final updatedItems = currentScanSuccess.scannedItems.map((item) {
        // Match by original EPC code - for unknown items, assetNo is the EPC code
        if (item.isUnknown && item.assetNo == event.originalEpcCode) {
          print(
            '🔍 ScanBloc: Found unknown item ${item.assetNo}, replacing with created asset',
          );
          itemFound = true;
          // Return the created asset - it already has the correct new assetNo and details
          return event.createdAsset;
        }
        return item; // เก็บ item เดิม
      }).toList();

      if (itemFound) {
        print(
          '🔍 ScanBloc: ✅ Item replaced successfully, emitting new ScanSuccess',
        );

        // Emit state ใหม่พร้อม updated list และ filter เดิม
        final updatedScanSuccess = ScanSuccess(
          scannedItems: updatedItems,
          selectedFilter: currentScanSuccess.selectedFilter,
          selectedLocation: currentScanSuccess.selectedLocation,
          currentLocation: currentScanSuccess.currentLocation,
          expectedCounts: currentScanSuccess.expectedCounts,
        );
        _lastScanSuccess = updatedScanSuccess; // Update reference
        emit(updatedScanSuccess);

        print(
          '🔍 ScanBloc: ✅ New ScanSuccess state emitted with replaced item',
        );
      } else {
        print('🔍 ScanBloc: ⚠️ Unknown item not found in scanned items list');

        // Debug: แสดง asset numbers ทั้งหมดใน list
        print('🔍 ScanBloc: Current asset numbers in list:');
        for (var item in currentScanSuccess.scannedItems) {
          print(
            '🔍 ScanBloc: - ${item.assetNo} (isUnknown: ${item.isUnknown})',
          );
        }
      }
    } else {
      print('🔍 ScanBloc: ⚠️ No valid ScanSuccess state available, cannot update');
    }
  }

  // Status Filter handler
  void _onFilterChanged(FilterChanged event, Emitter<ScanState> emit) {
    if (state is ScanSuccess) {
      final currentState = state as ScanSuccess;
      // อัพเดต status filter ใน state เดิม - ไม่ใช่ scan ใหม่
      emit(
        ScanSuccessFiltered(
          scannedItems: currentState.scannedItems,
          selectedFilter: event.filter,
          selectedLocation: currentState.selectedLocation,
          currentLocation: currentState.currentLocation,
          expectedCounts: currentState.expectedCounts,
        ),
      );
    }
  }

  // Location Filter handler
  void _onLocationFilterChanged(
    LocationFilterChanged event,
    Emitter<ScanState> emit,
  ) {
    if (state is ScanSuccess) {
      final currentState = state as ScanSuccess;
      // อัพเดต location filter และ reset status filter เป็น 'All' - ไม่ใช่ scan ใหม่
      emit(
        ScanSuccessFiltered(
          scannedItems: currentState.scannedItems,
          selectedLocation: event.location,
          selectedFilter: 'All', // Reset status filter เมื่อเปลี่ยน location
          currentLocation: currentState.currentLocation,
          expectedCounts: currentState.expectedCounts,
        ),
      );
    }
  }

  // Handler สำหรับ LoadExpectedCounts
  Future<void> _onLoadExpectedCounts(
    LoadExpectedCounts event,
    Emitter<ScanState> emit,
  ) async {
    if (state is ScanSuccess) {
      final currentState = state as ScanSuccess;

      try {
        print(
          'ScanBloc: Loading expected counts for locations: ${event.locationCodes}',
        );

        final expectedCounts = await getAssetsByLocationUseCase
            .getMultipleLocationCounts(event.locationCodes);

        print('ScanBloc: Expected counts loaded: $expectedCounts');

        final updatedState = currentState.copyWith(expectedCounts: expectedCounts);
        _lastScanSuccess = updatedState; // Update reference
        emit(updatedState);
      } catch (e) {
        print('ScanBloc: Error loading expected counts: $e');
        // ไม่ emit error state เพื่อไม่กระทบ UI หลัก
        // แค่ log error และเก็บ state เดิม
      }
    }
  }

  // ⭐ Handler ใหม่สำหรับ LoadAssetImages
  Future<void> _onLoadAssetImages(
    LoadAssetImages event,
    Emitter<ScanState> emit,
  ) async {
    emit(AssetImagesLoading(assetNo: event.assetNo));

    try {
      final images = await getAssetImagesUseCase.execute(event.assetNo);
      emit(AssetImagesLoaded(assetNo: event.assetNo, images: images));
    } catch (error) {
      print('ScanBloc: Error loading asset images: $error');
      emit(AssetImagesError(assetNo: event.assetNo, message: error.toString()));
    }
  }
}
