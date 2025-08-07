import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/asset_admin_entity.dart';
import '../../data/datasources/admin_remote_datasource.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../domain/usecases/get_all_assets_usecase.dart';
import '../../domain/usecases/search_assets_usecase.dart';
import '../../domain/usecases/update_asset_usecase.dart';
import '../../domain/usecases/delete_asset_usecase.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../widgets/asset_search_widget.dart';
import '../widgets/asset_list_widget.dart';
import '../../../../l10n/features/admin/admin_localizations.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final datasource = AdminRemoteDatasourceImpl();
        final repository = AdminRepositoryImpl(remoteDataSource: datasource);

        return AdminBloc(
          getAllAssetsUsecase: GetAllAssetsUsecase(repository),
          searchAssetsUsecase: SearchAssetsUsecase(repository),
          updateAssetUsecase: UpdateAssetUsecase(repository),
          deleteAssetUsecase: DeleteAssetUsecase(repository),
        )..add(const LoadAllAssets());
      },
      child: const AdminPageView(),
    );
  }
}

class AdminPageView extends StatelessWidget {
  const AdminPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AdminLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.menuTitle),
        automaticallyImplyLeading: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1200;
          final isTablet = constraints.maxWidth >= 768;
          final padding = isDesktop ? 24.0 : (isTablet ? 16.0 : 12.0);

          return Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AssetSearchWidget(
                  constraints: constraints,
                  onSearch: ({searchTerm, status, plantCode, locationCode}) {
                    context.read<AdminBloc>().add(
                      SearchAssets(
                        searchTerm: searchTerm,
                        status: status,
                        plantCode: plantCode,
                        locationCode: locationCode,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: BlocConsumer<AdminBloc, AdminState>(
                    listener: (context, state) {
                      if (state is AdminError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.red,
                            action: SnackBarAction(
                              label: l10n.dismiss,
                              textColor: Colors.white,
                              onPressed: () {
                                context.read<AdminBloc>().add(
                                  const ClearError(),
                                );
                              },
                            ),
                          ),
                        );
                      } else if (state is AssetUpdated) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.assetUpdatedSuccess),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else if (state is AssetDeleted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.assetDeactivatedSuccess),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is AdminLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is AdminLoaded ||
                          state is AssetUpdating ||
                          state is AssetDeleting ||
                          state is AssetUpdated ||
                          state is AssetDeleted) {
                        List<AssetAdminEntity> assets = [];

                        if (state is AdminLoaded)
                          assets = state.assets;
                        else if (state is AssetUpdating)
                          assets = state.assets;
                        else if (state is AssetDeleting)
                          assets = state.assets;
                        else if (state is AssetUpdated)
                          assets = state.assets;
                        else if (state is AssetDeleted)
                          assets = state.assets;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.inventory),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${l10n.totalAssets}: ${assets.length}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: AssetListWidget(
                                    assets: assets,
                                    onUpdate: (request) {
                                      context.read<AdminBloc>().add(
                                        UpdateAsset(request),
                                      );
                                    },
                                    onDelete: (assetNo) {
                                      context.read<AdminBloc>().add(
                                        DeleteAsset(assetNo),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      } else if (state is AdminError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '${l10n.errorGeneric}: ${state.message}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.red,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<AdminBloc>().add(
                                    const LoadAllAssets(),
                                  );
                                },
                                child: Text(l10n.retry),
                              ),
                            ],
                          ),
                        );
                      }

                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
