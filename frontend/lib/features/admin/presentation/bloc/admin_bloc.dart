import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_all_assets_usecase.dart';
import '../../domain/usecases/search_assets_usecase.dart';
import '../../domain/usecases/update_asset_usecase.dart';
import '../../domain/usecases/delete_asset_usecase.dart';
import '../../domain/usecases/delete_image_usecase.dart';
import '../../domain/entities/asset_admin_entity.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final GetAllAssetsUsecase getAllAssetsUsecase;
  final SearchAssetsUsecase searchAssetsUsecase;
  final UpdateAssetUsecase updateAssetUsecase;
  final DeleteAssetUsecase deleteAssetUsecase;
  final DeleteImageUsecase deleteImageUsecase;

  AdminBloc({
    required this.getAllAssetsUsecase,
    required this.searchAssetsUsecase,
    required this.updateAssetUsecase,
    required this.deleteAssetUsecase,
    required this.deleteImageUsecase,
  }) : super(const AdminInitial()) {
    on<LoadAllAssets>(_onLoadAllAssets);
    on<SearchAssets>(_onSearchAssets);
    on<UpdateAsset>(_onUpdateAsset);
    on<DeleteAsset>(_onDeleteAsset);
    on<DeleteImage>(_onDeleteImage);
    on<ClearError>(_onClearError);
  }

  Future<void> _onLoadAllAssets(
    LoadAllAssets event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final assets = await getAllAssetsUsecase();
      emit(AdminLoaded(assets));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onSearchAssets(
    SearchAssets event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final assets = await searchAssetsUsecase(
        searchTerm: event.searchTerm,
        status: event.status,
        plantCode: event.plantCode,
        locationCode: event.locationCode,
      );
      emit(AdminLoaded(assets));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onUpdateAsset(
    UpdateAsset event,
    Emitter<AdminState> emit,
  ) async {
    List<AssetAdminEntity> currentAssets = [];
    
    if (state is AdminLoaded) {
      currentAssets = (state as AdminLoaded).assets;
    } else if (state is AssetUpdated) {
      currentAssets = (state as AssetUpdated).assets;
    }
    
    if (currentAssets.isNotEmpty) {
      emit(AssetUpdating(currentAssets));
      
      try {
        final updatedAsset = await updateAssetUsecase(event.request);
        final updatedAssets = currentAssets.map((asset) {
          return asset.assetNo == updatedAsset.assetNo ? updatedAsset : asset;
        }).toList();
        
        emit(AssetUpdated(updatedAssets, updatedAsset));
      } catch (e) {
        emit(AdminError(e.toString()));
      }
    }
  }

  Future<void> _onDeleteAsset(
    DeleteAsset event,
    Emitter<AdminState> emit,
  ) async {
    if (state is AdminLoaded) {
      final currentAssets = (state as AdminLoaded).assets;
      emit(AssetDeleting(currentAssets, event.assetNo));
      
      try {
        await deleteAssetUsecase(event.assetNo);
        final updatedAssets = currentAssets
            .where((asset) => asset.assetNo != event.assetNo)
            .toList();
        
        emit(AssetDeleted(updatedAssets));
      } catch (e) {
        emit(AdminError(e.toString()));
      }
    }
  }

  Future<void> _onDeleteImage(
    DeleteImage event,
    Emitter<AdminState> emit,
  ) async {
    if (state is AdminLoaded) {
      final currentAssets = (state as AdminLoaded).assets;
      emit(ImageDeleting(currentAssets, event.imageId));
      
      try {
        await deleteImageUsecase(event.imageId);
        emit(ImageDeleted(currentAssets, event.imageId));
      } catch (e) {
        emit(AdminError(e.toString()));
      }
    }
  }

  void _onClearError(
    ClearError event,
    Emitter<AdminState> emit,
  ) {
    emit(const AdminInitial());
  }
}