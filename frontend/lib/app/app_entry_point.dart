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
import '../core/services/browser_api_io.dart';
import '../core/services/session_timer_service.dart';
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
  final SessionTimerService _sessionTimer = SessionTimerService();
  Timer? _expiryCheckTimer;
  StreamSubscription<void>? _focusSubscription;
  StreamSubscription<void>? _visibilitySubscription;
  bool _isAppInForeground = true; // Track app state

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
      _isAppInForeground = true;
      _checkSessionOnResume();
    });
    
    // Listen for visibility change (tab becomes visible/hidden) - works on all platforms
    _visibilitySubscription = _browserApi.onVisibilityChange.listen((event) {
      if (!_browserApi.isDocumentHidden) {
        _isAppInForeground = true;
        _checkSessionOnResume();
      } else {
        _isAppInForeground = false;
      }
    });
  }

  void _startPeriodicExpiryCheck() {
    // Check session expiry every 5 minutes while app is active for production
    _expiryCheckTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
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

    print('⏰ Periodic session check at ${DateTime.now()} (App in foreground: $_isAppInForeground)');
    await _sessionService.hasValidSession();
    final isExpired = _sessionService.isSessionExpired();
    final timeUntilExpiry = _sessionService.getTimeUntilExpiry();
    print('⏰ Session expired: $isExpired, Time until expiry: ${timeUntilExpiry?.inSeconds} seconds');
    
    if (isExpired && mounted) {
      // Check if user was recently active before expiring
      final isActive = _sessionTimer.wasRecentlyActive(const Duration(minutes: 15));
      if (isActive) {
        print('🔄 Session expired but user was active - attempting refresh');
        final authBloc = context.read<AuthBloc>();
        authBloc.add(const RefreshTokenRequested());
      } else {
        print('🔄 Session expired and user inactive - forcing logout');
        final authBloc = context.read<AuthBloc>();
        authBloc.add(const LogoutRequested());
      }
    } else if (timeUntilExpiry != null && timeUntilExpiry.inMinutes <= 10 && mounted) {
      // Only proactively refresh if app is in foreground AND user was recently active
      final isActive = _sessionTimer.wasRecentlyActive(const Duration(minutes: 15));
      if (isActive && _isAppInForeground) {
        print('🔄 Session near expiry, user active, and app in foreground - proactive refresh');
        final authBloc = context.read<AuthBloc>();
        authBloc.add(const RefreshTokenRequested());
      } else if (!_isAppInForeground) {
        print('⏸️ Session near expiry but app in background - skipping proactive refresh');
      } else {
        print('💤 Session near expiry but user not recently active - skipping proactive refresh');
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Handle Windows/Desktop app lifecycle properly
    if (_browserApi is BrowserApiIO) {
      final browserApiIO = _browserApi as BrowserApiIO;
      
      switch (state) {
        case AppLifecycleState.resumed:
          print('🪟 Windows: App resumed - marking as active');
          _isAppInForeground = true;
          browserApiIO.handleAppLifecycleState(true);
          _checkSessionOnResume();
          break;
        case AppLifecycleState.paused:
        case AppLifecycleState.inactive:
          print('🪟 Windows: App paused/inactive - marking as background');
          _isAppInForeground = false;
          browserApiIO.handleAppLifecycleState(false);
          break;
        case AppLifecycleState.detached:
        case AppLifecycleState.hidden:
          print('🪟 Windows: App detached/hidden - marking as background');
          _isAppInForeground = false;
          browserApiIO.handleAppLifecycleState(false);
          break;
      }
    } else {
      // Web/other platforms - original behavior
      if (state == AppLifecycleState.resumed) {
        _isAppInForeground = true;
        _checkSessionOnResume();
      } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
        _isAppInForeground = false;
      }
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
      // User returned to app - always attempt refresh on resume
      print('🔄 Session expired on resume - attempting refresh');
      final authBloc = context.read<AuthBloc>();
      authBloc.add(const RefreshTokenRequested());
    } else {
      // Session valid but check if close to expiry - preemptively refresh
      final timeUntilExpiry = _sessionService.getTimeUntilExpiry();
      if (timeUntilExpiry != null && timeUntilExpiry.inMinutes <= 10 && mounted) {
        print('🔄 Session near expiry on resume - proactive refresh');
        final authBloc = context.read<AuthBloc>();
        authBloc.add(const RefreshTokenRequested());
      }
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
        // Handle auth state changes
      },
      builder: (context, state) {
        
        if (state is AuthLoading || state is AuthInitial) {
          return const SplashScreen();
        } else if (state is AuthAuthenticated) {
          // Wrap with global activity detector
          return GestureDetector(
            onTap: () {
              _sessionTimer.recordActivity();
            },
            onPanDown: (_) {
              _sessionTimer.recordActivity();
            },
            onScaleStart: (_) {
              _sessionTimer.recordActivity();
            },
            behavior: HitTestBehavior.translucent,
            child: const SessionManager(child: RootLayout()),
          );
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
