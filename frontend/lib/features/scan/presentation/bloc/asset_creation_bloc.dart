// Path: lib/features/scan/presentation/bloc/asset_creation_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/master_data_entity.dart';
import '../../domain/entities/scanned_item_entity.dart';
import '../../domain/usecases/create_asset_usecase.dart';
import '../../domain/usecases/get_master_data_usecase.dart';
import '../../../auth/domain/usecases/get_current_user_usecase.dart';

// Events
abstract class AssetCreationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMasterData extends AssetCreationEvent {}

class PlantSelected extends AssetCreationEvent {
  final String plantCode;
  PlantSelected(this.plantCode);
  @override
  List<Object> get props => [plantCode];
}

class DepartmentSelected extends AssetCreationEvent {
  final String deptCode;
  DepartmentSelected(this.deptCode);
  @override
  List<Object> get props => [deptCode];
}

class CreateAssetSubmitted extends AssetCreationEvent {
  final CreateAssetRequest request;
  CreateAssetSubmitted(this.request);
  @override
  List<Object> get props => [request];
}

// States
abstract class AssetCreationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AssetCreationInitial extends AssetCreationState {}

class MasterDataLoading extends AssetCreationState {}

class MasterDataLoaded extends AssetCreationState {
  final List<PlantEntity> plants;
  final List<LocationEntity> locations;
  final List<UnitEntity> units;
  final List<DepartmentEntity> departments;
  final List<CategoryEntity> categories;
  final List<BrandEntity> brands;

  MasterDataLoaded({
    required this.plants,
    required this.locations,
    required this.units,
    required this.departments,
    required this.categories,
    required this.brands,
  });

  @override
  List<Object> get props => [
    plants,
    locations,
    units,
    departments,
    categories,
    brands,
  ];
}

class AssetCreating extends AssetCreationState {}

class AssetCreated extends AssetCreationState {
  final ScannedItemEntity asset;
  AssetCreated(this.asset);
  @override
  List<Object> get props => [asset];
}

class AssetCreationError extends AssetCreationState {
  final String message;
  AssetCreationError(this.message);
  @override
  List<Object> get props => [message];
}

// BLoC
class AssetCreationBloc extends Bloc<AssetCreationEvent, AssetCreationState> {
  final CreateAssetUseCase createAssetUseCase;
  final GetMasterDataUseCase getMasterDataUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AssetCreationBloc({
    required this.createAssetUseCase,
    required this.getMasterDataUseCase,
    required this.getCurrentUserUseCase,
  }) : super(AssetCreationInitial()) {
    on<LoadMasterData>(_onLoadMasterData);
    on<PlantSelected>(_onPlantSelected);
    on<DepartmentSelected>(_onDepartmentSelected);
    on<CreateAssetSubmitted>(_onCreateAssetSubmitted);
  }

  Future<void> _onLoadMasterData(
    LoadMasterData event,
    Emitter<AssetCreationState> emit,
  ) async {
    emit(MasterDataLoading());
    try {
      final plants = await getMasterDataUseCase.getPlants();
      final units = await getMasterDataUseCase.getUnits();
      final departments = await getMasterDataUseCase.getDepartments();
      final categories = await getMasterDataUseCase.getCategories();
      final brands = await getMasterDataUseCase.getBrands();

      emit(
        MasterDataLoaded(
          plants: plants,
          locations: const [],
          units: units,
          departments: departments,
          categories: categories,
          brands: brands,
        ),
      );
    } catch (e) {
      emit(AssetCreationError('Failed to load master data: $e'));
    }
  }

  Future<void> _onPlantSelected(
    PlantSelected event,
    Emitter<AssetCreationState> emit,
  ) async {
    if (state is MasterDataLoaded) {
      final currentState = state as MasterDataLoaded;
      try {
        final locations = await getMasterDataUseCase.getLocationsByPlant(
          event.plantCode,
        );
        emit(
          MasterDataLoaded(
            plants: currentState.plants,
            locations: locations,
            units: currentState.units,
            departments: currentState.departments,
            categories: currentState.categories,
            brands: currentState.brands,
          ),
        );
      } catch (e) {
        emit(AssetCreationError('Failed to load locations: $e'));
      }
    }
  }

  Future<void> _onDepartmentSelected(
    DepartmentSelected event,
    Emitter<AssetCreationState> emit,
  ) async {
    // Handle department selection if needed
    // For now, just maintain current state
    if (state is MasterDataLoaded) {
      final currentState = state as MasterDataLoaded;
      emit(
        MasterDataLoaded(
          plants: currentState.plants,
          locations: currentState.locations,
          units: currentState.units,
          departments: currentState.departments,
          categories: currentState.categories,
          brands: currentState.brands,
        ),
      );
    }
  }

  Future<void> _onCreateAssetSubmitted(
    CreateAssetSubmitted event,
    Emitter<AssetCreationState> emit,
  ) async {
    emit(AssetCreating());
    try {
      final asset = await createAssetUseCase.execute(event.request);
      emit(AssetCreated(asset));
    } catch (e) {
      emit(AssetCreationError('Failed to create asset: $e'));
    }
  }
}
