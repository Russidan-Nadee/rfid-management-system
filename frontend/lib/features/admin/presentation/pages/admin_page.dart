import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/asset_admin_entity.dart';
import '../../data/datasources/admin_remote_datasource.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../domain/usecases/get_all_assets_usecase.dart';
import '../../domain/usecases/search_assets_usecase.dart';
import '../../domain/usecases/update_asset_usecase.dart';
import '../../domain/usecases/delete_asset_usecase.dart';
import '../../domain/usecases/delete_image_usecase.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../widgets/asset_search_widget.dart';
import '../widgets/asset_list_widget.dart';
import '../widgets/role_management_tab.dart';
import '../../../../l10n/features/admin/admin_localizations.dart';
import 'admin_all_reports_page.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_colors.dart';

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
          deleteImageUsecase: DeleteImageUsecase(repository),
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

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.menuTitle,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkText
                  : AppColors.primary,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkText
              : AppColors.primary,
          elevation: 0,
          scrolledUnderElevation: 1,
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.inventory_2_outlined),
                text: 'Asset Management',
              ),
              Tab(icon: Icon(Icons.assignment_outlined), text: 'All Reports'),
              Tab(icon: Icon(Icons.people_outlined), text: 'Role Management'),
            ],
          ),
          automaticallyImplyLeading: false,
        ),
        body: TabBarView(
          children: [
            // Asset Management Tab
            AssetManagementTab(),
            // All Reports Tab
            AdminAllReportsPage(),
            // Role Management Tab
            RoleManagementTab(),
          ],
        ),
      ),
    );
  }
}

class AssetManagementTab extends StatefulWidget {
  const AssetManagementTab({super.key});

  @override
  State<AssetManagementTab> createState() => _AssetManagementTabState();
}

class _AssetManagementTabState extends State<AssetManagementTab> {
  bool _isSearchExpanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AdminLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1200;
        final isTablet = constraints.maxWidth >= 768;
        final padding = isDesktop ? 24.0 : (isTablet ? 16.0 : 12.0);

        return Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Collapsible search section
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    // Search toggle header
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isSearchExpanded = !_isSearchExpanded;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.search),
                            const SizedBox(width: 8),
                            Text(
                              l10n.searchTitle,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            AnimatedRotation(
                              turns: _isSearchExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: const Icon(Icons.expand_more),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Collapsible content
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: AssetSearchWidget(
                          constraints: constraints,
                          onSearch:
                              ({searchTerm, status, plantCode, locationCode}) {
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
                      ),
                      crossFadeState: _isSearchExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 200),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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
                              context.read<AdminBloc>().add(const ClearError());
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
                    } else if (state is ImageDeleted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Image deleted successfully'),
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
                        state is AssetDeleted ||
                        state is ImageDeleting ||
                        state is ImageDeleted) {
                      List<AssetAdminEntity> assets = [];

                      if (state is AdminLoaded) {
                        assets = state.assets;
                      } else if (state is AssetUpdating) {
                        assets = state.assets;
                      } else if (state is AssetDeleting) {
                        assets = state.assets;
                      } else if (state is AssetUpdated) {
                        assets = state.assets;
                      } else if (state is AssetDeleted) {
                        assets = state.assets;
                      } else if (state is ImageDeleting) {
                        assets = state.assets;
                      } else if (state is ImageDeleted) {
                        assets = state.assets;
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusXS,
                              ),
                            ),
                            child: Padding(
                              padding: AppSpacing.paddingLG,
                              child: Row(
                                children: [
                                  const Icon(Icons.inventory),
                                  AppSpacing.horizontalSpaceSM,
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
                          AppSpacing.verticalSpaceLG,
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: AppSpacing.paddingLG,
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
    );
  }
}

