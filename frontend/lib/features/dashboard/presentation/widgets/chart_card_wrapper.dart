// Path: frontend/lib/features/dashboard/presentation/widgets/chart_card_wrapper.dart
import 'package:flutter/material.dart';

class ChartCardWrapper extends StatelessWidget {
  final String title;
  final String? dropdownLabel;
  final String? dropdownValue;
  final List<String>? dropdownItems;
  final Function(String?)? onDropdownChanged;
  final Widget? additionalControls;
  final Widget child;
  final VoidCallback? onRefresh;
  final bool showRefreshButton;
  final EdgeInsets? padding;

  const ChartCardWrapper({
    super.key,
    required this.title,
    required this.child,
    this.dropdownLabel,
    this.dropdownValue,
    this.dropdownItems,
    this.onDropdownChanged,
    this.additionalControls,
    this.onRefresh,
    this.showRefreshButton = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and controls
          _buildHeader(theme),
          const SizedBox(height: 16),

          // Main content
          child,
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title row
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (showRefreshButton && onRefresh != null)
              IconButton(
                onPressed: onRefresh,
                icon: Icon(
                  Icons.refresh,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
          ],
        ),

        // Controls row (if any controls exist)
        if (_hasControls()) ...[
          const SizedBox(height: 12),
          _buildControlsRow(theme),
        ],
      ],
    );
  }

  Widget _buildControlsRow(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Dropdown control
        if (_hasDropdown()) _buildDropdownControl(theme),

        // Additional controls
        if (additionalControls != null) additionalControls!,
      ],
    );
  }

  Widget _buildDropdownControl(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (dropdownLabel != null) ...[
          Text(
            dropdownLabel!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 8),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(8),
            color: theme.colorScheme.surface,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: dropdownValue,
              items: dropdownItems?.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item, style: theme.textTheme.bodyMedium),
                );
              }).toList(),
              onChanged: onDropdownChanged,
              style: theme.textTheme.bodyMedium,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                size: 16,
              ),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  bool _hasControls() {
    return _hasDropdown() || additionalControls != null;
  }

  bool _hasDropdown() {
    return dropdownItems != null &&
        dropdownItems!.isNotEmpty &&
        onDropdownChanged != null;
  }
}

/// Specialized wrapper for charts with loading states
class LoadingChartCardWrapper extends StatelessWidget {
  final String title;
  final bool isLoading;
  final String? loadingMessage;
  final Widget child;
  final String? dropdownLabel;
  final String? dropdownValue;
  final List<String>? dropdownItems;
  final Function(String?)? onDropdownChanged;
  final Widget? additionalControls;

  const LoadingChartCardWrapper({
    super.key,
    required this.title,
    required this.isLoading,
    required this.child,
    this.loadingMessage,
    this.dropdownLabel,
    this.dropdownValue,
    this.dropdownItems,
    this.onDropdownChanged,
    this.additionalControls,
  });

  @override
  Widget build(BuildContext context) {
    return ChartCardWrapper(
      title: title,
      dropdownLabel: dropdownLabel,
      dropdownValue: dropdownValue,
      dropdownItems: dropdownItems,
      onDropdownChanged: isLoading ? null : onDropdownChanged,
      additionalControls: additionalControls,
      child: isLoading ? _buildLoadingState() : child,
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            if (loadingMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                loadingMessage!,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Specialized wrapper for charts with error states
class ErrorChartCardWrapper extends StatelessWidget {
  final String title;
  final bool hasError;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final Widget child;
  final String? dropdownLabel;
  final String? dropdownValue;
  final List<String>? dropdownItems;
  final Function(String?)? onDropdownChanged;

  const ErrorChartCardWrapper({
    super.key,
    required this.title,
    required this.hasError,
    required this.child,
    this.errorMessage,
    this.onRetry,
    this.dropdownLabel,
    this.dropdownValue,
    this.dropdownItems,
    this.onDropdownChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ChartCardWrapper(
      title: title,
      dropdownLabel: dropdownLabel,
      dropdownValue: dropdownValue,
      dropdownItems: dropdownItems,
      onDropdownChanged: hasError ? null : onDropdownChanged,
      child: hasError ? _buildErrorState(context) : child,
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
            const SizedBox(height: 16),
            Text(
              'เกิดข้อผิดพลาด',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                style: TextStyle(color: Colors.red.shade600, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                child: const Text('ลองอีกครั้ง'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Specialized wrapper for empty data states
class EmptyChartCardWrapper extends StatelessWidget {
  final String title;
  final bool isEmpty;
  final String? emptyMessage;
  final IconData? emptyIcon;
  final Widget child;
  final String? dropdownLabel;
  final String? dropdownValue;
  final List<String>? dropdownItems;
  final Function(String?)? onDropdownChanged;

  const EmptyChartCardWrapper({
    super.key,
    required this.title,
    required this.isEmpty,
    required this.child,
    this.emptyMessage,
    this.emptyIcon,
    this.dropdownLabel,
    this.dropdownValue,
    this.dropdownItems,
    this.onDropdownChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ChartCardWrapper(
      title: title,
      dropdownLabel: dropdownLabel,
      dropdownValue: dropdownValue,
      dropdownItems: dropdownItems,
      onDropdownChanged: onDropdownChanged,
      child: isEmpty ? _buildEmptyState() : child,
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon ?? Icons.pie_chart_outline,
              color: Colors.grey.shade400,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'ไม่มีข้อมูล',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (emptyMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                emptyMessage!,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
