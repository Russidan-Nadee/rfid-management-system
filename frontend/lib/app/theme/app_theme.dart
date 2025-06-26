// Path: frontend/lib/core/constants/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_decorations.dart';
import 'app_spacing.dart';

class AppTheme {
  // Light Theme
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

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

  // Dark Theme
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Color Scheme
    colorScheme: darkColorScheme,

    // Scaffold
    scaffoldBackgroundColor: const Color(0xFF121212),

    // App Bar Theme
    appBarTheme: darkAppBarTheme,

    // Text Theme
    textTheme: AppTextStyles.darkTextTheme,

    // Component Themes (same as light theme but adjusted for dark)
    elevatedButtonTheme: elevatedButtonTheme,
    outlinedButtonTheme: outlinedButtonTheme,
    textButtonTheme: textButtonTheme,

    cardTheme: darkCardTheme,
    inputDecorationTheme: darkInputDecorationTheme,
    dropdownMenuTheme: dropdownMenuTheme,

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
    switchTheme: switchTheme,
    checkboxTheme: checkboxTheme,

    tooltipTheme: darkTooltipTheme,
    snackBarTheme: darkSnackBarTheme,
    bannerTheme: bannerTheme,
  );

  // Color Schemes
  static const ColorScheme lightColorScheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.info,
    onSecondary: Colors.white,
    error: AppColors.error,
    onError: Colors.white,
    background: AppColors.background,
    onBackground: AppColors.onBackground,
    surface: AppColors.surface,
    onSurface: AppColors.onBackground,
    outline: AppColors.cardBorder,
    outlineVariant: AppColors.divider,
  );

  static const ColorScheme darkColorScheme = ColorScheme.dark(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.info,
    onSecondary: Colors.white,
    error: AppColors.error,
    onError: Colors.white,
    background: Color(0xFF121212),
    onBackground: Colors.white,
    surface: Color(0xFF1E1E1E),
    onSurface: Colors.white,
    outline: Color(0xFF404040),
    outlineVariant: Color(0xFF2C2C2C),
  );

  // App Bar Themes
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

  static const AppBarTheme darkAppBarTheme = AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E),
    foregroundColor: Colors.white,
    elevation: 0,
    scrolledUnderElevation: 1,
    shadowColor: Colors.black26,
    titleTextStyle: AppTextStyles.headline6,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    iconTheme: IconThemeData(color: Colors.white),
    actionsIconTheme: IconThemeData(color: Colors.white),
  );

  // Button Themes
  static ElevatedButtonThemeData get elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: AppSpacing.buttonPaddingAll,
          shape: RoundedRectangleBorder(borderRadius: AppBorders.medium),
          textStyle: AppTextStyles.button,
          elevation: 2,
        ),
      );

  static OutlinedButtonThemeData get outlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: AppSpacing.buttonPaddingAll,
          shape: RoundedRectangleBorder(borderRadius: AppBorders.medium),
          side: const BorderSide(color: AppColors.primary),
          textStyle: AppTextStyles.button,
        ),
      );

  static TextButtonThemeData get textButtonTheme => TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      padding: AppSpacing.buttonPaddingAll,
      shape: RoundedRectangleBorder(borderRadius: AppBorders.medium),
      textStyle: AppTextStyles.button,
    ),
  );

  // Card Theme
  static CardThemeData get cardTheme => CardThemeData(
    color: AppColors.surface,
    elevation: 2,
    shadowColor: Colors.black12,
    shape: RoundedRectangleBorder(
      borderRadius: AppBorders.large,
      side: const BorderSide(color: AppColors.cardBorder),
    ),
    margin: EdgeInsets.zero,
  );

  static CardThemeData get darkCardTheme => CardThemeData(
    color: const Color(0xFF1E1E1E),
    elevation: 4,
    shadowColor: Colors.black26,
    shape: RoundedRectangleBorder(borderRadius: AppBorders.large),
    margin: EdgeInsets.zero,
  );

  // Input Decoration Theme
  static InputDecorationTheme get inputDecorationTheme => InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: AppSpacing.inputPaddingAll,
    border: OutlineInputBorder(
      borderRadius: AppBorders.medium,
      borderSide: const BorderSide(color: AppColors.cardBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppBorders.medium,
      borderSide: const BorderSide(color: AppColors.cardBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppBorders.medium,
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: AppBorders.medium,
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: AppBorders.medium,
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
    labelStyle: AppTextStyles.body2,
    hintStyle: AppTextStyles.hintText,
    errorStyle: AppTextStyles.errorText,
  );

  static InputDecorationTheme get darkInputDecorationTheme =>
      InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        contentPadding: AppSpacing.inputPaddingAll,
        border: OutlineInputBorder(
          borderRadius: AppBorders.medium,
          borderSide: const BorderSide(color: Color(0xFF404040)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorders.medium,
          borderSide: const BorderSide(color: Color(0xFF404040)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorders.medium,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppBorders.medium,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppBorders.medium,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: AppTextStyles.body2.copyWith(color: Colors.white70),
        hintStyle: AppTextStyles.body2.copyWith(color: Colors.white54),
        errorStyle: AppTextStyles.errorText,
      );

  // Dropdown Menu Theme
  static DropdownMenuThemeData get dropdownMenuTheme => DropdownMenuThemeData(
    inputDecorationTheme: inputDecorationTheme,
    menuStyle: MenuStyle(
      backgroundColor: MaterialStateProperty.all(AppColors.surface),
      elevation: MaterialStateProperty.all(4),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: AppBorders.medium),
      ),
    ),
  );

  // Dialog Themes
  static DialogThemeData get dialogTheme => DialogThemeData(
    backgroundColor: AppColors.surface,
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: AppBorders.large),
    titleTextStyle: AppTextStyles.headline6,
    contentTextStyle: AppTextStyles.body1,
  );

  static DialogThemeData get darkDialogTheme => DialogThemeData(
    backgroundColor: const Color(0xFF1E1E1E),
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: AppBorders.large),
    titleTextStyle: AppTextStyles.headline6.copyWith(color: Colors.white),
    contentTextStyle: AppTextStyles.body1.copyWith(color: Colors.white),
  );

  // Bottom Sheet Theme
  static BottomSheetThemeData get bottomSheetTheme => BottomSheetThemeData(
    backgroundColor: AppColors.surface,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: AppBorders.only(topLeft: 16, topRight: 16),
    ),
  );

  static BottomSheetThemeData get darkBottomSheetTheme => BottomSheetThemeData(
    backgroundColor: const Color(0xFF1E1E1E),
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: AppBorders.only(topLeft: 16, topRight: 16),
    ),
  );

  // Chip Theme
  static ChipThemeData get chipTheme => ChipThemeData(
    backgroundColor: AppColors.backgroundSecondary,
    selectedColor: AppColors.primary.withOpacity(0.1),
    disabledColor: AppColors.backgroundTertiary,
    padding: AppSpacing.paddingSmall,
    labelStyle: AppTextStyles.caption,
    secondaryLabelStyle: AppTextStyles.caption,
    shape: RoundedRectangleBorder(borderRadius: AppBorders.circular),
    side: const BorderSide(color: AppColors.cardBorder),
  );

  static ChipThemeData get darkChipTheme => ChipThemeData(
    backgroundColor: const Color(0xFF2C2C2C),
    selectedColor: AppColors.primary.withOpacity(0.2),
    disabledColor: const Color(0xFF404040),
    padding: AppSpacing.paddingSmall,
    labelStyle: AppTextStyles.caption.copyWith(color: Colors.white),
    secondaryLabelStyle: AppTextStyles.caption.copyWith(color: Colors.white),
    shape: RoundedRectangleBorder(borderRadius: AppBorders.circular),
    side: const BorderSide(color: Color(0xFF404040)),
  );

  // Tab Bar Theme
  static TabBarThemeData get tabBarTheme => TabBarThemeData(
    labelColor: AppColors.primary,
    unselectedLabelColor: AppColors.textSecondary,
    labelStyle: AppTextStyles.button,
    unselectedLabelStyle: AppTextStyles.button,
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
  );

  static TabBarThemeData get darkTabBarTheme => TabBarThemeData(
    labelColor: AppColors.primary,
    unselectedLabelColor: Colors.white70,
    labelStyle: AppTextStyles.button,
    unselectedLabelStyle: AppTextStyles.button,
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
  );

  // Navigation Themes
  static NavigationBarThemeData get navigationBarTheme =>
      NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        elevation: 8,
        height: AppSpacing.bottomNavHeight,
        labelTextStyle: MaterialStateProperty.all(AppTextStyles.caption),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return IconThemeData(color: AppColors.primary);
          }
          return IconThemeData(color: AppColors.textSecondary);
        }),
      );

  static NavigationBarThemeData get darkNavigationBarTheme =>
      NavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 8,
        height: AppSpacing.bottomNavHeight,
        labelTextStyle: MaterialStateProperty.all(
          AppTextStyles.caption.copyWith(color: Colors.white),
        ),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return IconThemeData(color: AppColors.primary);
          }
          return IconThemeData(color: Colors.white70);
        }),
      );

  static BottomNavigationBarThemeData get bottomNavigationBarTheme =>
      BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        elevation: 8,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: AppTextStyles.caption,
        unselectedLabelStyle: AppTextStyles.caption,
        type: BottomNavigationBarType.fixed,
      );

  static BottomNavigationBarThemeData get darkBottomNavigationBarTheme =>
      BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 8,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.white70,
        selectedLabelStyle: AppTextStyles.caption.copyWith(color: Colors.white),
        unselectedLabelStyle: AppTextStyles.caption.copyWith(
          color: Colors.white70,
        ),
        type: BottomNavigationBarType.fixed,
      );

  // Progress Indicator Theme
  static ProgressIndicatorThemeData get progressIndicatorTheme =>
      ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.backgroundSecondary,
        circularTrackColor: AppColors.backgroundSecondary,
      );

  // Divider Theme
  static DividerThemeData get dividerTheme =>
      DividerThemeData(color: AppColors.divider, thickness: 1, space: 1);

  static DividerThemeData get darkDividerTheme =>
      DividerThemeData(color: const Color(0xFF404040), thickness: 1, space: 1);

  // Icon Themes
  static IconThemeData get lightIconTheme =>
      IconThemeData(color: AppColors.onBackground, size: 24);

  static IconThemeData get darkIconTheme =>
      IconThemeData(color: Colors.white, size: 24);

  static IconThemeData get primaryIconTheme =>
      IconThemeData(color: AppColors.primary, size: 24);

  // List Tile Theme
  static ListTileThemeData get listTileTheme => ListTileThemeData(
    contentPadding: AppSpacing.paddingMedium,
    shape: RoundedRectangleBorder(borderRadius: AppBorders.medium),
    titleTextStyle: AppTextStyles.body1,
    subtitleTextStyle: AppTextStyles.body2,
    iconColor: AppColors.textSecondary,
  );

  static ListTileThemeData get darkListTileTheme => ListTileThemeData(
    contentPadding: AppSpacing.paddingMedium,
    shape: RoundedRectangleBorder(borderRadius: AppBorders.medium),
    titleTextStyle: AppTextStyles.body1.copyWith(color: Colors.white),
    subtitleTextStyle: AppTextStyles.body2.copyWith(color: Colors.white70),
    iconColor: Colors.white70,
  );

  // Switch Theme
  static SwitchThemeData get switchTheme => SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primary;
      }
      return AppColors.textSecondary;
    }),
    trackColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primary.withOpacity(0.3);
      }
      return AppColors.backgroundSecondary;
    }),
  );

  // Checkbox Theme
  static CheckboxThemeData get checkboxTheme => CheckboxThemeData(
    fillColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primary;
      }
      return Colors.transparent;
    }),
    checkColor: MaterialStateProperty.all(AppColors.onPrimary),
    side: const BorderSide(color: AppColors.cardBorder, width: 2),
    shape: RoundedRectangleBorder(borderRadius: AppBorders.small),
  );

  // Tooltip Theme
  static TooltipThemeData get tooltipTheme => TooltipThemeData(
    decoration: BoxDecoration(
      color: Colors.black87,
      borderRadius: AppBorders.small,
    ),
    textStyle: AppTextStyles.caption.copyWith(color: Colors.white),
    padding: AppSpacing.paddingSmall,
  );

  static TooltipThemeData get darkTooltipTheme => TooltipThemeData(
    decoration: BoxDecoration(
      color: const Color(0xFFE0E0E0), // Light grey instead of white87
      borderRadius: AppBorders.small,
    ),
    textStyle: AppTextStyles.caption.copyWith(color: Colors.black),
    padding: AppSpacing.paddingSmall,
  );

  // Snackbar Theme
  static SnackBarThemeData get snackBarTheme => SnackBarThemeData(
    backgroundColor: Colors.black87,
    contentTextStyle: AppTextStyles.body2.copyWith(color: Colors.white),
    shape: RoundedRectangleBorder(borderRadius: AppBorders.medium),
    behavior: SnackBarBehavior.floating,
    actionTextColor: AppColors.primary,
  );

  static SnackBarThemeData get darkSnackBarTheme => SnackBarThemeData(
    backgroundColor: const Color(0xFFE0E0E0), // Light grey instead of white87
    contentTextStyle: AppTextStyles.body2.copyWith(color: Colors.black),
    shape: RoundedRectangleBorder(borderRadius: AppBorders.medium),
    behavior: SnackBarBehavior.floating,
    actionTextColor: AppColors.primary,
  );

  // Banner Theme
  static MaterialBannerThemeData get bannerTheme => MaterialBannerThemeData(
    backgroundColor: AppColors.backgroundSecondary,
    contentTextStyle: AppTextStyles.body2,
    padding: AppSpacing.paddingMedium,
  );
}
