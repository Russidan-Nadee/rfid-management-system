// Path: frontend/lib/app/app_entry_point.dart
import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../core/widgets/session_manager.dart';
import '../core/services/cookie_session_service.dart';
import 'splash_screen.dart';
import '../layouts/root_layout.dart';

class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({super.key});

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<AppEntryPoint> with WidgetsBindingObserver {
  final CookieSessionService _sessionService = CookieSessionService();
  Timer? _expiryCheckTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startPeriodicExpiryCheck();
    _setupWebEventListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _expiryCheckTimer?.cancel();
    super.dispose();
  }

  void _setupWebEventListeners() {
    if (kIsWeb) {
      // Listen for window focus (when user returns to tab)
      html.window.onFocus.listen((event) {
        _checkSessionOnResume();
      });
      
      // Listen for visibility change (tab becomes visible/hidden)
      html.document.onVisibilityChange.listen((event) {
        if (!html.document.hidden!) {
          _checkSessionOnResume();
        }
      });
    }
  }

  void _startPeriodicExpiryCheck() {
    // Check session expiry every 5 minutes while app is active
    _expiryCheckTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _checkSessionExpiry();
    });
  }

  void _checkSessionExpiry() async {
    if (!mounted) return;
    
    final currentState = context.read<AuthBloc>().state;
    if (currentState is! AuthAuthenticated) {
      return;
    }

    await _sessionService.hasValidSession();
    if (_sessionService.isSessionExpired() && mounted) {
      context.read<AuthBloc>().add(const LogoutRequested());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.resumed) {
      _checkSessionOnResume();
    }
  }

  void _checkSessionOnResume() async {
    // Check if widget is still mounted before accessing context
    if (!mounted) return;
    
    // Only check if user is currently authenticated
    final currentState = context.read<AuthBloc>().state;
    
    if (currentState is! AuthAuthenticated) {
      return;
    }

    // Load session data from storage and check if expired
    await _sessionService.hasValidSession();
    
    final isExpired = _sessionService.isSessionExpired();
    
    if (isExpired && mounted) {
      context.read<AuthBloc>().add(const LogoutRequested());
    }
  }

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
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        print('🎯 AppEntryPoint: BlocConsumer received state: ${state.runtimeType}');
        if (state is AuthUnauthenticated) {
          print('🚨 AppEntryPoint: AuthUnauthenticated detected - should show LoginPage');
        }
      },
      builder: (context, state) {
        print('🔍 AppEntryPoint: Building with state: ${state.runtimeType}');
        
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
