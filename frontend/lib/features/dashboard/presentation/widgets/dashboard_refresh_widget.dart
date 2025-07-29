// Path: frontend/lib/features/dashboard/presentation/widgets/dashboard_refresh_widget.dart
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../l10n/features/dashboard/dashboard_localizations.dart';

class DashboardRefreshWidget extends StatelessWidget {
  final VoidCallback onRefresh;
  final bool isLoading;
  final DateTime? lastRefresh;

  const DashboardRefreshWidget({
    super.key,
    required this.onRefresh,
    this.isLoading = false,
    this.lastRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Last refresh time indicator
        if (lastRefresh != null && !isLoading)
          _LastRefreshIndicator(lastRefresh: lastRefresh!),

        AppSpacing.horizontalSpaceSmall,

        // Refresh button
        _RefreshButton(
          onPressed: isLoading ? null : onRefresh,
          isLoading: isLoading,
        ),
      ],
    );
  }
}

class _LastRefreshIndicator extends StatelessWidget {
  final DateTime lastRefresh;

  const _LastRefreshIndicator({required this.lastRefresh});

  @override
  Widget build(BuildContext context) {
    final timeAgo = Helpers.formatTimeAgo(lastRefresh);
    final isRecent = DateTime.now().difference(lastRefresh).inMinutes < 5;

    return Container(
      padding: AppSpacing.paddingHorizontalSM.add(AppSpacing.paddingVerticalXS),
      decoration: AppDecorations.chip.copyWith(
        color: isRecent
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.backgroundSecondary,
        border: Border.all(
          color: isRecent
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.divider,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time,
            size: 12,
            color: isRecent ? AppColors.success : AppColors.textSecondary,
          ),
          AppSpacing.horizontalSpaceXS,
          Text(
            timeAgo,
            style: AppTextStyles.overline.copyWith(
              color: isRecent ? AppColors.success : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _RefreshButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const _RefreshButton({this.onPressed, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: AppBorders.medium,
      child: Padding(
        padding: AppSpacing.paddingSmall,
        child: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : Icon(
                Icons.refresh,
                size: 16,
                color: onPressed != null
                    ? AppColors.primary
                    : AppColors.textTertiary,
              ),
      ),
    );
  }
}

// Enhanced version with more features
class DashboardRefreshEnhanced extends StatefulWidget {
  final VoidCallback onRefresh;
  final VoidCallback? onClearCache;
  final bool isLoading;
  final DateTime? lastRefresh;
  final bool showMenu;

  const DashboardRefreshEnhanced({
    super.key,
    required this.onRefresh,
    this.onClearCache,
    this.isLoading = false,
    this.lastRefresh,
    this.showMenu = true,
  });

  @override
  State<DashboardRefreshEnhanced> createState() =>
      _DashboardRefreshEnhancedState();
}

class _DashboardRefreshEnhancedState extends State<DashboardRefreshEnhanced>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(DashboardRefreshEnhanced oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _rotationController.repeat();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _rotationController.stop();
      _rotationController.reset();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Data freshness indicator
        if (widget.lastRefresh != null)
          _DataFreshnessIndicator(lastRefresh: widget.lastRefresh!),

        AppSpacing.horizontalSpaceSmall,

        // Refresh controls
        if (widget.showMenu) ...[
          _RefreshMenuButton(
            onRefresh: widget.isLoading ? null : widget.onRefresh,
            onClearCache: widget.onClearCache,
            isLoading: widget.isLoading,
            rotationAnimation: _rotationAnimation,
          ),
        ] else ...[
          _SimpleRefreshButton(
            onPressed: widget.isLoading ? null : widget.onRefresh,
            isLoading: widget.isLoading,
            rotationAnimation: _rotationAnimation,
          ),
        ],
      ],
    );
  }
}

class _DataFreshnessIndicator extends StatelessWidget {
  final DateTime lastRefresh;

  const _DataFreshnessIndicator({required this.lastRefresh});

  @override
  Widget build(BuildContext context) {
    final l10n = DashboardLocalizations.of(context);
    final now = DateTime.now();
    final difference = now.difference(lastRefresh);
    final isFresh = difference.inMinutes < 5;
    final isStale = difference.inMinutes > 30;

    Color indicatorColor;
    IconData indicatorIcon;
    String status;

    if (isFresh) {
      indicatorColor = AppColors.success;
      indicatorIcon = Icons.check_circle;
      status = l10n.fresh;
    } else if (isStale) {
      indicatorColor = AppColors.warning;
      indicatorIcon = Icons.warning;
      status = l10n.stale;
    } else {
      indicatorColor = AppColors.info;
      indicatorIcon = Icons.info;
      status = l10n.ok;
    }

    return Tooltip(
      message: l10n.lastUpdatedTooltip(Helpers.formatDateTime(lastRefresh)),
      child: Container(
        padding: AppSpacing.paddingHorizontalSM.add(
          AppSpacing.paddingVerticalXS,
        ),
        decoration: AppDecorations.chip.copyWith(
          color: indicatorColor.withValues(alpha: 0.1),
          border: Border.all(color: indicatorColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(indicatorIcon, size: 12, color: indicatorColor),
            AppSpacing.horizontalSpaceXS,
            Text(
              status,
              style: AppTextStyles.overline.copyWith(
                color: indicatorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RefreshMenuButton extends StatelessWidget {
  final VoidCallback? onRefresh;
  final VoidCallback? onClearCache;
  final bool isLoading;
  final Animation<double> rotationAnimation;

  const _RefreshMenuButton({
    this.onRefresh,
    this.onClearCache,
    required this.isLoading,
    required this.rotationAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = DashboardLocalizations.of(context);

    return PopupMenuButton<String>(
      enabled: !isLoading,
      icon: AnimatedBuilder(
        animation: rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: rotationAnimation.value * 2 * 3.14159,
            child: Icon(
              Icons.refresh,
              size: 18,
              color: isLoading
                  ? AppColors.primary
                  : onRefresh != null
                  ? AppColors.primary
                  : AppColors.textTertiary,
            ),
          );
        },
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'refresh',
          enabled: onRefresh != null,
          child: Row(
            children: [
              const Icon(Icons.refresh, size: 16),
              AppSpacing.horizontalSpaceSmall,
              Text(l10n.refreshData),
            ],
          ),
        ),
        if (onClearCache != null)
          PopupMenuItem(
            value: 'clear_cache',
            child: Row(
              children: [
                const Icon(Icons.clear_all, size: 16),
                AppSpacing.horizontalSpaceSmall,
                Text(l10n.clearCache),
              ],
            ),
          ),
        PopupMenuItem(
          value: 'auto_refresh',
          child: Row(
            children: [
              const Icon(Icons.timer, size: 16),
              SizedBox(width: 8),
              Text(l10n.autoRefresh),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'refresh':
            onRefresh?.call();
            break;
          case 'clear_cache':
            onClearCache?.call();
            break;
          case 'auto_refresh':
            _showAutoRefreshDialog(context);
            break;
        }
      },
    );
  }

  void _showAutoRefreshDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _AutoRefreshDialog(),
    );
  }
}

class _SimpleRefreshButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final Animation<double> rotationAnimation;

  const _SimpleRefreshButton({
    this.onPressed,
    required this.isLoading,
    required this.rotationAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.1),
      borderRadius: AppBorders.medium,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppBorders.medium,
        child: Padding(
          padding: AppSpacing.paddingSmall,
          child: AnimatedBuilder(
            animation: rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: rotationAnimation.value * 2 * 3.14159,
                child: Icon(
                  Icons.refresh,
                  size: 16,
                  color: onPressed != null
                      ? AppColors.primary
                      : AppColors.textTertiary,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AutoRefreshDialog extends StatefulWidget {
  const _AutoRefreshDialog();

  @override
  State<_AutoRefreshDialog> createState() => _AutoRefreshDialogState();
}

class _AutoRefreshDialogState extends State<_AutoRefreshDialog> {
  int _selectedInterval = 30; // seconds
  bool _isEnabled = false;

  final List<int> _intervals = [15, 30, 60, 120, 300]; // seconds

  @override
  Widget build(BuildContext context) {
    final l10n = DashboardLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.autoRefreshSettings),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enable/Disable toggle
          SwitchListTile(
            title: Text(l10n.enableAutoRefresh),
            subtitle: Text(l10n.autoRefreshDescription),
            value: _isEnabled,
            onChanged: (value) => setState(() => _isEnabled = value),
            activeColor: AppColors.primary,
          ),

          AppSpacing.verticalSpaceMedium,

          // Interval selection
          if (_isEnabled) ...[
            Text(
              l10n.refreshInterval,
              style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w500),
            ),
            AppSpacing.verticalSpaceSmall,
            Wrap(
              spacing: AppSpacing.small,
              children: _intervals.map((interval) {
                final isSelected = _selectedInterval == interval;
                return ChoiceChip(
                  label: Text(_formatInterval(interval)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedInterval = interval);
                    }
                  },
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : null,
                    fontWeight: isSelected ? FontWeight.w600 : null,
                  ),
                );
              }).toList(),
            ),

            AppSpacing.verticalSpaceMedium,

            // Warning note
            Container(
              padding: AppSpacing.paddingMedium,
              decoration: AppDecorations.warning,
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppColors.warning),
                  AppSpacing.horizontalSpaceSmall,
                  Expanded(
                    child: Text(
                      l10n.autoRefreshWarning,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            _showAutoRefreshToast(context);
          },
          child: Text(l10n.apply),
        ),
      ],
    );
  }

  String _formatInterval(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    } else {
      final minutes = seconds ~/ 60;
      return '${minutes}m';
    }
  }

  void _showAutoRefreshToast(BuildContext context) {
    final l10n = DashboardLocalizations.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEnabled
              ? l10n.autoRefreshEnabledWithInterval(
                  _formatInterval(_selectedInterval),
                )
              : l10n.autoRefreshDisabled,
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: _isEnabled
            ? AppColors.success
            : AppColors.textSecondary,
      ),
    );
  }
}

// Floating Refresh Button (Alternative Implementation)
class DashboardFloatingRefresh extends StatelessWidget {
  final VoidCallback onRefresh;
  final bool isLoading;
  final bool isVisible;

  const DashboardFloatingRefresh({
    super.key,
    required this.onRefresh,
    this.isLoading = false,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: FloatingActionButton.small(
        onPressed: isLoading ? null : onRefresh,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.refresh, size: 20),
      ),
    );
  }
}
