// Path: frontend/lib/features/auth/presentation/bloc/auth_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];

  @override
  String toString() {
    return 'AuthAuthenticated(user: $user)';
  }
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() {
    return 'AuthError(message: $message)';
  }
}

class LoginLoading extends AuthState {
  const LoginLoading();
}

class LoginSuccess extends AuthState {
  final UserEntity user;

  const LoginSuccess({required this.user});

  @override
  List<Object?> get props => [user];

  @override
  String toString() {
    return 'LoginSuccess(user: $user)';
  }
}

class LoginFailure extends AuthState {
  final String message;

  const LoginFailure({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() {
    return 'LoginFailure(message: $message)';
  }
}

class LogoutLoading extends AuthState {
  const LogoutLoading();
}

class LogoutSuccess extends AuthState {
  final String message;

  const LogoutSuccess({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() {
    return 'LogoutSuccess(message: $message)';
  }
}

class PasswordChangeLoading extends AuthState {
  const PasswordChangeLoading();
}

class PasswordChangeSuccess extends AuthState {
  final String message;

  const PasswordChangeSuccess({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() {
    return 'PasswordChangeSuccess(message: $message)';
  }
}

class PasswordChangeFailure extends AuthState {
  final String message;

  const PasswordChangeFailure({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() {
    return 'PasswordChangeFailure(message: $message)';
  }
}
