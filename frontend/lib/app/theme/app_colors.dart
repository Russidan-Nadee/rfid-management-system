import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Navy tone for buttons and headers
  static const Color primary = Color(0xFF1E3A5F);
  static const Color primaryLight = Color(0xFF2C4F7C);
  static const Color primaryDark = Color(0xFF0F1B2E);
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

  static const Color warning = Color(0xFFF59E0B); // ส้มเดิม
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
  static const Color vibrantGreen = Color(0xFF42A5F5); // Light Blue แทนเขียวสด
  static const Color vibrantGreenLight = Color(0xFFE3F2FD);
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
  static const Color chartGreen = Color(0xFF42A5F5); // Light Blue แทนเขียวสด
  static const Color chartOrange = Color(0xFFF59E0B);
  static const Color chartRed = Color(0xFFEF4444);
  static const Color chartPurple = Color(0xFF6366F1);
  static const Color chartTeal = Color(0xFF14B8A6);
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

  // Gradients - Updated
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

  static const LinearGradient vibrantGreenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF64B5F6), vibrantGreen], // Light blue gradient
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
    colors: [
      chartTeal,
      chartBlue,
      vibrantGreen,
    ], // ใช้ vibrantGreen ที่เป็น Light Blue
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
        return success; // Light Blue
      default:
        return info;
    }
  }

  static List<Color> get chartPalette => [
    chartBlue,
    vibrantOrange,
    chartGreen, // ยังใช้ชื่อเดิม
    vibrantPurple,
    chartTeal,
    chartAmber,
    chartRed,
  ];

  static List<Color> get vibrantPalette => [
    vibrantOrange,
    vibrantGreen, // ยังใช้ชื่อเดิม
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

  static Map<String, Color> get darkScheme => {
    'primary': primaryLight,
    'background': Color(0xFF0F172A),
    'surface': Color(0xFF1E293B),
    'onPrimary': onPrimary,
    'onBackground': Color(0xFFF8FAFC),
    'onSurface': Color(0xFFE2E8F0),
  };

  static List<LinearGradient> get modernGradients => [
    primaryGradient,
    vibrantOrangeGradient,
    vibrantGreenGradient, // ยังใช้ชื่อเดิม
    vibrantPurpleGradient,
    sunsetGradient,
    oceanGradient,
  ];

  static Color getRandomVibrantColor() {
    final colors = vibrantPalette;
    return colors[DateTime.now().millisecondsSinceEpoch % colors.length];
  }

  static Color getComplementaryColor(Color color) {
    if (color == vibrantOrange) return vibrantGreen; // ยังใช้ชื่อเดิม
    if (color == vibrantGreen) return vibrantPurple; // ยังใช้ชื่อเดิม
    if (color == vibrantPurple) return vibrantOrange;
    return primary;
  }
}
