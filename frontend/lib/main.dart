import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'di/injection.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'app/theme/app_colors.dart';
import 'app.dart';

// เพิ่ม import ApiConstants
import 'core/constants/api_constants.dart';
import 'core/services/cookie_session_service.dart';
import 'core/services/api_service.dart';
import 'core/services/api_error_interceptor.dart';
import 'core/services/global_exception_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize global exception handler
  GlobalExceptionHandler.initialize();

  // **แก้ IP เป็นตัวจริง**
  ApiConstants.setManualIP('172.101.35.153'); // <-- แก้เป็น IP จริงของ Laptop

  // Configure system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Configure supported orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Initialize dependencies
  await configureDependencies();
  
  // Initialize cookie session service
  await CookieSessionService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final authBloc = getIt<AuthBloc>();
        
        // Set up global error interceptor with AuthBloc
        ApiErrorInterceptor.setAuthBloc(authBloc);
        
        // Set up force logout callback to trigger logout when session expires
        ApiService.setForceLogoutCallback(() {
          print('🔥 MAIN: Force logout callback triggered - adding LogoutRequested to AuthBloc');
          authBloc.add(const LogoutRequested());
        });
        
        return authBloc..add(const AppStarted());
      },
      child: const AssetManagementApp(),
    );
  }
}
