// Path: frontend/lib/app/theme/app_spacing.dart
import 'package:flutter/material.dart';

class AppSpacing {
  // Modern 4px Grid System - More breathing room
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double xxxxl = 48.0;

  // Legacy names for backward compatibility
  static const double small = sm;
  static const double medium = lg;
  static const double large = xxl;

  // Modern semantic spacing - More generous
  static const double cardPadding = xl; // 20px (was 16px)
  static const double screenPadding = lg; // 16px
  static const double sectionSpacing = xxxl; // 32px (was 24px)
  static const double itemSpacing = md; // 12px (was 8px)
  static const double tightSpacing = xs; // 4px

  // Component specific - Enhanced breathing room
  static const double buttonPadding = lg; // 16px
  static const double buttonPaddingVertical = md; // 12px
  static const double buttonPaddingHorizontal = xxl; // 24px

  static const double inputPadding = lg; // 16px
  static const double inputPaddingVertical = md; // 12px
  static const double inputPaddingHorizontal = lg; // 16px

  static const double listItemPadding = lg; // 16px
  static const double listItemSpacing = sm; // 8px

  static const double modalPadding = xxl; // 24px
  static const double dialogPadding = xxl; // 24px

  // Dashboard specific - Modern spacing
  static const double dashboardCardPadding = xl; // 20px (was 16px)
  static const double dashboardItemSpacing = lg; // 16px
  static const double dashboardSectionSpacing = xxxl; // 32px (was 24px)
  static const double chartPadding = lg; // 16px
  static const double filterSpacing = md; // 12px (was 8px)

  // Layout constants - Modern sizes
  static const double navigationHeight = 60.0; // Taller (was 56px)
  static const double toolbarHeight = 64.0; // Taller (was 56px)
  static const double bottomNavHeight = 72.0; // Taller (was 60px)
  static const double fabSize = 56.0;
  static const double appBarElevation = 0.0; // Flat design

  // Modern border radius - More rounded
  static const double radiusXS = 4.0;
  static const double radiusSM = 6.0;
  static const double radiusMD = 8.0;
  static const double radiusLG = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusXXL = 20.0;
  static const double radiusXXXL = 24.0;

  // SizedBox helpers - Updated
  static const Widget verticalSpaceXS = SizedBox(height: xs);
  static const Widget verticalSpaceSM = SizedBox(height: sm);
  static const Widget verticalSpaceMD = SizedBox(height: md);
  static const Widget verticalSpaceLG = SizedBox(height: lg);
  static const Widget verticalSpaceXL = SizedBox(height: xl);
  static const Widget verticalSpaceXXL = SizedBox(height: xxl);
  static const Widget verticalSpaceXXXL = SizedBox(height: xxxl);

  static const Widget horizontalSpaceXS = SizedBox(width: xs);
  static const Widget horizontalSpaceSM = SizedBox(width: sm);
  static const Widget horizontalSpaceMD = SizedBox(width: md);
  static const Widget horizontalSpaceLG = SizedBox(width: lg);
  static const Widget horizontalSpaceXL = SizedBox(width: xl);
  static const Widget horizontalSpaceXXL = SizedBox(width: xxl);
  static const Widget horizontalSpaceXXXL = SizedBox(width: xxxl);

  // Legacy support
  static const Widget verticalSpaceSmall = verticalSpaceSM;
  static const Widget verticalSpaceMedium = verticalSpaceLG;
  static const Widget verticalSpaceLarge = verticalSpaceXXL;
  static const Widget horizontalSpaceSmall = horizontalSpaceSM;
  static const Widget horizontalSpaceMedium = horizontalSpaceLG;
  static const Widget horizontalSpaceLarge = horizontalSpaceXXL;

