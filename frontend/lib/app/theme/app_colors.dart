// Path: frontend/lib/app/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Navy tone for buttons and headers
  static const Color primary = Color(0xFF1E3A5F);
  static const Color primaryLight = Color(0xFF2C4F7C);
  static const Color primaryDark = Color.fromARGB(255, 19, 35, 59);
  static const Color primarySurface = Color(0xFFF1F5F9);

  // Background
  static const Color background = Color(0xFFF9FAFB);
  static const Color backgroundSecondary = Color(0xFFF3F4F6);
  static const Color backgroundTertiary = Color(0xFFE5E7EB);

  // Surface
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFF9FAFB);

  // Text
  static const Color onPrimary = Colors.white;
  static const Color onBackground = Color(0xFF1F2937);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFFD1D5DB);

  // Status Colors - Updated with Light Blue theme
  static const Color success = Color(0xFF42A5F5); // Light Blue แทนเขียว
  static const Color successLight = Color(0xFFE3F2FD); // Light blue background
  static const Color successDark = Color(0xFF1976D2); // Darker blue
  static const Color warning = Color(0xFFDC2626); // ส้มเดิม
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFD97706);

  static const Color error = Color(0xFFEF4444); // แดงอ่อนลงเล็กน้อย
  static const Color errorLight = Color(0xFFFEF2F2);
  static const Color errorDark = Color(0xFFDC2626);

  static const Color info = Color(0xFF6366F1); // ม่วงน้ำเงินแทนม่วงสด
  static const Color infoLight = Color(0xFFF0F0FF);
  static const Color infoDark = Color(0xFF4F46E5);

  // Vibrant Colors - Updated with theme colors
  static const Color vibrantOrange = Color(0xFFF59E0B);
  static const Color vibrantOrangeLight = Color(0xFFFEF3C7);
  static const Color vibrantBlue = Color(0xFF42A5F5); // Light Blue
  static const Color vibrantBlueLight = Color(0xFFE3F2FD);
  static const Color vibrantPurple = Color(0xFF6366F1);
  static const Color vibrantPurpleLight = Color(0xFFF0F0FF);

  // Asset Status Colors - Updated
  static const Color assetActive = Color(0xFF42A5F5); // Light Blue
  static const Color assetInactive = Color(0xFFF59E0B); // Orange
  static const Color assetCreated = Color(0xFF6366F1); // Purple-blue
  static const Color assetChecked = Color(0xFF42A5F5); // Light Blue

  // Trend Colors - Updated
  static const Color trendUp = Color(0xFF42A5F5); // Light Blue แทนเขียว
  static const Color trendDown = Color(0xFFEF4444); // Red
  static const Color trendStable = Color(0xFF6B7280); // Gray

  // Chart Colors - Updated with harmonized palette
  static const Color chartBlue = Color(0xFF3B82F6);
  static const Color chartGreen = Colors.green; // Light Blue แทนเขียวสด
  static const Color chartOrange = Color(0xFFF59E0B);
  static const Color chartRed = Color(0xFFEF4444);
  static const Color chartPurple = Color(0xFF6366F1);
  static const Color chartTeal = Color.fromARGB(255, 20, 184, 88);
  static const Color chartAmber = Color(0xFFF59E0B);

  // UI Helper Colors
  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color dividerLight = Color(0xFFF3F4F6);

  // Interactive States
  static const Color selected = primary;
  static const Color unselected = textSecondary;
  static Color hover = primary.withOpacity(0.08);
  static Color pressed = primary.withOpacity(0.12);
  static Color focus = primary.withOpacity(0.12);
  static Color disabled = textMuted.withOpacity(0.38);

  //export
  static const Color excel = Colors.green;
  static const Color csv = Color(0xFFF59E0B);

  // NEW DARK THEME COLORS - Lighter Gray with Blue Tone
  static const Color darkBackground = Color(
    0xFF2A2D35,
  ); // Lighter gray with blue tone - Base background
  static const Color darkSurface = Color(
    0xFF363B45,
  ); // Medium gray-blue - Cards, surfaces
  static const Color darkSurfaceVariant = Color(
    0xFF424954,
  ); // Light gray-blue - Elevated surfaces
  static const Color darkNavigation = Color(
    0xFF1E3A5F,
  ); // Keep original navy for navigation
  static const Color darkSecondary = Color(
    0xFF4A5160,
  ); // Blue-gray - Secondary surfaces
  static const Color darkAccent = Color(
    0xFF525A6B,
  ); // Blue-gray accent - Accent elements

  static const Color darkBorder = Color(
    0xFF4A5160,
  ); // Blue-gray - Borders/dividers
  static const Color darkText = Color(
    0xFFE8EAF0,
  ); // Light blue-tinted text - Primary text
  static const Color darkTextSecondary = Color(
    0xFFB8BCC8,
  ); // Medium blue-gray - Secondary text
  static const Color darkTextMuted = Color(
    0xFF8A90A0,
  ); // Muted blue-gray - Muted text

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary],
  );

  static const LinearGradient vibrantOrangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFA726), vibrantOrange],
  );

  static const LinearGradient vibrantBlueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF64B5F6), vibrantBlue], // Light blue gradient
  );

  static const LinearGradient vibrantPurpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [vibrantPurple, Color(0xFF7C3AED)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, backgroundSecondary],
  );

  // Dark Theme Gradients - Updated with lighter blue-gray tones
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      darkBackground,
      Color(0xFF1F242B),
    ], // Blue-gray to darker blue-gray
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      darkSurface,
      darkSurfaceVariant,
    ], // Medium blue-gray to light blue-gray
  );

  static const LinearGradient darkNavigationGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkNavigation, Color(0xFF0F2A45)], // Navy to darker navy
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [surface, surfaceContainer],
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFA726), vibrantOrange, error],
  );

  static const LinearGradient oceanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [chartTeal, chartBlue, vibrantBlue],
  );

  // Helper Methods
  static Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'A':
      case 'ACTIVE':
        return assetActive; // Light Blue
      case 'I':
      case 'INACTIVE':
        return assetInactive; // Orange
      case 'C':
      case 'CREATED':
        return assetCreated; // Purple-blue
      case 'CHECKED':
        return assetChecked; // Light Blue
      default:
        return textSecondary;
    }
  }

  static Color getStatusColorWithOpacity(String status, double opacity) {
    return getStatusColor(status).withOpacity(opacity);
  }

  static Color getTrendColor(String trend) {
    switch (trend.toLowerCase()) {
      case 'up':
        return trendUp; // Light Blue
      case 'down':
        return trendDown; // Red
      case 'stable':
        return trendStable; // Gray
      default:
        return trendStable;
    }
  }

  static Color getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'error':
        return error;
      case 'warning':
        return warning;
      case 'info':
        return info;
      case 'success':
        return success;
      default:
        return info;
    }
  }

  static List<Color> get chartPalette => [
    chartBlue,
    vibrantOrange,
    chartGreen,
    vibrantPurple,
    chartTeal,
    chartAmber,
    chartRed,
  ];

  static List<Color> get vibrantPalette => [
    vibrantOrange,
    vibrantBlue,
    vibrantPurple,
    chartTeal,
    chartAmber,
  ];

  static List<Color> get assetStatusColors => [
    assetActive, // Light Blue
    assetInactive, // Orange
    assetCreated, // Purple-blue
    assetChecked, // Light Blue
  ];

  static Map<String, Color> get lightScheme => {
    'primary': primary,
    'background': background,
    'surface': surface,
    'onPrimary': onPrimary,
    'onBackground': onBackground,
    'onSurface': textPrimary,
  };

  // Updated Dark Scheme with lighter blue-gray colors
  static Map<String, Color> get darkScheme => {
    'primary': primary,
    'background': darkBackground, // Blue-tinted Gray
    'surface': darkSurface, // Medium Blue-Gray
    'navigation': darkNavigation, // Keep navy for navigation
    'onPrimary': onPrimary,
    'onBackground': darkText, // Light blue-tinted text
    'onSurface': darkText, // Light blue-tinted text
  };

  static List<LinearGradient> get modernGradients => [
    primaryGradient,
    vibrantOrangeGradient,
    vibrantBlueGradient,
    vibrantPurpleGradient,
    sunsetGradient,
    oceanGradient,
  ];

  static Color getRandomVibrantColor() {
    final colors = vibrantPalette;
    return colors[DateTime.now().millisecondsSinceEpoch % colors.length];
  }

  static Color getComplementaryColor(Color color) {
    if (color == vibrantOrange) return vibrantBlue;
    if (color == vibrantBlue) return vibrantPurple;
    if (color == vibrantPurple) return vibrantOrange;
    return primary;
  }

  // Dark Theme Helper Methods - Updated with lighter blue-gray tones
  static Color getDarkSurfaceColor(int level) {
    switch (level) {
      case 0:
        return darkBackground; // Blue-tinted Gray - Base background
      case 1:
        return darkSurface; // Medium Blue-Gray - Cards, surfaces
      case 2:
        return darkSurfaceVariant; // Light Blue-Gray - Elevated surfaces
      case 3:
        return darkSecondary; // Blue-Gray - Secondary surfaces
      default:
        return darkSurface;
    }
  }

  static Color getDarkTextColor(int level) {
    switch (level) {
      case 0:
        return darkText; // Light blue-tinted text - Primary text
      case 1:
        return darkTextSecondary; // Medium blue-gray - Secondary text
      case 2:
        return darkTextMuted; // Muted blue-gray - Muted text
      default:
        return darkText;
    }
  }
}
