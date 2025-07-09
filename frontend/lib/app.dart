// Path: frontend/lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/theme/app_theme.dart';
import 'app/app_constants.dart';
import 'app/app_entry_point.dart';
import 'features/setting/presentation/bloc/settings_bloc.dart';
import 'features/setting/presentation/bloc/settings_state.dart';
import 'features/setting/presentation/bloc/settings_event.dart';
import 'di/injection.dart';

class AssetManagementApp extends StatelessWidget {
  const AssetManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsBloc>(
      create: (context) => getIt<SettingsBloc>()..add(const LoadSettings()),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (previous, current) {
          // Rebuild เมื่อ language หรือ theme เปลี่ยน
          if (previous is SettingsLoaded && current is SettingsLoaded) {
            return previous.settings.language != current.settings.language ||
                previous.settings.themeMode != current.settings.themeMode;
          }
          return current is SettingsLoaded;
        },
        builder: (context, state) {
          Locale locale = const Locale('en'); // Default locale
          ThemeMode themeMode = ThemeMode.system; // Default theme mode

          if (state is SettingsLoaded) {
            locale = Locale(state.settings.language);
            themeMode = _getThemeMode(state.settings.themeMode);
          }

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: AppConstants.appName,

            // ใช้ Enhanced Theme ที่สร้างไว้
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode, // ใช้จาก settings แล้ว
            // เพิ่ม Localization Delegates
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // รองรับภาษา
            supportedLocales: const [
              Locale('en'), // English
              Locale('th'), // Thai
              Locale('ja'), // Japanese
            ],

            // ใช้ locale จาก settings
            locale: locale,

            // Home page
            home: const AppEntryPoint(),
          );
        },
      ),
    );
  }

  /// แปลง theme mode string เป็น ThemeMode enum
  ThemeMode _getThemeMode(String themeMode) {
    switch (themeMode.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
