// Path: frontend/lib/app.dart
import 'package:flutter/material.dart';
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

      // Home page
      home: const AppEntryPoint(),
    );
  }
}
