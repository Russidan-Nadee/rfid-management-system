// Path: frontend/lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color.fromARGB(255, 80, 131, 211);
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onPrimary = Colors.white;
  static const Color onBackground = Color(0xFF1F2937);

  // Status Colors (Dashboard specific)
  static final Color success = Color.fromARGB(255, 30, 180, 60); // Green 500
  static const Color successLight = Color(0xFFD1FAE5); // Green 100
  static const Color warning = Color(0xFFF59E0B); // Orange 500
  static const Color warningLight = Color(0xFFFEF3C7); // Orange 100
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color errorLight = Color(0xFFFEE2E2); // Red 100
  static const Color info = Color(0xFF3B82F6); // Blue 500
  static const Color infoLight = Color(0xFFDDEAFE); // Blue 100
  static const Color DarkBlue = Color.fromARGB(255, 9, 49, 122);

  // Asset Status Colors
  static const Color assetActive = Color.fromARGB(
    255,
    30,
    180,
    60,
  ); // Green - Active assets
  static const Color assetInactive = Color(
    0xFFF59E0B,
  ); // Orange - Inactive assets
  static const Color assetCreated = Color(0xFF3B82F6); // Blue - Created assets
  static const Color assetChecked = Color.fromARGB(
    255,
    30,
    180,
    60,
  ); // Green - Checked assets

  // Trend Colors
  static const Color trendUp = Color.fromARGB(
    255,
    30,
    180,
    60,
  ); // Green - Positive trend
  static const Color trendDown = Color(0xFFEF4444); // Red - Negative trend
  static const Color trendStable = Color(0xFF6B7280); // Gray - Stable trend

  // Chart Colors
  static const Color chartGreen = Color.fromARGB(255, 30, 180, 60);
  static const Color chartRed = Color(0xFFEF4444);
  static const Color chartBlue = Color(0xFF3B82F6);
  static const Color chartOrange = Color(0xFFF59E0B);
  static const Color chartPurple = Color(0xFF8B5CF6);

  // Export Status Colors
  static const Color exportPending = Color(0xFFF59E0B); // Orange
  static const Color exportCompleted = Color.fromARGB(
    255,
    30,
    180,
    60,
  ); // Green
  static const Color exportFailed = Color(0xFFEF4444); // Red

  // Severity Colors (Alerts)
  static const Color severityError = Color(0xFFEF4444); // Red
  static const Color severityWarning = Color(0xFFF59E0B); // Orange
  static const Color severityInfo = Color(0xFF3B82F6); // Blue

  // UI Helper Colors
  static const Color cardBorder = Color(0xFFE5E7EB); // Gray 200
  static const Color divider = Color(0xFFE5E7EB); // Gray 200
  static const Color textSecondary = Color(0xFF6B7280); // Gray 500
  static const Color textTertiary = Color(0xFF9CA3AF); // Gray 400

  // Background Variants
  static const Color backgroundSecondary = Color(0xFFF3F4F6); // Gray 100
  static const Color backgroundTertiary = Color(0xFFE5E7EB); // Gray 200

  // UI State Colors
  static const Color selected = primary;
  static const Color unselected = textSecondary;
  static Color hover = primary.withOpacity(0.1);

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

  static Color getExportStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'P':
      case 'PENDING':
        return exportPending;
      case 'C':
      case 'COMPLETED':
        return exportCompleted;
      case 'F':
      case 'FAILED':
        return exportFailed;
      default:
        return textSecondary;
    }
  }

  static Color getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'error':
        return severityError;
      case 'warning':
        return severityWarning;
      case 'info':
        return severityInfo;
      default:
        return severityInfo;
    }
  }

  // เพิ่ม Filter Color Helper
  static Color getFilterColor(String filter) {
    switch (filter.toLowerCase()) {
      case 'all':
        return primary;
      case 'active':
        return assetActive;
      case 'checked':
        return assetChecked;
      case 'inactive':
        return assetInactive;
      case 'unknown':
        return error;
      default:
        return primary;
    }
  }

  // Chart Color Palette
  static List<Color> get chartPalette => [
    chartGreen,
    chartRed,
    chartBlue,
    chartOrange,
    chartPurple,
  ];

  // Asset Status Pie Chart Colors
  static List<Color> get assetStatusPieColors => [
    assetActive, // Active
    assetInactive, // Inactive
    assetCreated, // Created
  ];
}
