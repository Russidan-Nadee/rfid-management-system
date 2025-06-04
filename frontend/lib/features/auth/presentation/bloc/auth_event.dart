// Path: frontend/lib/features/auth/presentation/bloc/auth_event.dart
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {
  const AppStarted();
}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;
  final bool rememberMe;

  const LoginRequested({
    required this.username,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [username, password, rememberMe];

  @override
  String toString() {
    return 'LoginRequested(username: $username, password: [HIDDEN], rememberMe: $rememberMe)';
  }
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class GetProfileRequested extends AuthEvent {
  const GetProfileRequested();
}

class ChangePasswordRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];

  @override
  String toString() {
    return 'ChangePasswordRequested(currentPassword: [HIDDEN], newPassword: [HIDDEN])';
  }
}

class RefreshTokenRequested extends AuthEvent {
  const RefreshTokenRequested();
}

class CheckAuthenticationStatus extends AuthEvent {
  const CheckAuthenticationStatus();
}
