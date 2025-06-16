// Path: frontend/lib/features/auth/data/repositories/auth_repository_impl.dart
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final StorageService storageService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.storageService,
  });

  @override
  Future<AuthResult> login(String username, String password) async {
    try {
      final request = LoginRequest(username: username, password: password);
      final response = await remoteDataSource.login(request);

      // Save authentication data
      await storageService.saveAuthToken(response.token);
      await storageService.saveUserData(response.user.toJson());

      return AuthResult.success(
        user: response.user,
        token: response.token,
        sessionId: response.sessionId,
      );
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Try to logout from server
      await remoteDataSource.logout();
    } catch (e) {
      // Continue with local logout even if server logout fails
    } finally {
      // Always clear local data
      await clearAuthData();
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final userData = await storageService.getUserData();
      if (userData != null) {
        return UserModel.fromJson(userData);
      }

      // If no local data, try to get from server
      final user = await remoteDataSource.getProfile();
      await storageService.saveUserData(user.toJson());
      return user;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getCurrentUserId() async {
    try {
      final user = await getCurrentUser();
      return user?.userId;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await storageService.getAuthToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await storageService.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await remoteDataSource.refreshToken(refreshToken);

      if (response) {
        // ถ้า Backend return token ใหม่ ต้องบันทึก
        // แต่ตอนนี้ Backend แค่ validate เลยไม่ต้องทำอะไร
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await remoteDataSource.changePassword(currentPassword, newPassword);
    } catch (e) {
      throw Exception('Failed to change password: ${e.toString()}');
    }
  }

  @override
  Future<String?> getAuthToken() async {
    return await storageService.getAuthToken();
  }

  @override
  Future<void> clearAuthData() async {
    await storageService.clearAuthData();
  }
}
