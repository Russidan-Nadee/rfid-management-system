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
import '../../../../l10n/features/admin/admin_localizations.dart';
import '../../../reports/presentation/pages/all_reports_page.dart';
import '../../../../app/theme/app_spacing.dart';

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
          title: Text(l10n.menuTitle),
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
            AllReportsPage(),
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
                            const Text(
                              'Search & Filters',
                              style: TextStyle(
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

class RoleManagementTab extends StatefulWidget {
  const RoleManagementTab({super.key});

  @override
  State<RoleManagementTab> createState() => _RoleManagementTabState();
}

class _RoleManagementTabState extends State<RoleManagementTab> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedRoleFilter = 'all';
  String selectedStatusFilter = 'all';
  bool _isSearchExpanded = false;

  final List<String> roles = ['admin', 'manager', 'staff', 'viewer'];
  final List<String> statusOptions = ['all', 'active', 'inactive'];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => isLoading = true);

    try {
      final datasource = AdminRemoteDatasourceImpl();
      final response = await datasource.getAllUsers();

      users = response
          .map(
            (user) => {
              'user_id': user['user_id'],
              'employee_id': user['employee_id'],
              'full_name': user['full_name'],
              'department': user['department'],
              'position': user['position'],
              'company_role': user['company_role'],
              'email': user['email'],
              'role': user['role'],
              'is_active': user['is_active'],
              'last_login': user['last_login'] != null
                  ? DateTime.parse(user['last_login'])
                  : null,
              'created_at': user['created_at'] != null
                  ? DateTime.parse(user['created_at'])
                  : null,
            },
          )
          .toList();

      _applyFilters();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load users: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }

      // Fall back to empty list on error
      users = [];
      _applyFilters();
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _applyFilters() {
    filteredUsers = users.where((user) {
      final matchesSearch =
          searchQuery.isEmpty ||
          user['full_name'].toLowerCase().contains(searchQuery.toLowerCase()) ||
          user['employee_id'].toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ||
          user['email'].toLowerCase().contains(searchQuery.toLowerCase());

      final matchesRole =
          selectedRoleFilter == 'all' || user['role'] == selectedRoleFilter;

      final matchesStatus =
          selectedStatusFilter == 'all' ||
          (selectedStatusFilter == 'active' && user['is_active']) ||
          (selectedStatusFilter == 'inactive' && !user['is_active']);

      return matchesSearch && matchesRole && matchesStatus;
    }).toList();
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value;
      _applyFilters();
    });
  }

  Future<void> _updateUserRole(String userId, String newRole) async {
    try {
      final datasource = AdminRemoteDatasourceImpl();
      await datasource.updateUserRole(userId, newRole);

      // Update local state
      setState(() {
        final userIndex = users.indexWhere((u) => u['user_id'] == userId);
        if (userIndex != -1) {
          users[userIndex]['role'] = newRole;
          _applyFilters();
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User role updated to $newRole'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update user role: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleUserStatus(String userId, bool isActive) async {
    try {
      final datasource = AdminRemoteDatasourceImpl();
      await datasource.updateUserStatus(userId, isActive);

      // Update local state
      setState(() {
        final userIndex = users.indexWhere((u) => u['user_id'] == userId);
        if (userIndex != -1) {
          users[userIndex]['is_active'] = isActive;
          _applyFilters();
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User ${isActive ? 'activated' : 'deactivated'}'),
            backgroundColor: isActive ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update user status: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              // Header card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: AppSpacing.paddingLG,
                  child: Row(
                    children: [
                      const Icon(Icons.people),
                      AppSpacing.horizontalSpaceSM,
                      const Text(
                        'Role Management',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Total Users: ${filteredUsers.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacing.verticalSpaceSM,

              // Collapsible search and filters
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
                            const Text(
                              'Search & Filters',
                              style: TextStyle(
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
                        child: Column(
                          children: [
                            // Search and filters row
                            if (isDesktop) ...[
                              Row(
                                children: [
                                  // Search field
                                  Expanded(
                                    flex: 2,
                                    child: TextField(
                                      decoration: const InputDecoration(
                                        hintText:
                                            'Search by name, employee ID, or email...',
                                        prefixIcon: Icon(Icons.search),
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                      onChanged: _onSearchChanged,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Role filter
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: selectedRoleFilter,
                                      decoration: const InputDecoration(
                                        labelText: 'Filter by Role',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                      items: [
                                        const DropdownMenuItem(
                                          value: 'all',
                                          child: Text('All Roles'),
                                        ),
                                        ...roles.map(
                                          (role) => DropdownMenuItem(
                                            value: role,
                                            child: Text(role.toUpperCase()),
                                          ),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          selectedRoleFilter = value!;
                                          _applyFilters();
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Status filter
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: selectedStatusFilter,
                                      decoration: const InputDecoration(
                                        labelText: 'Filter by Status',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                      items: statusOptions
                                          .map(
                                            (status) => DropdownMenuItem(
                                              value: status,
                                              child: Text(status.toUpperCase()),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedStatusFilter = value!;
                                          _applyFilters();
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              // Mobile layout - stacked filters
                              TextField(
                                decoration: const InputDecoration(
                                  hintText: 'Search users...',
                                  prefixIcon: Icon(Icons.search),
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                onChanged: _onSearchChanged,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: selectedRoleFilter,
                                      decoration: const InputDecoration(
                                        labelText: 'Role',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                      items: [
                                        const DropdownMenuItem(
                                          value: 'all',
                                          child: Text('All'),
                                        ),
                                        ...roles.map(
                                          (role) => DropdownMenuItem(
                                            value: role,
                                            child: Text(role.toUpperCase()),
                                          ),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          selectedRoleFilter = value!;
                                          _applyFilters();
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: selectedStatusFilter,
                                      decoration: const InputDecoration(
                                        labelText: 'Status',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                      items: statusOptions
                                          .map(
                                            (status) => DropdownMenuItem(
                                              value: status,
                                              child: Text(status.toUpperCase()),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedStatusFilter = value!;
                                          _applyFilters();
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
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
              AppSpacing.verticalSpaceLG,

              // User list
              Expanded(
                child: Card(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredUsers.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No users found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : _buildUserList(isDesktop),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserList(bool isDesktop) {
    return _buildVerticalCards();
  }

  Widget _buildVerticalCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate grid dimensions based on screen size
        int crossAxisCount;

        if (constraints.maxWidth >= 1400) {
          crossAxisCount = 5;
        } else if (constraints.maxWidth >= 1100) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth >= 800) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth >= 600) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 1;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            final user = filteredUsers[index];
            return _buildUserCard(user);
          },
        );
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with avatar and status
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: _getRoleColor(user['role']),
                  child: Text(
                    user['full_name'][0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['full_name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'ID: ${user['employee_id'] ?? 'N/A'}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildCompactStatusChip(user['is_active']),
              ],
            ),
            const SizedBox(height: 4),

            // Role chip
            _buildCompactRoleChip(user['role']),
            const SizedBox(height: 4),

            // Department and Position in single line
            if (user['department'] != null || user['position'] != null) ...[
              Text(
                '${user['department'] ?? ''} ${user['position'] != null ? '• ${user['position']}' : ''}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
            ],

            // Email
            if (user['email'] != null) ...[
              Text(
                user['email'],
                style: const TextStyle(fontSize: 10, color: Colors.blue),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
            ],

            // Last login
            Text(
              'Last: ${_formatDateTime(user['last_login'])}',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),

            const SizedBox(height: 6),

            // Action buttons - more compact
            Row(
              children: [
                Expanded(
                  child: PopupMenuButton<String>(
                    child: Container(
                      height: 28,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit, size: 14),
                          SizedBox(width: 4),
                          Text('Role', style: TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                    onSelected: (newRole) =>
                        _updateUserRole(user['user_id'], newRole),
                    itemBuilder: (context) => roles
                        .where((role) => role != user['role'])
                        .map(
                          (role) => PopupMenuItem(
                            value: role,
                            child: Text(role.toUpperCase()),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: SizedBox(
                    height: 28,
                    child: ElevatedButton(
                      onPressed: () => _toggleUserStatus(
                        user['user_id'],
                        !user['is_active'],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: user['is_active']
                            ? Colors.orange
                            : Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        textStyle: const TextStyle(fontSize: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text(
                        user['is_active'] ? 'Deactivate' : 'Activate',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactRoleChip(String role) {
    final colors = {
      'admin': Colors.red,
      'manager': Colors.blue,
      'staff': Colors.green,
      'viewer': Colors.orange,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colors[role] ?? Colors.grey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCompactStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.grey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        isActive ? 'ACTIVE' : 'INACTIVE',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'manager':
        return Colors.blue;
      case 'staff':
        return Colors.green;
      case 'viewer':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }
}
