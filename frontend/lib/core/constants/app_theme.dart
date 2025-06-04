// lib/core/styles/app_theme.dart
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';

final ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: AppColors.background,
  primaryColor: AppColors.primary,
  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    background: AppColors.background,
    surface: AppColors.surface,
    onPrimary: AppColors.onPrimary,
    onBackground: AppColors.onBackground,
  ),
  useMaterial3: true,
);
