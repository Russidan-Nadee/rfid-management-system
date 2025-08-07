// Path: frontend/lib/features/auth/domain/usecases/login_usecase.dart
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<LoginResult> execute(String ldapUsername, String password) async {
    // Validation
    if (ldapUsername.isEmpty) {
      return LoginResult.failure('LDAP username is required');
    }

    if (password.isEmpty) {
      return LoginResult.failure('Password is required');
    }

    if (ldapUsername.length < 3) {
      return LoginResult.failure('LDAP username must be at least 3 characters');
    }

    if (password.length < 4) {
      return LoginResult.failure('Password must be at least 4 characters');
    }

    // Execute login
    try {
      final result = await repository.login(ldapUsername.trim(), password);

      if (result.success && result.user != null) {
        return LoginResult.success(result.user!);
      } else {
        return LoginResult.failure(result.errorMessage ?? 'Login failed');
      }
    } catch (e) {
      return LoginResult.failure('Network error: ${e.toString()}');
    }
  }
}

class LoginResult {
  final bool success;
  final UserEntity? user;
  final String? errorMessage;

  LoginResult({required this.success, this.user, this.errorMessage});

  factory LoginResult.success(UserEntity user) {
    return LoginResult(success: true, user: user);
  }

  factory LoginResult.failure(String errorMessage) {
    return LoginResult(success: false, errorMessage: errorMessage);
  }

  @override
  String toString() {
    return 'LoginResult(success: $success, user: $user, errorMessage: $errorMessage)';
  }
}
