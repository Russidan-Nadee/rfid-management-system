// Path: frontend/lib/features/auth/domain/entities/user_entity.dart
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String userId;
  final String username;
  final String fullName;
  final String role;
  final DateTime? lastLogin;
  final DateTime? createdAt;

  const UserEntity({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.role,
    this.lastLogin,
    this.createdAt,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isManager => role.toLowerCase() == 'manager';
  bool get isUser => role.toLowerCase() == 'user';

  String get roleLabel {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'manager':
        return 'Manager';
      case 'user':
        return 'User';
      default:
        return role;
    }
  }

  String get displayName => fullName.isNotEmpty ? fullName : username;

  String get initials {
    if (fullName.isNotEmpty) {
      final parts = fullName.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return fullName[0].toUpperCase();
    }
    return username[0].toUpperCase();
  }

  @override
  List<Object?> get props => [
    userId,
    username,
    fullName,
    role,
    lastLogin,
    createdAt,
  ];

  @override
  String toString() {
    return 'UserEntity(userId: $userId, username: $username, fullName: $fullName, role: $role)';
  }
}
