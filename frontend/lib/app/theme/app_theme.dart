// Path: frontend/lib/app/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_decorations.dart';
import 'app_spacing.dart';

class AppTheme {
  // Light Theme - เก็บเดิมไม่แตะ
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Font Family
    fontFamily: 'Inter',
    fontFamilyFallback: const ['Kanit', 'Noto Sans JP', 'Roboto'],

    // Color Scheme
    colorScheme: lightColorScheme,

    // Scaffold
    scaffoldBackgroundColor: AppColors.background,

    // App Bar Theme
    appBarTheme: lightAppBarTheme,

    // Text Theme
    textTheme: AppTextStyles.lightTextTheme,

    // Component Themes
    elevatedButtonTheme: elevatedButtonTheme,
    outlinedButtonTheme: outlinedButtonTheme,
    textButtonTheme: textButtonTheme,

    cardTheme: cardTheme,
    inputDecorationTheme: inputDecorationTheme,
    dropdownMenuTheme: dropdownMenuTheme,

    // Dialog Theme
    dialogTheme: dialogTheme,
    bottomSheetTheme: bottomSheetTheme,

    // Chip Theme
    chipTheme: chipTheme,

    // Tab Bar Theme
    tabBarTheme: tabBarTheme,

    // Navigation Theme
    navigationBarTheme: navigationBarTheme,
    bottomNavigationBarTheme: bottomNavigationBarTheme,

    // Progress Indicator Theme
    progressIndicatorTheme: progressIndicatorTheme,

    // Divider Theme
    dividerTheme: dividerTheme,

    // Icon Theme
    iconTheme: lightIconTheme,
    primaryIconTheme: primaryIconTheme,

    // List Tile Theme
    listTileTheme: listTileTheme,

    // Switch & Checkbox Theme
    switchTheme: switchTheme,
    checkboxTheme: checkboxTheme,

    // Tooltip Theme
    tooltipTheme: tooltipTheme,

    // Snackbar Theme
    snackBarTheme: snackBarTheme,

