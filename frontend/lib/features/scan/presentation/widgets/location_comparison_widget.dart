// Path: frontend/lib/features/scan/presentation/widgets/location_comparison_widget.dart
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../app/theme/app_typography.dart';

class LocationComparisonData {
  final String locationName;
  final int scannedCount;
  final int expectedCount;
  final bool isSelected;
  final bool hasWrongItems;

  const LocationComparisonData({
    required this.locationName,
    required this.scannedCount,
    required this.expectedCount,
    required this.isSelected,
    this.hasWrongItems = false,
  });

  bool get isComplete => scannedCount >= expectedCount;
  int get missingCount => expectedCount - scannedCount;
}

class LocationComparisonWidget extends StatefulWidget {
  final List<LocationComparisonData> comparisonData;
  final int unknownItemsCount;
  final String? selectedCurrentLocation;

  const LocationComparisonWidget({
    super.key,
    required this.comparisonData,
    this.unknownItemsCount = 0,
    this.selectedCurrentLocation,
  });

  @override
  State<LocationComparisonWidget> createState() =>
      _LocationComparisonWidgetState();
}

class _LocationComparisonWidgetState extends State<LocationComparisonWidget> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: AppSpacing.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkText
                        : theme.colorScheme.primary,
                    size: 18,
                  ),
                  AppSpacing.horizontalSpaceSM,
                  Text(
                    'Location Comparison',
                    style: AppTextStyles.filterLabel.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkText
                          : theme.colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  if (widget.selectedCurrentLocation != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: Text(
                        'Current: ${widget.selectedCurrentLocation}',
                        style: AppTextStyles.caption.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    AppSpacing.horizontalSpaceSM,
                  ],
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkText
                          : theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _isExpanded ? null : 0,
            child: _isExpanded
                ? Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.md,
                    ),
                    child: _buildComparisonContent(),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonContent() {
    return Column(
      children: [
        // Location comparison chips
        if (widget.comparisonData.isNotEmpty) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.comparisonData.map((data) {
                return Padding(
                  padding: AppSpacing.only(right: AppSpacing.sm),
                  child: _buildComparisonChip(data),
                );
              }).toList(),
            ),
          ),
          if (widget.unknownItemsCount > 0) AppSpacing.verticalSpaceSM,
        ],

        // Unknown items chip
        if (widget.unknownItemsCount > 0)
          Row(children: [_buildUnknownItemsChip()]),
      ],
    );
  }

  Widget _buildComparisonChip(LocationComparisonData data) {
    final theme = Theme.of(context);

    // Color logic:
    // - Normal: location ที่ user เลือก
    // - Orange: location อื่นที่มี assets ปนมา
    // - Red: Unknown items (จัดการแยกต่างหาก)

    Color chipColor;
    Color textColor;
    Color borderColor;

    if (data.isSelected) {
      // Selected location - Normal color (primary)
      chipColor = theme.colorScheme.primary;
      textColor = theme.colorScheme.onPrimary;
      borderColor = theme.colorScheme.primary;
    } else if (data.hasWrongItems || data.scannedCount > 0) {
      // Other locations with mixed items - Orange
      chipColor = AppColors.warning.withValues(alpha: 0.1);
      textColor = AppColors.warning;
      borderColor = AppColors.warning;
    } else {
      // Empty locations - Normal but muted
      chipColor = theme.colorScheme.primary.withValues(alpha: 0.1);
      textColor = Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkText
          : theme.colorScheme.primary;
      borderColor = Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkTextSecondary.withValues(alpha: 0.2)
          : theme.colorScheme.primary;
    }

    return Container(
      padding: AppSpacing.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: AppBorders.lg,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on, size: 14, color: textColor),
          AppSpacing.horizontalSpaceXS,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getDisplayLocationName(data.locationName),
                style: AppTextStyles.caption.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (data.expectedCount > 0)
                Text(
                  '${data.scannedCount}/${data.expectedCount}',
                  style: AppTextStyles.caption.copyWith(
                    color: textColor.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                )
              else
                Text(
                  '${data.scannedCount}',
                  style: AppTextStyles.caption.copyWith(
                    color: textColor.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
            ],
          ),
          if (data.expectedCount > 0 && !data.isComplete) ...[
            AppSpacing.horizontalSpaceXS,
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: data.isSelected
                    ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                    : AppColors.error.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUnknownItemsChip() {
    final theme = Theme.of(context);

    return Container(
      padding: AppSpacing.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: AppBorders.lg,
        border: Border.all(color: AppColors.error, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.help_outline, size: 14, color: AppColors.error),
          AppSpacing.horizontalSpaceXS,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Unknown Items',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${widget.unknownItemsCount}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.error.withValues(alpha: 0.8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          AppSpacing.horizontalSpaceXS,
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  String _getDisplayLocationName(String locationName) {
    const maxLength = 15.0;
    const trimLength = 12.0;

    if (locationName.length > maxLength) {
      return '${locationName.substring(0, trimLength.toInt())}...';
    }
    return locationName;
  }
}
