// Path: frontend/lib/app/app_entry_point.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../core/widgets/session_manager.dart';
import 'splash_screen.dart';
import '../layouts/root_layout.dart';

class AppEntryPoint extends StatelessWidget {
  const AppEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    // ===== DEVELOPMENT MODE: ข้าม Auth ตรงไป Layout =====
    if (kDebugMode) {
      const bool skipAuth = false; // เปลี่ยนเป็น false เมื่อต้องการ auth กลับ

      if (skipAuth) {
        return const SessionManager(child: RootLayout());
      }
    }

    // ===== PRODUCTION MODE: ใช้ Auth ปกติ =====
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const SplashScreen();
        } else if (state is AuthAuthenticated) {
          return const SessionManager(child: RootLayout());
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
