// Path: frontend/lib/app/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Modern Blue Gradient
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primarySurface = Color(0xFFEFF6FF);

  // Background - Modern layered approach
  static const Color background = Color(0xFFFAFAFC);
  static const Color backgroundSecondary = Color(0xFFF1F5F9);
  static const Color backgroundTertiary = Color(0xFFE2E8F0);

  // Surface - Enhanced depth
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFF8FAFC);

  // Text - Better hierarchy
  static const Color onPrimary = Colors.white;
  static const Color onBackground = Color(0xFF0F172A);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFFCBD5E1);

  // Status Colors - More vibrant
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF047857);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFD97706);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFDC2626);

  static const Color info = Color(0xFF06B6D4);
  static const Color infoLight = Color(0xFFCFFAFE);
  static const Color infoDark = Color(0xFF0891B2);

  // Asset Status Colors - Enhanced contrast
  static const Color assetActive = Color(0xFF10B981);
  static const Color assetInactive = Color(0xFFF59E0B);
  static const Color assetCreated = Color(0xFF06B6D4);
  static const Color assetChecked = Color(0xFF10B981);

  // Trend Colors
  static const Color trendUp = Color(0xFF10B981);
  static const Color trendDown = Color(0xFFEF4444);
  static const Color trendStable = Color(0xFF6B7280);

  // Chart Colors - Modern palette
  static const Color chartGreen = Color(0xFF10B981);
  static const Color chartRed = Color(0xFFEF4444);
  static const Color chartBlue = Color(0xFF3B82F6);
  static const Color chartOrange = Color(0xFFF59E0B);
  static const Color chartPurple = Color(0xFF8B5CF6);
  static const Color chartTeal = Color(0xFF06B6D4);
  static const Color chartPink = Color(0xFFEC4899);

  // UI Helper Colors - Modern approach
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFE2E8F0);
  static const Color dividerLight = Color(0xFFF1F5F9);

  // Interactive States
  static const Color selected = primary;
  static const Color unselected = textSecondary;
  static Color hover = primary.withOpacity(0.08);
  static Color pressed = primary.withOpacity(0.12);
  static Color focus = primary.withOpacity(0.12);
  static Color disabled = textMuted.withOpacity(0.38);

  // Gradients - Modern depth
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, backgroundSecondary],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [surface, surfaceContainer],
  );

  // Helper Methods
  static Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'A':
      case 'ACTIVE':
        return assetActive;
      case 'I':
      case 'INACTIVE':
        return assetInactive;
      case 'C':
      case 'CREATED':
        return assetCreated;
      case 'CHECKED':
        return assetChecked;
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
        return trendUp;
      case 'down':
        return trendDown;
      case 'stable':
        return trendStable;
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

  // Chart Color Palette - Enhanced
  static List<Color> get chartPalette => [
    chartBlue,
    chartGreen,
    chartOrange,
    chartPurple,
    chartTeal,
    chartPink,
    chartRed,
  ];

  // Asset Status Colors for Charts
  static List<Color> get assetStatusColors => [
    assetActive,
    assetInactive,
    assetCreated,
    assetChecked,
  ];

  // Modern Color Schemes
  static Map<String, Color> get lightScheme => {
    'primary': primary,
    'background': background,
    'surface': surface,
    'onPrimary': onPrimary,
    'onBackground': onBackground,
    'onSurface': textPrimary,
  };

  static Map<String, Color> get darkScheme => {
    'primary': primaryLight,
    'background': const Color(0xFF0F172A),
    'surface': const Color(0xFF1E293B),
    'onPrimary': onPrimary,
    'onBackground': const Color(0xFFF8FAFC),
    'onSurface': const Color(0xFFE2E8F0),
  };
}
