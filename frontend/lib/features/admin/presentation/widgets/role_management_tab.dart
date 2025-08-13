import 'package:flutter/material.dart';
import '../../data/datasources/admin_remote_datasource.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/api_service.dart';

class RoleManagementTab extends StatefulWidget {
  const RoleManagementTab({super.key});

  @override
  State<RoleManagementTab> createState() => _RoleManagementTabState();
}

class _RoleManagementTabState extends State<RoleManagementTab> {
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
      final authRepository = AuthRepositoryImpl(
        remoteDataSource: AuthRemoteDataSourceImpl(ApiService()),
        storageService: StorageService(),
      );
      
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
                            if (isDesktop) ...{
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
                                        ...availableRoles.map(
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
                            } else ...{
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
                                        ...availableRoles.map(
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
                            },
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
            childAspectRatio: 1.3,
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
            if (user['department'] != null || user['position'] != null) ...{
              Text(
                '${user['department'] ?? ''} ${user['position'] != null ? '• ${user['position']}' : ''}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
            },

            // Email
            if (user['email'] != null) ...{
              Text(
                user['email'],
                style: const TextStyle(fontSize: 10, color: Colors.blue),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
            },

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
                    itemBuilder: (context) {
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

                      return availableRoles
                          .map(
                            (role) => PopupMenuItem(
                              value: role,
                              child: Text(role.toUpperCase()),
                            ),
                          )
                          .toList();
                    },
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
