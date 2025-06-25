// Path: frontend/lib/core/constants/app_spacing.dart
import 'package:flutter/material.dart';

class AppSpacing {
  // Base 8px Grid System
  static const double xs = 4.0;
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Semantic Spacing
  static const double cardPadding = medium;
  static const double screenPadding = medium;
  static const double sectionSpacing = large;
  static const double itemSpacing = small;
  static const double tightSpacing = xs;

  // Component Specific Spacing
  static const double buttonPadding = medium;
  static const double inputPadding = medium;
  static const double listItemPadding = medium;
  static const double modalPadding = large;

  // Dashboard Specific
  static const double dashboardCardPadding = medium;
  static const double dashboardItemSpacing = medium;
  static const double dashboardSectionSpacing = large;
  static const double chartPadding = medium;
  static const double filterSpacing = small;

  // Layout Spacing
  static const double navigationHeight = 56.0;
  static const double toolbarHeight = 56.0;
  static const double bottomNavHeight = 60.0;
  static const double fabSize = 56.0;

  // SizedBox Helpers
  static const Widget verticalSpaceXS = SizedBox(height: xs);
  static const Widget verticalSpaceSmall = SizedBox(height: small);
  static const Widget verticalSpaceMedium = SizedBox(height: medium);
  static const Widget verticalSpaceLarge = SizedBox(height: large);
  static const Widget verticalSpaceXL = SizedBox(height: xl);
  static const Widget verticalSpaceXXL = SizedBox(height: xxl);

  static const Widget horizontalSpaceXS = SizedBox(width: xs);
  static const Widget horizontalSpaceSmall = SizedBox(width: small);
  static const Widget horizontalSpaceMedium = SizedBox(width: medium);
  static const Widget horizontalSpaceLarge = SizedBox(width: large);
  static const Widget horizontalSpaceXL = SizedBox(width: xl);
  static const Widget horizontalSpaceXXL = SizedBox(width: xxl);

  // EdgeInsets Helpers
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSmall = EdgeInsets.all(small);
  static const EdgeInsets paddingMedium = EdgeInsets.all(medium);
  static const EdgeInsets paddingLarge = EdgeInsets.all(large);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);

  static const EdgeInsets paddingHorizontalXS = EdgeInsets.symmetric(
    horizontal: xs,
  );
  static const EdgeInsets paddingHorizontalSmall = EdgeInsets.symmetric(
    horizontal: small,
  );
  static const EdgeInsets paddingHorizontalMedium = EdgeInsets.symmetric(
    horizontal: medium,
  );
  static const EdgeInsets paddingHorizontalLarge = EdgeInsets.symmetric(
    horizontal: large,
  );

  static const EdgeInsets paddingVerticalXS = EdgeInsets.symmetric(
    vertical: xs,
  );
  static const EdgeInsets paddingVerticalSmall = EdgeInsets.symmetric(
    vertical: small,
  );
  static const EdgeInsets paddingVerticalMedium = EdgeInsets.symmetric(
    vertical: medium,
  );
  static const EdgeInsets paddingVerticalLarge = EdgeInsets.symmetric(
    vertical: large,
  );

  // Screen Padding
  static const EdgeInsets screenPaddingAll = EdgeInsets.all(screenPadding);
  static const EdgeInsets screenPaddingHorizontal = EdgeInsets.symmetric(
    horizontal: screenPadding,
  );
  static const EdgeInsets screenPaddingVertical = EdgeInsets.symmetric(
    vertical: screenPadding,
  );

  // Component Padding
  static const EdgeInsets cardPaddingAll = EdgeInsets.all(cardPadding);
  static const EdgeInsets buttonPaddingAll = EdgeInsets.all(buttonPadding);
  static const EdgeInsets inputPaddingAll = EdgeInsets.all(inputPadding);

  // Responsive Spacing Helper
  static double responsive({
    required BuildContext context,
    double? mobile,
    double? tablet,
    double? desktop,
    double fallback = medium,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      return mobile ?? fallback;
    } else if (screenWidth < 1024) {
      return tablet ?? fallback;
    } else {
      return desktop ?? fallback;
    }
  }

  // Custom spacing methods
  static Widget verticalSpace(double height) => SizedBox(height: height);
  static Widget horizontalSpace(double width) => SizedBox(width: width);

  static EdgeInsets symmetric({double? horizontal, double? vertical}) =>
      EdgeInsets.symmetric(
        horizontal: horizontal ?? 0,
        vertical: vertical ?? 0,
      );

  static EdgeInsets only({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) => EdgeInsets.only(
    left: left ?? 0,
    top: top ?? 0,
    right: right ?? 0,
    bottom: bottom ?? 0,
  );

  // Grid Helpers for Layouts
  static double gridSpacing(int multiplier) => small * multiplier;

  static EdgeInsets gridPadding(int multiplier) =>
      EdgeInsets.all(small * multiplier);

  // Safe Area Helpers
  static EdgeInsets safeAreaPadding(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    return EdgeInsets.only(
      top: mediaQuery.padding.top + small,
      bottom: mediaQuery.padding.bottom + small,
      left: screenPadding,
      right: screenPadding,
    );
  }

  // Layout Constants
  static const double maxContentWidth = 1200.0;
  static const double minCardWidth = 280.0;
  static const double maxCardWidth = 400.0;

  // Animation Spacing (for transitions)
  static const double animationOffset = medium;
  static const double slideDistance = large;
}
