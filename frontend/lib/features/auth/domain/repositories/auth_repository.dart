// Path: frontend/lib/features/auth/domain/repositories/auth_repository.dart
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<AuthResult> login(String ldapUsername, String password);
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
  Future<String?> getCurrentUserId();
  Future<bool> isAuthenticated();
  Future<bool> refreshToken();
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> clearAuthData();
}

class AuthResult {
  final bool success;
  final UserEntity? user;
  final String? sessionId;
  final String? errorMessage;

  AuthResult({
    required this.success,
    this.user,
    this.sessionId,
    this.errorMessage,
  });

  factory AuthResult.success({
    required UserEntity user,
    required String sessionId,
  }) {
    return AuthResult(
      success: true,
      user: user,
      sessionId: sessionId,
    );
  }

  factory AuthResult.failure(String errorMessage) {
    return AuthResult(success: false, errorMessage: errorMessage);
  }

  @override
  String toString() {
    return 'AuthResult(success: $success, user: $user, errorMessage: $errorMessage)';
  }
}
