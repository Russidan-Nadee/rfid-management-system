// Path: frontend/lib/features/auth/domain/entities/user_entity.dart
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String userId;
  final String? employeeId;
  final String fullName;
  final String? department;
  final String? position;
  final String? companyRole;
  final String? email;
  final String role; // System role
  final bool isActive;
  final DateTime? lastLogin;
  final DateTime? createdAt;

  const UserEntity({
    required this.userId,
    this.employeeId,
    required this.fullName,
    this.department,
    this.position,
    this.companyRole,
    this.email,
    required this.role,
    required this.isActive,
    this.lastLogin,
    this.createdAt,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isManager => role.toLowerCase() == 'manager';
  bool get isStaff => role.toLowerCase() == 'staff';
  bool get isViewer => role.toLowerCase() == 'viewer';

  String get roleLabel {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'manager':
        return 'Manager';
      case 'staff':
        return 'Staff';
      case 'viewer':
        return 'Viewer';
      default:
        return role;
    }
  }

  String get displayName => fullName.isNotEmpty ? fullName : (employeeId ?? 'Unknown User');

  String get initials {
    if (fullName.isNotEmpty) {
      final parts = fullName.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return fullName[0].toUpperCase();
    }
    return employeeId?[0].toUpperCase() ?? 'U';
  }

  String get departmentInfo => department ?? 'No Department';
  String get positionInfo => position ?? 'No Position';
  String get companyRoleInfo => companyRole ?? 'No Company Role';

  @override
  List<Object?> get props => [
    userId,
    employeeId,
    fullName,
    department,
    position,
    companyRole,
    email,
    role,
    isActive,
    lastLogin,
    createdAt,
  ];

  @override
  String toString() {
    return 'UserEntity(userId: $userId, employeeId: $employeeId, fullName: $fullName, role: $role)';
  }
}
