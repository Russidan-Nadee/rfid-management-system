import 'package:flutter/material.dart';

class UserCardWidget extends StatelessWidget {
  final Map<String, dynamic> user;
  final List<String> roles;
  final Function(String userId, String newRole) onUpdateUserRole;
  final Function(String userId, bool isActive) onToggleUserStatus;

  const UserCardWidget({
    super.key,
    required this.user,
    required this.roles,
    required this.onUpdateUserRole,
    required this.onToggleUserStatus,
  });

  @override
  Widget build(BuildContext context) {
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
                        onUpdateUserRole(user['user_id'], newRole),
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
                      onPressed: () => onToggleUserStatus(
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