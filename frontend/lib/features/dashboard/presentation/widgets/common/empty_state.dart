// Path: frontend/lib/features/dashboard/presentation/widgets/common/empty_state.dart
import 'package:flutter/material.dart';
import 'package:tp_rfid/app/theme/app_colors.dart';
import 'package:tp_rfid/app/theme/app_decorations.dart';
import 'package:tp_rfid/app/theme/app_spacing.dart';
import 'package:tp_rfid/app/theme/app_typography.dart';
import '../../../../../l10n/features/dashboard/dashboard_localizations.dart';

class EmptyState extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? description;
  final Widget? action;
  final Color? iconColor;
  final double? iconSize;
  final EdgeInsets? padding;

  const EmptyState({
    super.key,
    this.icon,
    required this.title,
    this.description,
    this.action,
    this.iconColor,
    this.iconSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? AppSpacing.paddingLarge,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: iconSize ?? 64,
              color: iconColor ?? AppColors.textTertiary,
            ),
            AppSpacing.verticalSpaceMedium,
          ],
          Text(
            title,
            style: AppTextStyles.headline6.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (description != null) ...[
            AppSpacing.verticalSpaceSmall,
            Text(
              description!,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[AppSpacing.verticalSpaceLarge, action!],
        ],
      ),
    );
  }
}

// Predefined empty states for common scenarios
class NoDataFound extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const NoDataFound({super.key, this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = DashboardLocalizations.of(context);

    return EmptyState(
      icon: Icons.inbox_outlined,
      title: l10n.noDataFound,
      description: message ?? l10n.noDataToDisplay,
      action: onRetry != null
          ? ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.reload),
            )
          : null,
    );
  }
}

class NoSearchResults extends StatelessWidget {
  final String? searchTerm;
  final VoidCallback? onClear;

  const NoSearchResults({super.key, this.searchTerm, this.onClear});

  @override
  Widget build(BuildContext context) {
    final l10n = DashboardLocalizations.of(context);

    return EmptyState(
      icon: Icons.search_off,
      title: l10n.noResultsFound,
      description: searchTerm != null
          ? l10n.noResultsFor(searchTerm!)
          : l10n.noResultsFound,
      action: onClear != null
          ? OutlinedButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.clear),
              label: Text(l10n.clearSearch),
            )
          : null,
    );
  }
}

class NoConnection extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoConnection({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = DashboardLocalizations.of(context);

    return EmptyState(
      icon: Icons.wifi_off,
      iconColor: AppColors.error,
      title: l10n.noConnection,
      description: l10n.checkInternetConnection,
      action: onRetry != null
          ? ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.tryAgain),
            )
          : null,
    );
  }
}

// Dashboard-specific empty states
class NoDashboardData extends StatelessWidget {
  final VoidCallback? onRefresh;

  const NoDashboardData({super.key, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final l10n = DashboardLocalizations.of(context);

    return EmptyState(
      icon: Icons.dashboard_outlined,
      title: l10n.noDashboardData,
      description: l10n.noDashboardDataDescription,
      action: onRefresh != null
          ? ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.refreshDashboard),
            )
          : null,
    );
  }
}

class NoChartData extends StatelessWidget {
  final String? chartType;
  final VoidCallback? onRefresh;

  const NoChartData({super.key, this.chartType, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final l10n = DashboardLocalizations.of(context);

    return EmptyState(
      icon: Icons.show_chart,
      title: l10n.noChartData,
      description: chartType != null
          ? l10n.noChartDataAvailable
          : l10n.noChartDataAvailable,
      action: onRefresh != null
          ? TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(l10n.reload),
            )
          : null,
    );
  }
}

class NoAssets extends StatelessWidget {
  final VoidCallback? onAdd;

  const NoAssets({super.key, this.onAdd});

  @override
  Widget build(BuildContext context) {
    final l10n = DashboardLocalizations.of(context);

    return EmptyState(
      icon: Icons.inventory_2_outlined,
      title: l10n.noDataFound,
      description: l10n.noAssetsInSystem,
      action: onAdd != null
          ? ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(l10n.addAsset),
            )
          : null,
    );
  }
}

// Empty state card wrapper
class EmptyStateCard extends StatelessWidget {
  final Widget child;
  final double? height;

  const EmptyStateCard({super.key, required this.child, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height ?? 200,
      decoration: AppDecorations.card,
      child: child,
    );
  }
}

// Compact empty state for smaller spaces
class CompactEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback? onTap;

  const CompactEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppBorders.medium,
      child: Container(
        padding: AppSpacing.paddingMedium,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: AppColors.textTertiary),
            AppSpacing.verticalSpaceSmall,
            Text(
              message,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Illustration empty state with custom image
class IllustrationEmptyState extends StatelessWidget {
  final String imagePath;
  final String title;
  final String? description;
  final Widget? action;
  final double? imageHeight;

  const IllustrationEmptyState({
    super.key,
    required this.imagePath,
    required this.title,
    this.description,
    this.action,
    this.imageHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingLarge,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: imageHeight ?? 120,
            fit: BoxFit.contain,
          ),
          AppSpacing.verticalSpaceLarge,
          Text(
            title,
            style: AppTextStyles.headline6.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (description != null) ...[
            AppSpacing.verticalSpaceSmall,
            Text(
              description!,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[AppSpacing.verticalSpaceLarge, action!],
        ],
      ),
    );
  }
}

// Builder for conditional empty states
class ConditionalEmptyState extends StatelessWidget {
  final bool isEmpty;
  final Widget child;
  final Widget emptyState;

  const ConditionalEmptyState({
    super.key,
    required this.isEmpty,
    required this.child,
    required this.emptyState,
  });

  @override
  Widget build(BuildContext context) {
    return isEmpty ? emptyState : child;
  }
}

// Helper widget for quick empty state creation
class QuickEmptyState extends StatelessWidget {
  final EmptyStateType type;
  final String? customMessage;
  final VoidCallback? onAction;

  const QuickEmptyState({
    super.key,
    required this.type,
    this.customMessage,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case EmptyStateType.noData:
        return NoDataFound(message: customMessage, onRetry: onAction);
      case EmptyStateType.noSearch:
        return NoSearchResults(onClear: onAction);
      case EmptyStateType.noConnection:
        return NoConnection(onRetry: onAction);
      case EmptyStateType.noDashboard:
        return NoDashboardData(onRefresh: onAction);
      case EmptyStateType.noChart:
        return NoChartData(onRefresh: onAction);
      case EmptyStateType.noAssets:
        return NoAssets(onAdd: onAction);
    }
  }
}

enum EmptyStateType {
  noData,
  noSearch,
  noConnection,
  noDashboard,
  noChart,
  noAssets,
}
