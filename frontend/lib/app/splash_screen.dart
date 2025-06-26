// Path: frontend/lib/app/splash_screen.dart
import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'theme/app_typography.dart';
import 'theme/app_spacing.dart';
import 'theme/app_decorations.dart';
import 'app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo with animation
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildAppLogo(),
                  ),

                  AppSpacing.verticalSpaceLarge,

                  // App Title
                  Text(
                    AppConstants.appName,
                    style: AppTextStyles.headline3.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  AppSpacing.verticalSpaceSmall,

                  // App Version
                  Text(
                    'Version ${AppConstants.appVersion}',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.onPrimary.withOpacity(0.8),
                    ),
                  ),

                  AppSpacing.verticalSpaceXXL,

                  // Loading Indicator
                  _buildLoadingIndicator(),

                  AppSpacing.verticalSpaceMedium,

                  // Loading Text
                  Text(
                    'Loading...',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.onPrimary.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorders.large,
        boxShadow: AppShadows.large,
      ),
      child: Icon(
        Icons.inventory_2_outlined,
        color: AppColors.primary,
        size: 60,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 32,
      height: 32,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
        strokeWidth: 3,
      ),
    );
  }
}

// Alternative minimal splash screen
class MinimalSplashScreen extends StatelessWidget {
  const MinimalSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Simple logo
            Container(
              width: 80,
              height: 80,
              decoration: AppDecorations.card,
              child: Icon(
                Icons.inventory_2_outlined,
                color: AppColors.primary,
                size: 40,
              ),
            ),

            AppSpacing.verticalSpaceLarge,

            // App name
            Text(
              AppConstants.appName,
              style: AppTextStyles.headline4.copyWith(color: AppColors.primary),
            ),

            AppSpacing.verticalSpaceXL,

            // Loading
            CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
          ],
        ),
      ),
    );
  }
}
