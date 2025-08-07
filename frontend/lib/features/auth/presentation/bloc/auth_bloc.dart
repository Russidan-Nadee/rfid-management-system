// Path: frontend/lib/features/auth/presentation/bloc/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final AuthRepository authRepository;

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.authRepository,
  }) : super(const AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<GetProfileRequested>(_onGetProfileRequested);
    on<ChangePasswordRequested>(_onChangePasswordRequested);
    on<RefreshTokenRequested>(_onRefreshTokenRequested);
    on<CheckAuthenticationStatus>(_onCheckAuthenticationStatus);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      final isAuthenticated = await authRepository.isAuthenticated();

      if (isAuthenticated) {
        final user = await authRepository.getCurrentUser();
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          emit(const AuthUnauthenticated());
        }
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const LoginLoading());

    try {
      final result = await loginUseCase.execute(event.ldapUsername, event.password);

      if (result.success && result.user != null) {
        emit(LoginSuccess(user: result.user!));
        emit(AuthAuthenticated(user: result.user!));
      } else {
        emit(LoginFailure(message: result.errorMessage ?? 'Login failed'));
      }
    } catch (e) {
      emit(LoginFailure(message: 'Network error: ${e.toString()}'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const LogoutLoading());

    try {
      final result = await logoutUseCase.execute();

      if (result.success) {
        emit(LogoutSuccess(message: result.message));
        emit(const AuthUnauthenticated());
      } else {
        // Even if logout fails, we should still go to unauthenticated state
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      // Force logout locally even if network fails
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onGetProfileRequested(
    GetProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await authRepository.getCurrentUser();

      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: 'Failed to get profile: ${e.toString()}'));
    }
  }

  Future<void> _onChangePasswordRequested(
    ChangePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const PasswordChangeLoading());

    try {
      await authRepository.changePassword(
        event.currentPassword,
        event.newPassword,
      );
      emit(
        const PasswordChangeSuccess(message: 'Password changed successfully'),
      );

      // Get updated user profile
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      }
    } catch (e) {
      emit(PasswordChangeFailure(message: e.toString()));
    }
  }

  Future<void> _onRefreshTokenRequested(
    RefreshTokenRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final success = await authRepository.refreshToken();

      if (!success) {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onCheckAuthenticationStatus(
    CheckAuthenticationStatus event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final isAuthenticated = await authRepository.isAuthenticated();

      if (isAuthenticated) {
        final user = await authRepository.getCurrentUser();
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          emit(const AuthUnauthenticated());
        }
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }
}
