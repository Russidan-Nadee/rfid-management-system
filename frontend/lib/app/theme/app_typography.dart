// Path: frontend/lib/app/theme/app_typography.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Font family configuration for local fonts
  static const String _englishFont = 'Inter';
  static const String _thaiFont = 'Kanit';
  static const String _japaneseFont = 'Noto Sans JP';
  static const List<String> _fontFamilyFallback = [
    _englishFont,
    _thaiFont,
    _japaneseFont,
    'Roboto',
  ];
  
  // Adjusted fallback for Japanese with medium weight
  static const List<String> _japaneseFontFallback = [
    _japaneseFont,
    _englishFont,
    _thaiFont,
    'Roboto',
  ];


  // Modern Typography Scale - Better hierarchy
  static const TextStyle display1 = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.0,
    height: 1.1,
    fontFamilyFallback: _fontFamilyFallback,
  );

  static const TextStyle display2 = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    height: 1.15,
    fontFamilyFallback: _fontFamilyFallback,
  );

  static const TextStyle display3 = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    height: 1.2,
    fontFamilyFallback: _fontFamilyFallback,
  );

  // Headlines - Enhanced contrast
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    height: 1.2,
    fontFamilyFallback: _fontFamilyFallback,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.25,
    fontFamilyFallback: _fontFamilyFallback,
  );

  static const TextStyle headline3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
    fontFamilyFallback: _fontFamilyFallback,
  );

  static const TextStyle headline4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.35,
    fontFamilyFallback: _fontFamilyFallback,
  );

  static const TextStyle headline5 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.4,
    fontFamilyFallback: _fontFamilyFallback,
  );

  static const TextStyle headline6 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.4,
    fontFamilyFallback: _fontFamilyFallback,
  );

  // Subtitles - Better readability
  static const TextStyle subtitle1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.5,
    fontFamilyFallback: _fontFamilyFallback,
  );

  static const TextStyle subtitle2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.25,
    height: 1.4,
    fontFamilyFallback: _fontFamilyFallback,
  );

  // Body text - Optimized for readability
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.1,
    height: 1.6,
    fontFamilyFallback: _fontFamilyFallback,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 1.5,
    fontFamilyFallback: _fontFamilyFallback,
  );

  static const TextStyle body3 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.4,
    fontFamilyFallback: _fontFamilyFallback,
  );

  // Labels and captions
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.3,
    fontFamilyFallback: _fontFamilyFallback,
  );

  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    height: 1.6,
    fontFamilyFallback: _fontFamilyFallback,
  );

  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.8,
    height: 1.4,
    fontFamilyFallback: _fontFamilyFallback,
  );

  // Button styles - Enhanced
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.2,
    fontFamilyFallback: _fontFamilyFallback,
  );

  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.25,
    fontFamilyFallback: _fontFamilyFallback,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    height: 1.2,
    fontFamilyFallback: _fontFamilyFallback,
  );

  // Dashboard specific styles - Enhanced hierarchy
  static const TextStyle dashboardTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.2,
    color: AppColors.textPrimary,
    fontFamilyFallback: _fontFamilyFallback,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
    color: AppColors.textPrimary,
    fontFamilyFallback: _fontFamilyFallback,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.25,
    height: 1.4,
    color: AppColors.textSecondary,
    fontFamilyFallback: _fontFamilyFallback,
  );

  // Statistics and numbers - Better emphasis
  static const TextStyle statValue = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
    height: 1.1,
    color: AppColors.textPrimary,
    fontFamilyFallback: _fontFamilyFallback,
  );

  static const TextStyle statValueLarge = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.0,
    height: 1.0,
    color: AppColors.textPrimary,
    fontFamilyFallback: _fontFamilyFallback,
  );

  static const TextStyle statLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    height: 1.3,
    color: AppColors.textSecondary,
    fontFamilyFallback: _fontFamilyFallback,
  );

  static const TextStyle statChange = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.2,
    fontFamilyFallback: _fontFamilyFallback,
  );

  // Chart and data visualization
  static const TextStyle chartLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    height: 1.2,
    color: AppColors.textSecondary,
    fontFamilyFallback: _fontFamilyFallback,
  );

  static const TextStyle chartValue = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.2,
    color: AppColors.textPrimary,
    fontFamilyFallback: _fontFamilyFallback,
  );

  // Filter and navigation
  static const TextStyle filterLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.2,
    color: AppColors.textSecondary,
    fontFamilyFallback: _fontFamilyFallback,
  );

  static const TextStyle filterLabelSelected = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1.2,
    color: AppColors.primary,
    fontFamilyFallback: _fontFamilyFallback,
  );

  static const TextStyle navigationLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    height: 1.2,
    color: AppColors.textSecondary,
    fontFamilyFallback: _fontFamilyFallback,
  );

  // Form and input styles
  static const TextStyle inputLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.0,
    height: 1.4,
    color: AppColors.textPrimary,
    fontFamilyFallback: _fontFamilyFallback,
  );

  static const TextStyle inputText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.05,
    height: 1.5,
    color: AppColors.textPrimary,
    fontFamilyFallback: _fontFamilyFallback,
  );

  static const TextStyle inputHint = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.5,
    color: AppColors.textTertiary,
    fontFamilyFallback: _fontFamilyFallback,
  );

  static const TextStyle inputError = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.3,
    color: AppColors.error,
    fontFamilyFallback: _fontFamilyFallback,
  );

  static const TextStyle inputHelper = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.3,
    color: AppColors.textSecondary,
    fontFamilyFallback: _fontFamilyFallback,
  );

  // Semantic styles with enhanced colors
  static TextStyle get primaryText =>
      body1.copyWith(color: AppColors.textPrimary);
  static TextStyle get secondaryText =>
      body2.copyWith(color: AppColors.textSecondary);
  static TextStyle get tertiaryText =>
      caption.copyWith(color: AppColors.textTertiary);
  static TextStyle get mutedText =>
      caption.copyWith(color: AppColors.textMuted);
  static TextStyle get hintText =>
      caption.copyWith(color: AppColors.textTertiary);

  // Status text styles
  static TextStyle get successText =>
      body2.copyWith(color: AppColors.success, fontWeight: FontWeight.w500);

  static TextStyle get warningText =>
      body2.copyWith(color: AppColors.warning, fontWeight: FontWeight.w500);

  static TextStyle get errorText =>
      body2.copyWith(color: AppColors.error, fontWeight: FontWeight.w500);

  static TextStyle get infoText =>
      body2.copyWith(color: AppColors.info, fontWeight: FontWeight.w500);

  // Link styles
  static TextStyle get link => body2.copyWith(
    color: AppColors.primary,
    fontWeight: FontWeight.w500,
    decoration: TextDecoration.underline,
    decorationColor: AppColors.primary,
  );

  static TextStyle get linkHover => link.copyWith(
    color: AppColors.primaryDark,
    decorationColor: AppColors.primaryDark,
  );

  // Badge and chip styles
  static const TextStyle badge = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
    color: AppColors.onPrimary,
    fontFamilyFallback: _fontFamilyFallback,
  );

  static const TextStyle chip = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.2,
    fontFamilyFallback: _fontFamilyFallback,
  );

  // Responsive text helper
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

    return style.copyWith(fontSize: (style.fontSize ?? 14) * factor);
  }

  // Font weight helpers
  static TextStyle thin(TextStyle style) =>
      style.copyWith(fontWeight: FontWeight.w100);
  static TextStyle light(TextStyle style) =>
      style.copyWith(fontWeight: FontWeight.w300);
  static TextStyle regular(TextStyle style) =>
      style.copyWith(fontWeight: FontWeight.w400);
  static TextStyle medium(TextStyle style) =>
      style.copyWith(fontWeight: FontWeight.w500);
  static TextStyle semiBold(TextStyle style) =>
      style.copyWith(fontWeight: FontWeight.w600);
  static TextStyle bold(TextStyle style) =>
      style.copyWith(fontWeight: FontWeight.w700);
  static TextStyle extraBold(TextStyle style) =>
      style.copyWith(fontWeight: FontWeight.w800);

  // Color helpers
  static TextStyle colored(TextStyle style, Color color) =>
      style.copyWith(color: color);

  // Japanese text optimization - use medium weight and adjusted spacing
  static TextStyle forJapanese(TextStyle style) => style.copyWith(
    fontWeight: FontWeight.w500, // Medium weight for better visibility
    letterSpacing: (style.letterSpacing ?? 0) + 0.2, // Slightly more spacing
    fontFamilyFallback: _japaneseFontFallback,
  );

  // Multi-language text helpers
  static TextStyle forLanguage(TextStyle style, String languageCode) {
    switch (languageCode) {
      case 'ja':
        return forJapanese(style);
      case 'th':
        return style.copyWith(
          letterSpacing: (style.letterSpacing ?? 0) - 0.1, // Tighter for Thai
        );
      default:
        return style; // English uses default
    }
  }

  // Theme data for Material Design
  static TextTheme get lightTextTheme => TextTheme(
    displayLarge: display1.copyWith(color: AppColors.textPrimary),
    displayMedium: display2.copyWith(color: AppColors.textPrimary),
    displaySmall: display3.copyWith(color: AppColors.textPrimary),
    headlineLarge: headline1.copyWith(color: AppColors.textPrimary),
    headlineMedium: headline2.copyWith(color: AppColors.textPrimary),
    headlineSmall: headline3.copyWith(color: AppColors.textPrimary),
    titleLarge: headline4.copyWith(color: AppColors.textPrimary),
    titleMedium: headline5.copyWith(color: AppColors.textPrimary),
    titleSmall: headline6.copyWith(color: AppColors.textPrimary),
    bodyLarge: body1.copyWith(color: AppColors.textPrimary),
    bodyMedium: body2.copyWith(color: AppColors.textPrimary),
    bodySmall: body3.copyWith(color: AppColors.textSecondary),
    labelLarge: button.copyWith(color: AppColors.textPrimary),
    labelMedium: caption.copyWith(color: AppColors.textSecondary),
    labelSmall: overline.copyWith(color: AppColors.textTertiary),
  );

  static TextTheme get darkTextTheme =>
      lightTextTheme.apply(bodyColor: Colors.white, displayColor: Colors.white);
}
