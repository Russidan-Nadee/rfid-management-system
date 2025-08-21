// Path: frontend/lib/features/auth/data/repositories/auth_repository_impl.dart
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/cookie_session_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final StorageService storageService;
  final CookieSessionService cookieService = CookieSessionService();

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.storageService,
  });

  @override
  Future<AuthResult> login(String ldapUsername, String password) async {
    try {
      // Initialize new session (clears old session data)
      await cookieService.initializeNewSession();
      
      final request = LoginRequest(ldapUsername: ldapUsername, password: password);
      final response = await remoteDataSource.login(request);

      // Update session cookie and expiry time if provided
      if (response.sessionId.isNotEmpty) {
        // Store session ID as cookie
        await cookieService.storeSessionId(response.sessionId);
      }
      
      if (response.expiresAt != null) {
        await cookieService.updateSessionExpiry(DateTime.parse(response.expiresAt!));
      }

      // Save user data
      await storageService.saveUserData(response.user.toJson());
      
      return AuthResult.success(
        user: response.user,
        sessionId: response.sessionId,
      );
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Try to logout from server (clears session cookies)
      await remoteDataSource.logout();
    } catch (e) {
      // Continue with local logout even if server logout fails
    } finally {
      // Always clear local data and session cookies
      await clearAuthData();
      await cookieService.clearSession();
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
    // Check session-based authentication only
    final hasValidSession = await cookieService.hasValidSession();
    return hasValidSession;
  }

  @override
  Future<bool> refreshToken() async {
    try {
      // Use session-based refresh only
      final sessionRefreshResult = await remoteDataSource.refreshSession();
      if (sessionRefreshResult) {
        await storageService.updateSessionTimestamp();
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
  Future<void> clearAuthData() async {
    await storageService.clearAuthData();
    await cookieService.clearSession();
  }
}
