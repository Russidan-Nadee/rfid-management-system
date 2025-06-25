// Path: frontend/lib/core/constants/app_decorations.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_constants.dart';

class AppShadows {
  // Base Shadows
  static const List<BoxShadow> none = [];

  static const List<BoxShadow> small = [
    BoxShadow(
      color: Color(0x1A000000), // Black with 10% opacity
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x1F000000), // Black with 12% opacity
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> large = [
    BoxShadow(
      color: Color(0x29000000), // Black with 16% opacity
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x33000000), // Black with 20% opacity
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  // Elevated Shadows (for floating elements)
  static const List<BoxShadow> elevated = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x0F000000), blurRadius: 16, offset: Offset(0, 8)),
  ];

  // Colored Shadows
  static List<BoxShadow> primary = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.2),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> success = [
    BoxShadow(
      color: AppColors.success.withOpacity(0.2),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> error = [
    BoxShadow(
      color: AppColors.error.withOpacity(0.2),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
}

class AppBorders {
  // Border Radius
  static const BorderRadius noRadius = BorderRadius.zero;
  static const BorderRadius small = BorderRadius.all(Radius.circular(4));
  static const BorderRadius medium = BorderRadius.all(Radius.circular(8));
  static const BorderRadius large = BorderRadius.all(Radius.circular(12));
  static const BorderRadius xl = BorderRadius.all(Radius.circular(16));
  static const BorderRadius circular = BorderRadius.all(Radius.circular(8));

  // Custom Radius
  static BorderRadius custom(double radius) =>
      BorderRadius.all(Radius.circular(radius));

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

  // Border Sides
  static const BorderSide noBorder = BorderSide.none;
  static const BorderSide thin = BorderSide(
    color: AppColors.cardBorder,
    width: 1,
  );
  static const BorderSide thick = BorderSide(
    color: AppColors.cardBorder,
    width: 2,
  );

  static BorderSide colored(Color color, {double width = 1}) =>
      BorderSide(color: color, width: width);

  // Borders
  static const Border allBorders = Border.fromBorderSide(thin);
  static const Border allThick = Border.fromBorderSide(thick);

  static Border primary = Border.all(color: AppColors.primary);
  static Border success = Border.all(color: AppColors.success);
  static Border error = Border.all(color: AppColors.error);
}

class AppDecorations {
  // Card Decorations
  static BoxDecoration get card => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.large,
    border: AppBorders.allBorders,
    boxShadow: AppShadows.medium,
  );

  static BoxDecoration get cardElevated => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.large,
    boxShadow: AppShadows.elevated,
  );

  static BoxDecoration get cardFlat => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.large,
    border: AppBorders.allBorders,
  );

  // Dashboard Specific Cards
  static BoxDecoration get dashboardCard => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.large,
    border: Border.all(color: AppColors.cardBorder),
    boxShadow: AppShadows.medium,
  );

  static BoxDecoration get summaryCard => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.xl,
    boxShadow: AppShadows.large,
  );

  // Input Decorations
  static BoxDecoration get input => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.medium,
    border: AppBorders.allBorders,
  );

  static BoxDecoration get inputFocused => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.medium,
    border: AppBorders.primary,
  );

  static BoxDecoration get inputError => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.medium,
    border: AppBorders.error,
  );

  // Button Decorations
  static BoxDecoration get buttonPrimary => BoxDecoration(
    color: AppColors.primary,
    borderRadius: AppBorders.medium,
    boxShadow: AppShadows.small,
  );

  static BoxDecoration get buttonSecondary => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.medium,
    border: AppBorders.primary,
  );

  static BoxDecoration get buttonFlat =>
      BoxDecoration(color: Colors.transparent, borderRadius: AppBorders.medium);

  // Status Decorations
  static BoxDecoration success = BoxDecoration(
    color: AppColors.successLight,
    borderRadius: AppBorders.medium,
    border: Border.all(color: AppColors.success.withOpacity(0.3)),
  );

  static BoxDecoration warning = BoxDecoration(
    color: AppColors.warningLight,
    borderRadius: AppBorders.medium,
    border: Border.all(color: AppColors.warning.withOpacity(0.3)),
  );

  static BoxDecoration error = BoxDecoration(
    color: AppColors.errorLight,
    borderRadius: AppBorders.medium,
    border: Border.all(color: AppColors.error.withOpacity(0.3)),
  );

  static BoxDecoration info = BoxDecoration(
    color: AppColors.infoLight,
    borderRadius: AppBorders.medium,
    border: Border.all(color: AppColors.info.withOpacity(0.3)),
  );

  // Gradient Decorations
  static BoxDecoration get primaryGradient => BoxDecoration(
    gradient: LinearGradient(
      colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: AppBorders.medium,
  );

  // Modal/Dialog Decorations
  static BoxDecoration get modal => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.large,
    boxShadow: AppShadows.xl,
  );

  static BoxDecoration get bottomSheet => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppBorders.only(topLeft: 16, topRight: 16),
  );

  // Filter/Chip Decorations
  static BoxDecoration get chip => BoxDecoration(
    color: AppColors.backgroundSecondary,
    borderRadius: AppBorders.medium,
    border: AppBorders.allBorders,
  );

  static BoxDecoration get chipSelected => BoxDecoration(
    color: AppColors.primary.withOpacity(0.1),
    borderRadius: AppBorders.medium,
    border: Border.all(color: AppColors.primary),
  );

  // Loading/Skeleton Decorations
  static BoxDecoration get skeleton => BoxDecoration(
    color: AppColors.backgroundSecondary,
    borderRadius: AppBorders.small,
  );

  // Custom Decoration Builder
  static BoxDecoration custom({
    Color? color,
    BorderRadius? borderRadius,
    Border? border,
    List<BoxShadow>? boxShadow,
    Gradient? gradient,
  }) => BoxDecoration(
    color: color,
    borderRadius: borderRadius,
    border: border,
    boxShadow: boxShadow,
    gradient: gradient,
  );

  // Hover Effects (for web/desktop)
  static BoxDecoration hover(BoxDecoration base) =>
      base.copyWith(boxShadow: AppShadows.large);

  // Theme-aware decorations
  static BoxDecoration cardForTheme(ThemeData theme) => BoxDecoration(
    color: theme.cardColor,
    borderRadius: AppBorders.large,
    border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
    boxShadow: theme.brightness == Brightness.light
        ? AppShadows.medium
        : AppShadows.none,
  );
}
