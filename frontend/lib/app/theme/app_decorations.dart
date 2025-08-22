// Path: frontend/lib/app/theme/app_decorations.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

class AppShadows {
  // Modern shadow system - More depth and softness
  static const List<BoxShadow> none = [];

  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 6,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> small = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 10,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x06000000),
      blurRadius: 4,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 16,
      offset: Offset(0, 6),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 6,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> large = [
    BoxShadow(
      color: Color(0x15000000),
      blurRadius: 24,
      offset: Offset(0, 10),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 10,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x19000000),
      blurRadius: 40,
      offset: Offset(0, 16),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 20,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  // Special shadow effects
  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 32,
      offset: Offset(0, 20),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 12,
      offset: Offset(0, 6),
      spreadRadius: 0,
    ),
  ];

  // Colored shadows for interactive elements
  static List<BoxShadow> primary = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.2),
      blurRadius: 16,
      offset: const Offset(0, 6),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> success = [
    BoxShadow(
      color: AppColors.success.withValues(alpha: 0.2),
      blurRadius: 16,
      offset: const Offset(0, 6),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> error = [
    BoxShadow(
      color: AppColors.error.withValues(alpha: 0.2),
      blurRadius: 16,
      offset: const Offset(0, 6),
      spreadRadius: 0,
    ),
  ];

  // Vibrant shadows - NEW
  static List<BoxShadow> vibrantOrange = [
    BoxShadow(
      color: AppColors.vibrantOrange.withValues(alpha: 0.25),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> vibrantBlue = [
    BoxShadow(
      color: AppColors.vibrantBlue.withValues(alpha: 0.25),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];
}

class AppBorders {
  // Modern border radius - Much more rounded like the example app
  static const BorderRadius noRadius = BorderRadius.zero;
  static const BorderRadius xs = BorderRadius.all(
    Radius.circular(AppSpacing.radiusXS),
  );
  static const BorderRadius sm = BorderRadius.all(
    Radius.circular(AppSpacing.radiusSM),
  );
  static const BorderRadius md = BorderRadius.all(
    Radius.circular(16.0), // Increased from 8 to 16
  );
  static const BorderRadius lg = BorderRadius.all(
    Radius.circular(20.0), // Increased from 12 to 20
  );
  static const BorderRadius xl = BorderRadius.all(
    Radius.circular(24.0), // Increased from 16 to 24
  );
  static const BorderRadius xxl = BorderRadius.all(
    Radius.circular(28.0), // Increased from 20 to 28
  );
  static const BorderRadius xxxl = BorderRadius.all(
    Radius.circular(32.0), // Increased from 24 to 32
  );

  // Legacy support with new values
  static const BorderRadius small = md; // Now 16px
  static const BorderRadius medium = lg; // Now 20px
  static const BorderRadius large = xl; // Now 24px
  static const BorderRadius circular = lg;

  // Extra rounded for modern apps
  static const BorderRadius extraRounded = BorderRadius.all(
    Radius.circular(28.0),
  );
  static const BorderRadius superRounded = BorderRadius.all(
    Radius.circular(32.0),
  );

  // Pill shape
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));

  // Custom radius helpers
  static BorderRadius custom(double radius) => BorderRadius.circular(radius);

  static BorderRadius only({
    double? topLeft,
    double? topRight,
    double? bottomLeft,
    double? bottomRight,
  }) => BorderRadius.only(
    topLeft: Radius.circular(topLeft ?? 0),
    topRight: Radius.circular(topRight ?? 0),
    bottomLeft: Radius.circular(bottomLeft ?? 0),
    bottomRight: Radius.circular(bottomRight ?? 0),
  );

  // Border sides - Modern subtle borders
  static const BorderSide noBorder = BorderSide.none;
  static const BorderSide thin = BorderSide(
    color: AppColors.cardBorder,
    width: 1,
  );
  static const BorderSide thick = BorderSide(
    color: AppColors.cardBorder,
    width: 2,
  );
  static const BorderSide subtle = BorderSide(
    color: AppColors.dividerLight,
    width: 1,
  );

  static BorderSide colored(Color color, {double width = 1}) =>
      BorderSide(color: color, width: width);

  // Full borders
  static const Border all = Border.fromBorderSide(thin);
  static const Border allThick = Border.fromBorderSide(thick);
  static const Border allSubtle = Border.fromBorderSide(subtle);

  static const Border primary = Border.fromBorderSide(
    BorderSide(color: AppColors.primary),
  );
  static const Border success = Border.fromBorderSide(
    BorderSide(color: AppColors.success),
  );
  static const Border error = Border.fromBorderSide(
    BorderSide(color: AppColors.error),
  );
}

class AppDecorations {
  // Modern card decorations - Much more rounded
  static BoxDecoration get card => const BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.lg, // Now 20px
    border: AppBorders.allSubtle,
    boxShadow: AppShadows.small,
  );

  static BoxDecoration get cardElevated => const BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.xl, // Now 24px
    boxShadow: AppShadows.medium,
  );

  static BoxDecoration get cardFlat => const BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.lg, // Now 20px
    border: AppBorders.allSubtle,
  );

  static BoxDecoration get cardFloating => const BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.xxl, // Now 28px
    boxShadow: AppShadows.floating,
  );

  // Dashboard specific cards - Enhanced with modern radius
  static BoxDecoration get dashboardCard => const BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.lg, // Now 20px
    border: AppBorders.allSubtle,
    boxShadow: AppShadows.small,
  );

  static BoxDecoration get summaryCard => const BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.xl, // Now 24px
    boxShadow: AppShadows.medium,
  );

  static BoxDecoration get statsCard => const BoxDecoration(
    gradient: AppColors.cardGradient,
    borderRadius: AppBorders.lg, // Now 20px
    boxShadow: AppShadows.small,
  );

  // Vibrant card decorations - NEW
  static BoxDecoration get vibrantOrangeCard => BoxDecoration(
    gradient: AppColors.vibrantOrangeGradient,
    borderRadius: AppBorders.xl,
    boxShadow: AppShadows.vibrantOrange,
  );

  static BoxDecoration get vibrantBlueCard => BoxDecoration(
    gradient: AppColors.vibrantBlueGradient,
    borderRadius: AppBorders.xl,
    boxShadow: AppShadows.vibrantBlue,
  );

  static BoxDecoration get vibrantPurpleCard => BoxDecoration(
    gradient: AppColors.vibrantPurpleGradient,
    borderRadius: AppBorders.xl,
    boxShadow: AppShadows.primary,
  );

  // Input decorations - Modern styling with increased radius
  static BoxDecoration get input => const BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.md, // Now 16px
    border: AppBorders.allSubtle,
  );

  static BoxDecoration get inputFocused => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.md, // Now 16px
    border: Border.all(color: AppColors.primary, width: 2),
    boxShadow: AppShadows.primary,
  );

  static BoxDecoration get inputError => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.md, // Now 16px
    border: Border.all(color: AppColors.error, width: 2),
    boxShadow: AppShadows.error,
  );

  // Button decorations - Enhanced with modern radius
  static BoxDecoration get buttonPrimary => BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: AppBorders.md, // Now 16px
    boxShadow: AppShadows.primary,
  );

  static BoxDecoration get buttonSecondary => const BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.md, // Now 16px
    border: AppBorders.primary,
    boxShadow: AppShadows.subtle,
  );

  static BoxDecoration get buttonFlat =>
      const BoxDecoration(color: Colors.transparent, borderRadius: AppBorders.md);

  static BoxDecoration get buttonFloating => const BoxDecoration(
    color: AppColors.primary,
    borderRadius: AppBorders.pill,
    boxShadow: AppShadows.floating,
  );

  // Vibrant button decorations - NEW
  static BoxDecoration get buttonVibrantOrange => BoxDecoration(
    gradient: AppColors.vibrantOrangeGradient,
    borderRadius: AppBorders.md,
    boxShadow: AppShadows.vibrantOrange,
  );

  static BoxDecoration get buttonVibrantGreen => BoxDecoration(
    gradient: AppColors.vibrantBlueGradient,
    borderRadius: AppBorders.md,
    boxShadow: AppShadows.vibrantBlue,
  );

  // Status decorations - Modern approach with increased radius
  static BoxDecoration success = BoxDecoration(
    color: AppColors.successLight,
    borderRadius: AppBorders.md, // Now 16px
    border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
    boxShadow: AppShadows.success,
  );

  static BoxDecoration warning = BoxDecoration(
    color: AppColors.warningLight,
    borderRadius: AppBorders.md, // Now 16px
    border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
  );

  static BoxDecoration error = BoxDecoration(
    color: AppColors.errorLight,
    borderRadius: AppBorders.md, // Now 16px
    border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
    boxShadow: AppShadows.error,
  );

  static BoxDecoration info = BoxDecoration(
    color: AppColors.infoLight,
    borderRadius: AppBorders.md, // Now 16px
    border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
  );

  // Gradient decorations - Modern depth with increased radius
  static BoxDecoration get primaryGradient => BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: AppBorders.md, // Now 16px
    boxShadow: AppShadows.primary,
  );

  static BoxDecoration get backgroundGradient =>
      const BoxDecoration(gradient: AppColors.backgroundGradient);

  // Modern gradient collection - NEW
  static BoxDecoration get sunsetGradient => BoxDecoration(
    gradient: AppColors.sunsetGradient,
    borderRadius: AppBorders.xl,
    boxShadow: AppShadows.vibrantOrange,
  );

  static BoxDecoration get oceanGradient => BoxDecoration(
    gradient: AppColors.oceanGradient,
    borderRadius: AppBorders.xl,
    boxShadow: AppShadows.primary,
  );

  // Modal/Dialog decorations - Enhanced with increased radius
  static BoxDecoration get modal => const BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.xxl, // Now 28px
    boxShadow: AppShadows.xl,
  );

  static BoxDecoration get bottomSheet => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.only(
      topLeft: 28, // Increased
      topRight: 28, // Increased
    ),
    boxShadow: AppShadows.large,
  );

  // Filter/Chip decorations - Modern with increased radius
  static BoxDecoration get chip => const BoxDecoration(
    color: AppColors.backgroundSecondary,
    borderRadius: AppBorders.pill,
    border: AppBorders.allSubtle,
  );

  static BoxDecoration get chipSelected => BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: AppBorders.pill,
    boxShadow: AppShadows.primary,
  );

  static BoxDecoration get chipOutlined => const BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.pill,
    border: AppBorders.primary,
  );

  // Loading/Skeleton decorations
  static BoxDecoration get skeleton => const BoxDecoration(
    color: AppColors.backgroundSecondary,
    borderRadius: AppBorders.md, // Now 16px
  );

  static BoxDecoration get skeletonShimmer => const BoxDecoration(
    gradient: LinearGradient(
      colors: [
        AppColors.backgroundSecondary,
        AppColors.backgroundTertiary,
        AppColors.backgroundSecondary,
      ],
      stops: [0.4, 0.5, 0.6],
    ),
    borderRadius: AppBorders.md, // Now 16px
  );

  // Interactive states
  static BoxDecoration hover(BoxDecoration base) =>
      base.copyWith(boxShadow: AppShadows.medium);

  static BoxDecoration pressed(BoxDecoration base) =>
      base.copyWith(boxShadow: AppShadows.small);

  // Navigation decorations
  static BoxDecoration get navigationCard => const BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.lg, // Now 20px
    boxShadow: AppShadows.small,
  );

  static BoxDecoration get navigationSelected => BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: AppBorders.md, // Now 16px
    boxShadow: AppShadows.primary,
  );

  // Custom decoration builder
  static BoxDecoration custom({
    Color? color,
    Gradient? gradient,
    BorderRadius? borderRadius,
    Border? border,
    List<BoxShadow>? boxShadow,
  }) => BoxDecoration(
    color: color,
    gradient: gradient,
    borderRadius: borderRadius ?? AppBorders.md, // Default now 16px
    border: border,
    boxShadow: boxShadow,
  );

  // Theme-aware decorations
  static BoxDecoration cardForTheme(ThemeData theme) => BoxDecoration(
    color: theme.cardColor,
    borderRadius: AppBorders.lg, // Now 20px
    border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
    boxShadow: theme.brightness == Brightness.light
        ? AppShadows.small
        : AppShadows.none,
  );

  // Glass morphism effect - Enhanced
  static BoxDecoration get glassMorphism => BoxDecoration(
    color: AppColors.surface.withValues(alpha: 0.8),
    borderRadius: AppBorders.lg, // Now 20px
    border: Border.all(color: AppColors.surface.withValues(alpha: 0.2)),
    boxShadow: AppShadows.medium,
  );

  // Neumorphism effect - Enhanced
  static BoxDecoration get neumorphism => const BoxDecoration(
    color: AppColors.backgroundSecondary,
    borderRadius: AppBorders.lg, // Now 20px
    boxShadow: [
      BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(6, 6)),
      BoxShadow(
        color: Color(0xFFFFFFFF),
        blurRadius: 12,
        offset: Offset(-6, -6),
      ),
    ],
  );

  // Modern list item decoration
  static BoxDecoration get listItem => const BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.md, // Now 16px
    border: AppBorders.allSubtle,
  );

  static BoxDecoration get listItemSelected => BoxDecoration(
    color: AppColors.primarySurface,
    borderRadius: AppBorders.md, // Now 16px
    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
  );

  // Badge decorations
  static BoxDecoration get badge => const BoxDecoration(
    color: AppColors.primary,
    borderRadius: AppBorders.pill,
    boxShadow: AppShadows.subtle,
  );

  static BoxDecoration getBadgeColored(Color color) => BoxDecoration(
    color: color,
    borderRadius: AppBorders.pill,
    boxShadow: AppShadows.subtle,
  );

  // Progress bar decorations
  static BoxDecoration get progressTrack => const BoxDecoration(
    color: AppColors.backgroundSecondary,
    borderRadius: AppBorders.pill,
  );

  static BoxDecoration get progressFill => BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: AppBorders.pill,
    boxShadow: AppShadows.primary,
  );

  // Modern decoration collection for dashboard cards
  static List<BoxDecoration> get modernCardDecorations => [
    vibrantOrangeCard,
    vibrantBlueCard,
    vibrantPurpleCard,
    sunsetGradient,
    oceanGradient,
  ];

  // Get random modern decoration
  static BoxDecoration getRandomModernCard() {
    final decorations = modernCardDecorations;
    final index = DateTime.now().millisecondsSinceEpoch % decorations.length;
    return decorations[index];
  }

  // Modern card with custom gradient
  static BoxDecoration modernCard({
    required LinearGradient gradient,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
  }) => BoxDecoration(
    gradient: gradient,
    borderRadius: borderRadius ?? AppBorders.xl,
    boxShadow: boxShadow ?? AppShadows.medium,
  );

  // iOS-style card (like the example app)
  static BoxDecoration get iosStyleCard => const BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.xl, // 24px like iOS
    boxShadow: [
      BoxShadow(
        color: Color(0x0A000000),
        blurRadius: 20,
        offset: Offset(0, 8),
        spreadRadius: 0,
      ),
    ],
  );

  // Android Material 3 style card
  static BoxDecoration get material3Card => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.lg, // 20px
    border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5)),
    boxShadow: AppShadows.small,
  );
}