  // EdgeInsets helpers - Modern padding
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);
  static const EdgeInsets paddingXXL = EdgeInsets.all(xxl);

  // Modern horizontal padding
  static const EdgeInsets paddingHorizontalXS = EdgeInsets.symmetric(
    horizontal: xs,
  );
  static const EdgeInsets paddingHorizontalSM = EdgeInsets.symmetric(
    horizontal: sm,
  );
  static const EdgeInsets paddingHorizontalMD = EdgeInsets.symmetric(
    horizontal: md,
  );
  static const EdgeInsets paddingHorizontalLG = EdgeInsets.symmetric(
    horizontal: lg,
  );
  static const EdgeInsets paddingHorizontalXL = EdgeInsets.symmetric(
    horizontal: xl,
  );
  static const EdgeInsets paddingHorizontalXXL = EdgeInsets.symmetric(
    horizontal: xxl,
  );

  // Modern vertical padding
  static const EdgeInsets paddingVerticalXS = EdgeInsets.symmetric(
    vertical: xs,
  );
  static const EdgeInsets paddingVerticalSM = EdgeInsets.symmetric(
    vertical: sm,
  );
  static const EdgeInsets paddingVerticalMD = EdgeInsets.symmetric(
    vertical: md,
  );
  static const EdgeInsets paddingVerticalLG = EdgeInsets.symmetric(
    vertical: lg,
  );
  static const EdgeInsets paddingVerticalXL = EdgeInsets.symmetric(
    vertical: xl,
  );
  static const EdgeInsets paddingVerticalXXL = EdgeInsets.symmetric(
    vertical: xxl,
  );

  // Legacy support
  static const EdgeInsets paddingSmall = paddingSM;
  static const EdgeInsets paddingMedium = paddingLG;
  static const EdgeInsets paddingLarge = paddingXXL;

  // Screen padding - Enhanced
  static const EdgeInsets screenPaddingAll = EdgeInsets.all(screenPadding);
  static const EdgeInsets screenPaddingHorizontal = EdgeInsets.symmetric(
    horizontal: screenPadding,
  );
  static const EdgeInsets screenPaddingVertical = EdgeInsets.symmetric(
    vertical: screenPadding,
  );

  // Component padding - Modern
  static const EdgeInsets cardPaddingAll = EdgeInsets.all(cardPadding);
  static const EdgeInsets buttonPaddingAll = EdgeInsets.all(buttonPadding);
  static const EdgeInsets inputPaddingAll = EdgeInsets.all(inputPadding);
  static const EdgeInsets buttonPaddingSymmetric = EdgeInsets.symmetric(
    horizontal: buttonPaddingHorizontal,
    vertical: buttonPaddingVertical,
  );
  static const EdgeInsets inputPaddingSymmetric = EdgeInsets.symmetric(
    horizontal: inputPaddingHorizontal,
    vertical: inputPaddingVertical,
  );

  // Modern responsive spacing
  static double responsiveSpacing(
    BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
    double fallback = lg,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      return mobile ?? fallback;
    } else if (screenWidth < 1024) {
      return tablet ?? (fallback * 1.2);
    } else {
      return desktop ?? (fallback * 1.5);
    }
  }

  // Modern spacing utilities
  static Widget space(double size) => SizedBox(width: size, height: size);
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

  // Modern grid spacing
  static double gridSpacing(int multiplier) => sm * multiplier;
  static EdgeInsets gridPadding(int multiplier) =>
      EdgeInsets.all(sm * multiplier);

  // Modern safe area helpers
  static EdgeInsets safeAreaPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.only(
      top: mediaQuery.padding.top + sm,
      bottom: mediaQuery.padding.bottom + sm,
      left: screenPadding,
      right: screenPadding,
    );
  }

  // Layout constants
  static const double maxContentWidth = 1200.0;
  static const double minCardWidth = 280.0;
  static const double maxCardWidth = 400.0;
  static const double maxModalWidth = 480.0;

  // Animation spacing
  static const double animationOffset = lg;
  static const double slideDistance = xxxl;
}
