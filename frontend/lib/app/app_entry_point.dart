// Path: frontend/lib/app/app_entry_point.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../core/widgets/session_manager.dart';
import '../core/services/cookie_session_service.dart';
import '../core/services/browser_api.dart';
import 'splash_screen.dart';
import '../layouts/root_layout.dart';

class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({super.key});

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<AppEntryPoint> with WidgetsBindingObserver {
  final CookieSessionService _sessionService = CookieSessionService();
  final BrowserApi _browserApi = BrowserApiService.instance;
  Timer? _expiryCheckTimer;
  StreamSubscription<void>? _focusSubscription;
  StreamSubscription<void>? _visibilitySubscription;

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
    _focusSubscription?.cancel();
    _visibilitySubscription?.cancel();
    super.dispose();
  }

  void _setupWebEventListeners() {
    // Listen for window focus (when user returns to tab) - works on all platforms
    _focusSubscription = _browserApi.onWindowFocus.listen((event) {
      _checkSessionOnResume();
    });
    
    // Listen for visibility change (tab becomes visible/hidden) - works on all platforms
    _visibilitySubscription = _browserApi.onVisibilityChange.listen((event) {
      if (!_browserApi.isDocumentHidden) {
        _checkSessionOnResume();
      }
    });
  }

  void _startPeriodicExpiryCheck() {
    // Check session expiry every 30 seconds while app is active (1:10 scaled)
    _expiryCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkSessionExpiry();
    });
  }

  void _checkSessionExpiry() async {
    if (!mounted) return;
    
    final currentState = context.read<AuthBloc>().state;
    if (currentState is! AuthAuthenticated) {
      print('⏰ Periodic check: User not authenticated, skipping');
      return;
    }

    print('⏰ Periodic session check at ${DateTime.now()}');
    await _sessionService.hasValidSession();
    final isExpired = _sessionService.isSessionExpired();
    print('⏰ Session expired: $isExpired');
    
    if (isExpired && mounted) {
      print('🚨 Session expired - triggering logout');
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
