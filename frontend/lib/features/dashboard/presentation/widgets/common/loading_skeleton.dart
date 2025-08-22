// Path: frontend/lib/core/widgets/common/loading_skeleton.dart
import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_decorations.dart';
import 'package:frontend/app/theme/app_spacing.dart';

class SkeletonLoader extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration? period;

  const SkeletonLoader({
    super.key,
    required this.child,
    required this.isLoading,
    this.baseColor,
    this.highlightColor,
    this.period,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.period ?? const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.isLoading) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(SkeletonLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _animationController.repeat();
      } else {
        _animationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    final theme = Theme.of(context);
    final baseColor =
        widget.baseColor ??
        (theme.brightness == Brightness.light
            ? Colors.grey.shade300
            : Colors.grey.shade700);
    final highlightColor =
        widget.highlightColor ??
        (theme.brightness == Brightness.light
            ? Colors.grey.shade100
            : Colors.grey.shade600);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                (_animation.value - 1).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 1).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SkeletonBox({super.key, this.width, this.height, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: AppDecorations.skeleton.copyWith(
        borderRadius: borderRadius ?? AppBorders.small,
      ),
    );
  }
}

class SkeletonText extends StatelessWidget {
  final double? width;
  final double height;
  final int lines;

  const SkeletonText({super.key, this.width, this.height = 16, this.lines = 1});

  @override
  Widget build(BuildContext context) {
    if (lines == 1) {
      return SkeletonBox(
        width: width,
        height: height,
        borderRadius: BorderRadius.circular(height / 2),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (index) {
        final isLast = index == lines - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.xs),
          child: SkeletonBox(
            width: isLast ? (width ?? double.infinity) * 0.7 : width,
            height: height,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        );
      }),
    );
  }
}

class SkeletonAvatar extends StatelessWidget {
  final double size;
  final bool isCircular;

  const SkeletonAvatar({super.key, this.size = 40, this.isCircular = true});

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: size,
      height: size,
      borderRadius: isCircular
          ? BorderRadius.circular(size / 2)
          : AppBorders.medium,
    );
  }
}

// Dashboard-specific skeleton widgets
class SkeletonDashboardCard extends StatelessWidget {
  final double? height;
  final bool hasTitle;
  final bool hasSubtitle;

  const SkeletonDashboardCard({
    super.key,
    this.height,
    this.hasTitle = true,
    this.hasSubtitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: AppSpacing.cardPaddingAll,
      decoration: AppDecorations.card,
      child: SkeletonLoader(
        isLoading: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasTitle) ...[
              const SkeletonText(width: 120, height: 18),
              if (hasSubtitle) ...[
                AppSpacing.verticalSpaceXS,
                const SkeletonText(width: 80, height: 12),
              ],
              AppSpacing.verticalSpaceMedium,
            ],
            const Expanded(
              child: SkeletonBox(
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SkeletonStatCard extends StatelessWidget {
  const SkeletonStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPaddingAll,
      decoration: AppDecorations.summaryCard,
      child: const SkeletonLoader(
        isLoading: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SkeletonAvatar(size: 24, isCircular: false),
            AppSpacing.verticalSpaceMedium,
            SkeletonText(width: 80, height: 28),
            AppSpacing.verticalSpaceSmall,
            SkeletonText(width: 60, height: 14),
          ],
        ),
      ),
    );
  }
}

class SkeletonChart extends StatelessWidget {
  final double height;
  final bool hasLegend;

  const SkeletonChart({super.key, this.height = 200, this.hasLegend = false});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      isLoading: true,
      child: Column(
        children: [
          SkeletonBox(width: double.infinity, height: height),
          if (hasLegend) ...[
            AppSpacing.verticalSpaceMedium,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                3,
                (index) => const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SkeletonAvatar(size: 12),
                    AppSpacing.horizontalSpaceXS,
                    SkeletonText(width: 40, height: 12),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SkeletonList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final bool hasAvatar;
  final bool hasTrailing;

  const SkeletonList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 60,
    this.hasAvatar = false,
    this.hasTrailing = false,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      isLoading: true,
      child: Column(
        children: List.generate(
          itemCount,
          (index) => Container(
            height: itemHeight,
            padding: AppSpacing.paddingMedium,
            margin: EdgeInsets.only(
              bottom: index < itemCount - 1 ? AppSpacing.small : 0,
            ),
            decoration: AppDecorations.card,
            child: Row(
              children: [
                if (hasAvatar) ...[
                  const SkeletonAvatar(),
                  AppSpacing.horizontalSpaceMedium,
                ],
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SkeletonText(height: 16),
                      AppSpacing.verticalSpaceXS,
                      SkeletonText(width: 100, height: 12),
                    ],
                  ),
                ),
                if (hasTrailing) ...[
                  AppSpacing.horizontalSpaceMedium,
                  const SkeletonBox(width: 24, height: 24),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SkeletonGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double childAspectRatio;

  const SkeletonGrid({
    super.key,
    this.itemCount = 4,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.2,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      isLoading: true,
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: AppSpacing.medium,
        mainAxisSpacing: AppSpacing.medium,
        children: List.generate(
          itemCount,
          (index) => const SkeletonDashboardCard(),
        ),
      ),
    );
  }
}

// Convenience widget for common loading states
class LoadingState extends StatelessWidget {
  final LoadingType type;
  final String? message;

  const LoadingState({super.key, required this.type, this.message});

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case LoadingType.dashboard:
        return const Column(
          children: [
            SkeletonGrid(itemCount: 2),
            AppSpacing.verticalSpaceLarge,
            SkeletonDashboardCard(height: 300),
            AppSpacing.verticalSpaceLarge,
            SkeletonDashboardCard(height: 250),
          ],
        );
      case LoadingType.chart:
        return const SkeletonChart(hasLegend: true);
      case LoadingType.list:
        return const SkeletonList();
      case LoadingType.grid:
        return const SkeletonGrid();
      case LoadingType.card:
        return const SkeletonDashboardCard();
    }
  }
}

enum LoadingType { dashboard, chart, list, grid, card }