    // Banner Theme
    bannerTheme: bannerTheme,
  );

  // Dark Theme - อัพเดทเป็นสีใหม่ทั้งหมด
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // Font Family
    fontFamily: 'Inter',
    fontFamilyFallback: const ['Kanit', 'Noto Sans JP', 'Roboto'],

    // Color Scheme - ใช้สีใหม่
    colorScheme: darkColorScheme,

    // Scaffold - Charcoal Gray background
    scaffoldBackgroundColor: AppColors.darkBackground,

    // App Bar Theme
    appBarTheme: darkAppBarTheme,

    // Text Theme
    textTheme: AppTextStyles.darkTextTheme,

    // Component Themes (adjusted for dark)
    elevatedButtonTheme: elevatedButtonTheme,
    outlinedButtonTheme: outlinedButtonTheme,
    textButtonTheme: textButtonTheme,

    cardTheme: darkCardTheme,
    inputDecorationTheme: darkInputDecorationTheme,
    dropdownMenuTheme: darkDropdownMenuTheme,

    dialogTheme: darkDialogTheme,
    bottomSheetTheme: darkBottomSheetTheme,

    chipTheme: darkChipTheme,
    tabBarTheme: darkTabBarTheme,

    navigationBarTheme: darkNavigationBarTheme,
    bottomNavigationBarTheme: darkBottomNavigationBarTheme,

    progressIndicatorTheme: progressIndicatorTheme,
    dividerTheme: darkDividerTheme,

    iconTheme: darkIconTheme,
    primaryIconTheme: primaryIconTheme,

    listTileTheme: darkListTileTheme,
    switchTheme: darkSwitchTheme,
    checkboxTheme: darkCheckboxTheme,

    tooltipTheme: darkTooltipTheme,
    snackBarTheme: darkSnackBarTheme,
    bannerTheme: darkBannerTheme,
  );

  // Color Schemes
  static const ColorScheme lightColorScheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.info,
    onSecondary: Colors.white,
    error: AppColors.error,
    onError: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.onBackground,
    outline: AppColors.cardBorder,
    outlineVariant: AppColors.divider,
  );

  // Dark Color Scheme - Updated with lighter blue-gray palette
  static const ColorScheme darkColorScheme = ColorScheme.dark(
    primary: AppColors.primary, // Keep navy blue
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.info,
    onSecondary: Colors.white,
    error: AppColors.error,
    onError: Colors.white,
    surface: AppColors.darkSurface, // Medium Blue-Gray
    onSurface: AppColors.darkText, // Light blue-tinted text
    outline: AppColors.darkBorder, // Blue-Gray
    outlineVariant: AppColors.darkBorder,
  );

  // App Bar Themes - Light เก็บเดิม
  static const AppBarTheme lightAppBarTheme = AppBarTheme(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.onBackground,
    elevation: 0,
    scrolledUnderElevation: 1,
    shadowColor: Colors.black12,
    titleTextStyle: AppTextStyles.headline6,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    iconTheme: IconThemeData(color: AppColors.onBackground),
    actionsIconTheme: IconThemeData(color: AppColors.onBackground),
  );

  // Dark App Bar - Navy navigation with new palette
  static const AppBarTheme darkAppBarTheme = AppBarTheme(
    backgroundColor: AppColors.darkNavigation, // Keep navy for navigation
    foregroundColor: AppColors.darkText, // Light gray text
    elevation: 0,
    scrolledUnderElevation: 1,
    shadowColor: Colors.black26,
    titleTextStyle: AppTextStyles.headline6,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    iconTheme: IconThemeData(color: AppColors.darkText),
    actionsIconTheme: IconThemeData(color: AppColors.darkText),
  );

  // Button Themes
  static ElevatedButtonThemeData get elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: AppSpacing.buttonPaddingAll,
          shape: const RoundedRectangleBorder(borderRadius: AppBorders.medium),
          textStyle: AppTextStyles.button,
          elevation: 2,
        ),
      );

  static OutlinedButtonThemeData get outlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: AppSpacing.buttonPaddingAll,
          shape: const RoundedRectangleBorder(borderRadius: AppBorders.medium),
          side: const BorderSide(color: AppColors.primary),
          textStyle: AppTextStyles.button,
        ),
      );

  static TextButtonThemeData get textButtonTheme => TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      padding: AppSpacing.buttonPaddingAll,
      shape: const RoundedRectangleBorder(borderRadius: AppBorders.medium),
      textStyle: AppTextStyles.button,
    ),
  );

  // Card Theme - Light เก็บเดิม
  static CardThemeData get cardTheme => const CardThemeData(
    color: AppColors.surface,
    elevation: 2,
    shadowColor: Colors.black12,
    shape: RoundedRectangleBorder(
      borderRadius: AppBorders.large,
      side: BorderSide(color: AppColors.cardBorder),
    ),
    margin: EdgeInsets.zero,
  );

  // Dark Card Theme - Lighter blue-gray palette
  static CardThemeData get darkCardTheme => CardThemeData(
    color: AppColors.darkSurface, // Medium Blue-Gray
    elevation: 0, // Flat design
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: AppBorders.large,
      side: BorderSide(
        color: AppColors.darkBorder.withValues(alpha: 0.3),
      ), // Subtle border
    ),
    margin: EdgeInsets.zero,
  );

  // Input Decoration Theme - Light เก็บเดิม
  static InputDecorationTheme get inputDecorationTheme => InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: AppSpacing.inputPaddingAll,
    border: const OutlineInputBorder(
      borderRadius: AppBorders.medium,
      borderSide: BorderSide(color: AppColors.cardBorder),
    ),
    enabledBorder: const OutlineInputBorder(
      borderRadius: AppBorders.medium,
      borderSide: BorderSide(color: AppColors.cardBorder),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: AppBorders.medium,
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: const OutlineInputBorder(
      borderRadius: AppBorders.medium,
      borderSide: BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: const OutlineInputBorder(
      borderRadius: AppBorders.medium,
      borderSide: BorderSide(color: AppColors.error, width: 2),
    ),
    labelStyle: AppTextStyles.body2,
    hintStyle: AppTextStyles.hintText,
    errorStyle: AppTextStyles.errorText,
  );

  // Dark Input Decoration - Lighter blue-gray palette
  static InputDecorationTheme get darkInputDecorationTheme =>
      InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant, // Light Blue-Gray
        contentPadding: AppSpacing.inputPaddingAll,
        border: const OutlineInputBorder(
          borderRadius: AppBorders.medium,
          borderSide: BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppBorders.medium,
          borderSide: BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppBorders.medium,
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppBorders.medium,
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppBorders.medium,
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: AppTextStyles.body2.copyWith(
          color: AppColors.darkTextSecondary,
        ),
        hintStyle: AppTextStyles.body2.copyWith(color: AppColors.darkTextMuted),
        errorStyle: AppTextStyles.errorText,
      );

  // Dropdown Menu Theme - Light
  static DropdownMenuThemeData get dropdownMenuTheme => DropdownMenuThemeData(
    inputDecorationTheme: inputDecorationTheme,
    menuStyle: MenuStyle(
      backgroundColor: WidgetStateProperty.all(AppColors.surface),
      elevation: WidgetStateProperty.all(4),
      shape: WidgetStateProperty.all(
        const RoundedRectangleBorder(borderRadius: AppBorders.medium),
      ),
    ),
  );

  // Dark Dropdown Menu Theme
  static DropdownMenuThemeData get darkDropdownMenuTheme =>
      DropdownMenuThemeData(
        inputDecorationTheme: darkInputDecorationTheme,
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(AppColors.darkSurface),
          elevation: WidgetStateProperty.all(4),
          shape: WidgetStateProperty.all(
            const RoundedRectangleBorder(borderRadius: AppBorders.medium),
          ),
        ),
      );

  // Dialog Themes - Light เก็บเดิม
  static DialogThemeData get dialogTheme => const DialogThemeData(
    backgroundColor: AppColors.surface,
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: AppBorders.large),
    titleTextStyle: AppTextStyles.headline6,
    contentTextStyle: AppTextStyles.body1,
  );

  // Dark Dialog - Lighter blue-gray palette
  static DialogThemeData get darkDialogTheme => DialogThemeData(
    backgroundColor: AppColors.darkSurface,
    elevation: 8,
    shape: const RoundedRectangleBorder(borderRadius: AppBorders.large),
    titleTextStyle: AppTextStyles.headline6.copyWith(color: AppColors.darkText),
    contentTextStyle: AppTextStyles.body1.copyWith(color: AppColors.darkText),
  );

  // Bottom Sheet Theme - Light เก็บเดิม
  static BottomSheetThemeData get bottomSheetTheme => BottomSheetThemeData(
    backgroundColor: AppColors.surface,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: AppBorders.only(topLeft: 16, topRight: 16),
    ),
  );

  // Dark Bottom Sheet - Lighter blue-gray palette
  static BottomSheetThemeData get darkBottomSheetTheme => BottomSheetThemeData(
    backgroundColor: AppColors.darkSurface,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: AppBorders.only(topLeft: 16, topRight: 16),
    ),
  );

  // Chip Theme - Light เก็บเดิม
  static ChipThemeData get chipTheme => ChipThemeData(
    backgroundColor: AppColors.backgroundSecondary,
    selectedColor: AppColors.primary.withValues(alpha: 0.1),
    disabledColor: AppColors.backgroundTertiary,
    padding: AppSpacing.paddingSmall,
    labelStyle: AppTextStyles.caption,
    secondaryLabelStyle: AppTextStyles.caption,
    shape: const RoundedRectangleBorder(borderRadius: AppBorders.circular),
    side: const BorderSide(color: AppColors.cardBorder),
  );

  // Dark Chip - Lighter blue-gray palette
  static ChipThemeData get darkChipTheme => ChipThemeData(
    backgroundColor: AppColors.darkSurfaceVariant,
    selectedColor: AppColors.primary.withValues(alpha: 0.2),
    disabledColor: AppColors.darkBorder,
    padding: AppSpacing.paddingSmall,
    labelStyle: AppTextStyles.caption.copyWith(color: AppColors.darkText),
    secondaryLabelStyle: AppTextStyles.caption.copyWith(
      color: AppColors.darkText,
    ),
    shape: const RoundedRectangleBorder(borderRadius: AppBorders.circular),
    side: const BorderSide(color: AppColors.darkBorder),
  );

  // Tab Bar Theme - Light เก็บเดิม
  static TabBarThemeData get tabBarTheme => const TabBarThemeData(
    labelColor: AppColors.primary,
    unselectedLabelColor: AppColors.textSecondary,
    labelStyle: AppTextStyles.button,
    unselectedLabelStyle: AppTextStyles.button,
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
  );

  // Dark Tab Bar - Lighter blue-gray palette
  static TabBarThemeData get darkTabBarTheme => const TabBarThemeData(
    labelColor: AppColors.primary,
    unselectedLabelColor: AppColors.darkTextSecondary,
    labelStyle: AppTextStyles.button,
    unselectedLabelStyle: AppTextStyles.button,
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
  );

  // Navigation Themes - Light เก็บเดิม
  static NavigationBarThemeData get navigationBarTheme =>
      NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        elevation: 8,
        height: AppSpacing.bottomNavHeight,
        labelTextStyle: WidgetStateProperty.all(AppTextStyles.caption),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary);
          }
          return const IconThemeData(color: AppColors.textSecondary);
        }),
      );

  // Dark Navigation - Keep navy for navigation consistency
  static NavigationBarThemeData get darkNavigationBarTheme =>
      NavigationBarThemeData(
        backgroundColor: AppColors.darkNavigation, // Keep navy for navigation
        elevation: 8,
        height: AppSpacing.bottomNavHeight,
        labelTextStyle: WidgetStateProperty.all(
          AppTextStyles.caption.copyWith(color: AppColors.darkText),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary);
          }
          return const IconThemeData(color: AppColors.darkTextSecondary);
        }),
      );

  static BottomNavigationBarThemeData get bottomNavigationBarTheme =>
      const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        elevation: 8,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: AppTextStyles.caption,
        unselectedLabelStyle: AppTextStyles.caption,
        type: BottomNavigationBarType.fixed,
      );

  // Dark Bottom Navigation - Keep navy for consistency
  static BottomNavigationBarThemeData get darkBottomNavigationBarTheme =>
      BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkNavigation, // Keep navy for navigation
        elevation: 8,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.darkTextSecondary,
        selectedLabelStyle: AppTextStyles.caption.copyWith(
          color: AppColors.darkText,
        ),
        unselectedLabelStyle: AppTextStyles.caption.copyWith(
          color: AppColors.darkTextSecondary,
        ),
        type: BottomNavigationBarType.fixed,
      );

  // Progress Indicator Theme
  static ProgressIndicatorThemeData get progressIndicatorTheme =>
      const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.backgroundSecondary,
        circularTrackColor: AppColors.backgroundSecondary,
      );

  // Divider Theme - Light เก็บเดิม
  static DividerThemeData get dividerTheme =>
      const DividerThemeData(color: AppColors.divider, thickness: 1, space: 1);

  // Dark Divider - Lighter blue-gray palette
  static DividerThemeData get darkDividerTheme => DividerThemeData(
    color: AppColors.darkBorder.withValues(alpha: 0.3),
    thickness: 1,
    space: 1,
  );

  // Icon Themes - Light เก็บเดิม
  static IconThemeData get lightIconTheme =>
      const IconThemeData(color: AppColors.onBackground, size: 24);

  // Dark Icon - Lighter blue-gray palette
  static IconThemeData get darkIconTheme =>
      const IconThemeData(color: AppColors.darkText, size: 24);

  static IconThemeData get primaryIconTheme =>
      const IconThemeData(color: AppColors.primary, size: 24);

  // List Tile Theme - Light เก็บเดิม
  static ListTileThemeData get listTileTheme => const ListTileThemeData(
    contentPadding: AppSpacing.paddingMedium,
    shape: RoundedRectangleBorder(borderRadius: AppBorders.medium),
    titleTextStyle: AppTextStyles.body1,
    subtitleTextStyle: AppTextStyles.body2,
    iconColor: AppColors.textSecondary,
  );

  // Dark List Tile - Lighter blue-gray palette
  static ListTileThemeData get darkListTileTheme => ListTileThemeData(
    contentPadding: AppSpacing.paddingMedium,
    shape: const RoundedRectangleBorder(borderRadius: AppBorders.medium),
    titleTextStyle: AppTextStyles.body1.copyWith(color: AppColors.darkText),
    subtitleTextStyle: AppTextStyles.body2.copyWith(
      color: AppColors.darkTextSecondary,
    ),
    iconColor: AppColors.darkTextSecondary,
  );

  // Switch Theme - Light
  static SwitchThemeData get switchTheme => SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }
      return AppColors.textSecondary;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary.withValues(alpha: 0.3);
      }
      return AppColors.backgroundSecondary;
    }),
  );

  // Dark Switch Theme
  static SwitchThemeData get darkSwitchTheme => SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }
      return AppColors.darkTextSecondary;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary.withValues(alpha: 0.3);
      }
      return AppColors.darkSurfaceVariant;
    }),
  );

  // Checkbox Theme - Light
  static CheckboxThemeData get checkboxTheme => CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }
      return Colors.transparent;
    }),
    checkColor: WidgetStateProperty.all(AppColors.onPrimary),
    side: const BorderSide(color: AppColors.cardBorder, width: 2),
    shape: const RoundedRectangleBorder(borderRadius: AppBorders.small),
  );

  // Dark Checkbox Theme
  static CheckboxThemeData get darkCheckboxTheme => CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }
      return Colors.transparent;
    }),
    checkColor: WidgetStateProperty.all(AppColors.onPrimary),
    side: const BorderSide(color: AppColors.darkBorder, width: 2),
    shape: const RoundedRectangleBorder(borderRadius: AppBorders.small),
  );

  // Tooltip Theme - Light เก็บเดิม
  static TooltipThemeData get tooltipTheme => TooltipThemeData(
    decoration: const BoxDecoration(
      color: Colors.black87,
      borderRadius: AppBorders.small,
    ),
    textStyle: AppTextStyles.caption.copyWith(color: Colors.white),
    padding: AppSpacing.paddingSmall,
  );

  // Dark Tooltip - Lighter blue-gray palette
  static TooltipThemeData get darkTooltipTheme => TooltipThemeData(
    decoration: BoxDecoration(
      color: AppColors.darkSurfaceVariant,
      borderRadius: AppBorders.small,
      border: Border.all(color: AppColors.darkBorder),
    ),
    textStyle: AppTextStyles.caption.copyWith(color: AppColors.darkText),
    padding: AppSpacing.paddingSmall,
  );

  // Snackbar Theme - Light เก็บเดิม
  static SnackBarThemeData get snackBarTheme => SnackBarThemeData(
    backgroundColor: Colors.black87,
    contentTextStyle: AppTextStyles.body2.copyWith(color: Colors.white),
    shape: const RoundedRectangleBorder(borderRadius: AppBorders.medium),
    behavior: SnackBarBehavior.floating,
    actionTextColor: AppColors.primary,
  );

  // Dark Snackbar - Lighter blue-gray palette
  static SnackBarThemeData get darkSnackBarTheme => SnackBarThemeData(
    backgroundColor: AppColors.darkSurfaceVariant,
    contentTextStyle: AppTextStyles.body2.copyWith(color: AppColors.darkText),
    shape: const RoundedRectangleBorder(borderRadius: AppBorders.medium),
    behavior: SnackBarBehavior.floating,
    actionTextColor: AppColors.primary,
  );

  // Banner Theme - Light
  static MaterialBannerThemeData get bannerTheme => const MaterialBannerThemeData(
    backgroundColor: AppColors.backgroundSecondary,
    contentTextStyle: AppTextStyles.body2,
    padding: AppSpacing.paddingMedium,
  );

  // Dark Banner Theme
  static MaterialBannerThemeData get darkBannerTheme => MaterialBannerThemeData(
    backgroundColor: AppColors.darkSurfaceVariant,
    contentTextStyle: AppTextStyles.body2.copyWith(color: AppColors.darkText),
    padding: AppSpacing.paddingMedium,
  );
}
