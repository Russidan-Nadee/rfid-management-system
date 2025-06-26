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
      blurRadius: 4,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> small = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 6,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x06000000),
      blurRadius: 2,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 4,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> large = [
    BoxShadow(
      color: Color(0x15000000),
      blurRadius: 20,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x19000000),
      blurRadius: 32,
      offset: Offset(0, 12),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 16,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  // Special shadow effects
  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 24,
      offset: Offset(0, 16),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 8,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  // Colored shadows for interactive elements
  static List<BoxShadow> primary = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.15),
      blurRadius: 12,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> success = [
    BoxShadow(
      color: AppColors.success.withOpacity(0.15),
      blurRadius: 12,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> error = [
    BoxShadow(
      color: AppColors.error.withOpacity(0.15),
      blurRadius: 12,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
}

class AppBorders {
  // Modern border radius - More rounded
  static const BorderRadius noRadius = BorderRadius.zero;
  static const BorderRadius xs = BorderRadius.all(
    Radius.circular(AppSpacing.radiusXS),
  );
  static const BorderRadius sm = BorderRadius.all(
    Radius.circular(AppSpacing.radiusSM),
  );
  static const BorderRadius md = BorderRadius.all(
    Radius.circular(AppSpacing.radiusMD),
  );
  static const BorderRadius lg = BorderRadius.all(
    Radius.circular(AppSpacing.radiusLG),
  );
  static const BorderRadius xl = BorderRadius.all(
    Radius.circular(AppSpacing.radiusXL),
  );
  static const BorderRadius xxl = BorderRadius.all(
    Radius.circular(AppSpacing.radiusXXL),
  );
  static const BorderRadius xxxl = BorderRadius.all(
    Radius.circular(AppSpacing.radiusXXXL),
  );

  // Legacy support
  static const BorderRadius small = sm;
  static const BorderRadius medium = md;
  static const BorderRadius large = lg;
  static const BorderRadius circular = md;

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
  // Modern card decorations
  static BoxDecoration get card => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.lg,
    border: AppBorders.allSubtle,
    boxShadow: AppShadows.small,
  );

  static BoxDecoration get cardElevated => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.lg,
    boxShadow: AppShadows.medium,
  );

  static BoxDecoration get cardFlat => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.lg,
    border: AppBorders.allSubtle,
  );

  static BoxDecoration get cardFloating => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.xl,
    boxShadow: AppShadows.floating,
  );

  // Dashboard specific cards - Enhanced
  static BoxDecoration get dashboardCard => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.lg,
    border: AppBorders.allSubtle,
    boxShadow: AppShadows.small,
  );

  static BoxDecoration get summaryCard => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.xl,
    boxShadow: AppShadows.medium,
  );

  static BoxDecoration get statsCard => BoxDecoration(
    gradient: AppColors.cardGradient,
    borderRadius: AppBorders.lg,
    boxShadow: AppShadows.small,
  );

  // Input decorations - Modern styling
  static BoxDecoration get input => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.md,
    border: AppBorders.allSubtle,
  );

  static BoxDecoration get inputFocused => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.md,
    border: Border.all(color: AppColors.primary, width: 2),
    boxShadow: AppShadows.primary,
  );

  static BoxDecoration get inputError => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.md,
    border: Border.all(color: AppColors.error, width: 2),
    boxShadow: AppShadows.error,
  );

  // Button decorations - Enhanced
  static BoxDecoration get buttonPrimary => BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: AppBorders.md,
    boxShadow: AppShadows.primary,
  );

  static BoxDecoration get buttonSecondary => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.md,
    border: AppBorders.primary,
    boxShadow: AppShadows.subtle,
  );

  static BoxDecoration get buttonFlat =>
      BoxDecoration(color: Colors.transparent, borderRadius: AppBorders.md);

  static BoxDecoration get buttonFloating => BoxDecoration(
    color: AppColors.primary,
    borderRadius: AppBorders.pill,
    boxShadow: AppShadows.floating,
  );

  // Status decorations - Modern approach
  static BoxDecoration success = BoxDecoration(
    color: AppColors.successLight,
    borderRadius: AppBorders.md,
    border: Border.all(color: AppColors.success.withOpacity(0.2)),
    boxShadow: AppShadows.success,
  );

  static BoxDecoration warning = BoxDecoration(
    color: AppColors.warningLight,
    borderRadius: AppBorders.md,
    border: Border.all(color: AppColors.warning.withOpacity(0.2)),
  );

  static BoxDecoration error = BoxDecoration(
    color: AppColors.errorLight,
    borderRadius: AppBorders.md,
    border: Border.all(color: AppColors.error.withOpacity(0.2)),
    boxShadow: AppShadows.error,
  );

  static BoxDecoration info = BoxDecoration(
    color: AppColors.infoLight,
    borderRadius: AppBorders.md,
    border: Border.all(color: AppColors.info.withOpacity(0.2)),
  );

  // Gradient decorations - Modern depth
  static BoxDecoration get primaryGradient => BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: AppBorders.md,
    boxShadow: AppShadows.primary,
  );

  static BoxDecoration get backgroundGradient =>
      BoxDecoration(gradient: AppColors.backgroundGradient);

  // Modal/Dialog decorations - Enhanced
  static BoxDecoration get modal => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.xl,
    boxShadow: AppShadows.xl,
  );

  static BoxDecoration get bottomSheet => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.only(
      topLeft: AppSpacing.radiusXL,
      topRight: AppSpacing.radiusXL,
    ),
    boxShadow: AppShadows.large,
  );

  // Filter/Chip decorations - Modern
  static BoxDecoration get chip => BoxDecoration(
    color: AppColors.backgroundSecondary,
    borderRadius: AppBorders.pill,
    border: AppBorders.allSubtle,
  );

  static BoxDecoration get chipSelected => BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: AppBorders.pill,
    boxShadow: AppShadows.primary,
  );

  static BoxDecoration get chipOutlined => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.pill,
    border: AppBorders.primary,
  );

  // Loading/Skeleton decorations
  static BoxDecoration get skeleton => BoxDecoration(
    color: AppColors.backgroundSecondary,
    borderRadius: AppBorders.sm,
  );

  static BoxDecoration get skeletonShimmer => BoxDecoration(
    gradient: LinearGradient(
      colors: [
        AppColors.backgroundSecondary,
        AppColors.backgroundTertiary,
        AppColors.backgroundSecondary,
      ],
      stops: const [0.4, 0.5, 0.6],
    ),
    borderRadius: AppBorders.sm,
  );

  // Interactive states
  static BoxDecoration hover(BoxDecoration base) =>
      base.copyWith(boxShadow: AppShadows.medium);

  static BoxDecoration pressed(BoxDecoration base) =>
      base.copyWith(boxShadow: AppShadows.small);

  // Navigation decorations
  static BoxDecoration get navigationCard => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.lg,
    boxShadow: AppShadows.small,
  );

  static BoxDecoration get navigationSelected => BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: AppBorders.md,
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
    borderRadius: borderRadius ?? AppBorders.md,
    border: border,
    boxShadow: boxShadow,
  );

  // Theme-aware decorations
  static BoxDecoration cardForTheme(ThemeData theme) => BoxDecoration(
    color: theme.cardColor,
    borderRadius: AppBorders.lg,
    border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
    boxShadow: theme.brightness == Brightness.light
        ? AppShadows.small
        : AppShadows.none,
  );

  // Glass morphism effect
  static BoxDecoration get glassMorphism => BoxDecoration(
    color: AppColors.surface.withOpacity(0.8),
    borderRadius: AppBorders.lg,
    border: Border.all(color: AppColors.surface.withOpacity(0.2)),
    boxShadow: AppShadows.medium,
  );

  // Neumorphism effect
  static BoxDecoration get neumorphism => BoxDecoration(
    color: AppColors.backgroundSecondary,
    borderRadius: AppBorders.lg,
    boxShadow: const [
      BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(4, 4)),
      BoxShadow(
        color: Color(0xFFFFFFFF),
        blurRadius: 8,
        offset: Offset(-4, -4),
      ),
    ],
  );

  // Modern list item decoration
  static BoxDecoration get listItem => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.md,
    border: AppBorders.allSubtle,
  );

  static BoxDecoration get listItemSelected => BoxDecoration(
    color: AppColors.primarySurface,
    borderRadius: AppBorders.md,
    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
  );

  // Badge decorations
  static BoxDecoration get badge => BoxDecoration(
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
  static BoxDecoration get progressTrack => BoxDecoration(
    color: AppColors.backgroundSecondary,
    borderRadius: AppBorders.pill,
  );

  static BoxDecoration get progressFill => BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: AppBorders.pill,
    boxShadow: AppShadows.primary,
  );
}
