// Path: frontend/lib/core/constants/app_typography.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Headline Styles
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
    height: 1.3,
  );

  static const TextStyle headline3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
  );

  static const TextStyle headline4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.25,
    height: 1.4,
  );

  static const TextStyle headline5 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.4,
  );

  static const TextStyle headline6 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.4,
  );

  // Body Styles
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.4,
  );

  // Caption & Label Styles
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.3,
  );

  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    height: 1.6,
  );

  // Button Styles
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.25,
    height: 1.2,
  );

  // Dashboard Specific Styles
  static const TextStyle dashboardTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.15,
    height: 1.2,
    color: AppColors.primary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.3,
  );

  static const TextStyle statValue = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.1,
  );

  static const TextStyle statLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    height: 1.3,
  );

  static const TextStyle chartLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    height: 1.2,
  );

  static const TextStyle filterLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    height: 1.2,
  );

  // Semantic Styles with Colors
  static TextStyle get primaryText =>
      body1.copyWith(color: AppColors.onBackground);
  static TextStyle get secondaryText =>
      body2.copyWith(color: AppColors.textSecondary);
  static TextStyle get hintText =>
      caption.copyWith(color: AppColors.textTertiary);

  static TextStyle get successText => body2.copyWith(color: AppColors.success);
  static TextStyle get warningText => body2.copyWith(color: AppColors.warning);
  static TextStyle get errorText => body2.copyWith(color: AppColors.error);

  // Responsive Text Styles Helper
  static TextStyle responsive({
    required BuildContext context,
    required TextStyle style,
    double? mobileFactor,
    double? tabletFactor,
    double? desktopFactor,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    double factor = 1.0;

    if (screenWidth < 600 && mobileFactor != null) {
      factor = mobileFactor;
    } else if (screenWidth < 1024 && tabletFactor != null) {
      factor = tabletFactor;
    } else if (desktopFactor != null) {
      factor = desktopFactor;
    }

    return style.copyWith(fontSize: style.fontSize! * factor);
  }

  // Theme Data Extension
  static TextTheme get lightTextTheme => TextTheme(
    displayLarge: headline1,
    displayMedium: headline2,
    displaySmall: headline3,
    headlineLarge: headline4,
    headlineMedium: headline5,
    headlineSmall: headline6,
    titleLarge: headline5,
    titleMedium: headline6,
    titleSmall: button,
    bodyLarge: body1,
    bodyMedium: body2,
    bodySmall: caption,
    labelLarge: button,
    labelMedium: caption,
    labelSmall: overline,
  );

  static TextTheme get darkTextTheme =>
      lightTextTheme.apply(bodyColor: Colors.white, displayColor: Colors.white);
}
