// Path: frontend/lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // เพิ่มบรรทัดนี้
import 'app/theme/app_theme.dart';
import 'app/app_constants.dart';
import 'app/app_entry_point.dart';

class AssetManagementApp extends StatelessWidget {
  const AssetManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,

      // ใช้ Enhanced Theme ที่สร้างไว้
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

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

      // Home page
      home: const AppEntryPoint(),
    );
  }
}
