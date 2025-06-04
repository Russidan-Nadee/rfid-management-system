// Path: frontend/lib/features/auth/data/datasources/auth_remote_datasource.dart
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(LoginRequest request);
  Future<void> logout();
  Future<UserModel> getProfile();
  Future<bool> refreshToken(String token);
  Future<void> changePassword(String currentPassword, String newPassword);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService apiService;

  AuthRemoteDataSourceImpl(this.apiService);

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    final response = await apiService.post<Map<String, dynamic>>(
      ApiConstants.login,
      body: request.toJson(),
      requiresAuth: false,
    );

    if (response.success && response.data != null) {
      return LoginResponse.fromJson(response.data!);
    } else {
      throw Exception(response.message);
    }
  }

  @override
  Future<void> logout() async {
    final response = await apiService.post<void>(
      ApiConstants.logout,
      requiresAuth: true,
    );

    if (!response.success) {
      throw Exception(response.message);
    }
  }

  @override
  Future<UserModel> getProfile() async {
    final response = await apiService.get<Map<String, dynamic>>(
      ApiConstants.profile,
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return UserModel.fromJson(response.data!);
    } else {
      throw Exception(response.message);
    }
  }

  @override
  Future<bool> refreshToken(String token) async {
    final response = await apiService.post<Map<String, dynamic>>(
      ApiConstants.refreshToken,
      body: {'token': token},
      requiresAuth: false,
    );

    return response.success;
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final response = await apiService.post<void>(
      ApiConstants.changePassword,
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': newPassword,
      },
      requiresAuth: true,
    );

    if (!response.success) {
      throw Exception(response.message);
    }
  }
}
