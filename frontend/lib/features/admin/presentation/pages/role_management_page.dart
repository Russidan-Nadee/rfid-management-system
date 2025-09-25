import 'package:flutter/material.dart';
import '../../data/datasources/admin_remote_datasource.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../../di/injection.dart';
import '../../../../l10n/features/admin/admin_localizations.dart';
import '../widgets/role_management_search_filters.dart';
import '../widgets/user_card_widget.dart';

class RoleManagementPage extends StatelessWidget {
  const RoleManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleManagementView();
  }
}

class RoleManagementView extends StatefulWidget {
  const RoleManagementView({super.key});

  @override
  State<RoleManagementView> createState() => _RoleManagementViewState();
}

class _RoleManagementViewState extends State<RoleManagementView> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  List<String> availableRoles = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedRoleFilter = 'all';
  String selectedStatusFilter = 'all';
  bool _isSearchExpanded = false;
  String? currentUserRole;
  String? currentUserId;

  final List<String> statusOptions = ['all', 'active', 'inactive'];

  @override
  void initState() {
    super.initState();
    _loadCurrentUserRole();
    _loadAvailableRoles();
    _loadUsers();
  }

  Future<void> _loadCurrentUserRole() async {
    try {
      final authRepository = getIt<AuthRepository>();

      final currentUser = await authRepository.getCurrentUser();
      if (currentUser != null) {
        currentUserRole = currentUser.role;
        currentUserId = currentUser.userId;
      } else {
        currentUserRole = 'viewer';
        currentUserId = null;
      }
    } catch (error) {
      currentUserRole = 'viewer'; // Default to most restrictive
      currentUserId = null;
    }
  }

  Future<void> _loadAvailableRoles() async {
    try {
      final datasource = AdminRemoteDatasourceImpl();
      availableRoles = await datasource.getAvailableRoles();
    } catch (error) {
      // Fallback to hardcoded roles if API fails or doesn't exist
      print('⚠️ Role API failed, using fallback roles: $error');
      availableRoles = ['admin', 'manager', 'staff', 'viewer'];
    }
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

      // ===== ROLE-BASED VISIBILITY =====
      bool canViewUser = false;

      if (currentUserRole == 'admin') {
        // Admin can fully manage managers and below, and can see every user except other admins
        canViewUser = user['role'] != 'admin';
      } else if (currentUserRole == 'manager') {
        // Manager can fully manage staff and viewers, and must not see admins or other managers
        canViewUser = user['role'] == 'staff' || user['role'] == 'viewer';
      } else {
        // Other roles have no viewing permissions
        canViewUser = false;
      }

      return matchesSearch && matchesRole && matchesStatus && canViewUser;
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1200;
          final isTablet = constraints.maxWidth >= 768;
          final padding = isDesktop ? 24.0 : (isTablet ? 16.0 : 12.0);

          return Padding(
            padding: EdgeInsets.fromLTRB(padding, 8, padding, padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.people, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          AdminLocalizations.of(context).roleManagement,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${AdminLocalizations.of(context).totalUsers}: ${filteredUsers.length}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Search and filters using widget
                RoleManagementSearchFilters(
                  isExpanded: _isSearchExpanded,
                  onToggle: () {
                    setState(() {
                      _isSearchExpanded = !_isSearchExpanded;
                    });
                  },
                  isDesktop: isDesktop,
                  roles: availableRoles,
                  statusOptions: statusOptions,
                  selectedRoleFilter: selectedRoleFilter,
                  selectedStatusFilter: selectedStatusFilter,
                  onSearchChanged: _onSearchChanged,
                  onRoleFilterChanged: (value) {
                    setState(() {
                      selectedRoleFilter = value;
                      _applyFilters();
                    });
                  },
                  onStatusFilterChanged: (value) {
                    setState(() {
                      selectedStatusFilter = value;
                      _applyFilters();
                    });
                  },
                ),
                const SizedBox(height: 12),

                // User list
                Expanded(
                  child: Card(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : filteredUsers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.people_outline,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  AdminLocalizations.of(context).noUsersFound,
                                  style: const TextStyle(
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
      ),
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
            childAspectRatio: 1.3,
          ),
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            final user = filteredUsers[index];
            return UserCardWidget(
              user: user,
              roles: _getAvailableRolesForUser(user),
              onUpdateUserRole: _updateUserRole,
              onToggleUserStatus: _toggleUserStatus,
            );
          },
        );
      },
    );
  }

  List<String> _getAvailableRolesForUser(Map<String, dynamic> user) {
    List<String> availableRoles;

    if (currentUserRole == 'admin') {
      // Admin can fully manage managers and below - can assign manager, staff, viewer (but not admin)
      availableRoles = this.availableRoles
          .where((role) => role != 'admin') // Cannot assign admin role
          .where((role) => role != user['role']) // Cannot assign same role
          .toList();
    } else if (currentUserRole == 'manager') {
      // Manager can fully manage staff and viewers - can only assign staff and viewer
      availableRoles = ['staff', 'viewer']
          .where((role) => role != user['role']) // Cannot assign same role
          .toList();
    } else {
      // Other roles have no permissions
      availableRoles = [];
    }

    return availableRoles;
  }

}