// Path: frontend/lib/features/auth/data/models/user_model.dart
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.userId,
    super.employeeId,
    required super.fullName,
    super.department,
    super.position,
    super.companyRole,
    super.email,
    required super.role,
    required super.isActive,
    super.lastLogin,
    super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id']?.toString() ?? '',
      employeeId: json['employee_id']?.toString(),
      fullName: json['full_name'] ?? '',
      department: json['department'],
      position: json['position'],
      companyRole: json['company_role'],
      email: json['email'],
      role: json['role'] ?? '',
      isActive: json['is_active'] == true || json['is_active'] == 1,
      lastLogin: json['last_login'] != null
          ? DateTime.tryParse(json['last_login'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'employee_id': employeeId,
      'full_name': fullName,
      'department': department,
      'position': position,
      'company_role': companyRole,
      'email': email,
      'role': role,
      'is_active': isActive,
      'last_login': lastLogin?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      userId: entity.userId,
      employeeId: entity.employeeId,
      fullName: entity.fullName,
      department: entity.department,
      position: entity.position,
      companyRole: entity.companyRole,
      email: entity.email,
      role: entity.role,
      isActive: entity.isActive,
      lastLogin: entity.lastLogin,
      createdAt: entity.createdAt,
    );
  }

  UserModel copyWith({
    String? userId,
    String? employeeId,
    String? fullName,
    String? department,
    String? position,
    String? companyRole,
    String? email,
    String? role,
    bool? isActive,
    DateTime? lastLogin,
    DateTime? createdAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      employeeId: employeeId ?? this.employeeId,
      fullName: fullName ?? this.fullName,
      department: department ?? this.department,
      position: position ?? this.position,
      companyRole: companyRole ?? this.companyRole,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(userId: $userId, employeeId: $employeeId, fullName: $fullName, role: $role)';
  }
}
