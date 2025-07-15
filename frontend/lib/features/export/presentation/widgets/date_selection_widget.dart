// Path: frontend/lib/features/export/presentation/widgets/date_selection_widget.dart
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/app_constants.dart';
import '../../data/models/period_model.dart';

class DateSelectionWidget extends StatefulWidget {
  final PeriodModel? selectedPeriod;
  final Function(PeriodModel?) onPeriodSelected;
  final bool isLargeScreen;

  const DateSelectionWidget({
    super.key,
    this.selectedPeriod,
    required this.onPeriodSelected,
    this.isLargeScreen = false,
  });

  @override
  State<DateSelectionWidget> createState() => _DateSelectionWidgetState();
}

class _DateSelectionWidgetState extends State<DateSelectionWidget> {
  bool _isCustomRangeMode = false;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    if (widget.selectedPeriod != null) {
      _fromDate = widget.selectedPeriod!.from;
      _toDate = widget.selectedPeriod!.to;
      _isCustomRangeMode = !_isPresetPeriod(widget.selectedPeriod!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLarge =
        widget.isLargeScreen || (screenWidth >= AppConstants.tabletBreakpoint);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, theme, isLarge),
        SizedBox(
          height: AppSpacing.responsiveSpacing(
            context,
            mobile: AppSpacing.lg,
            tablet: AppSpacing.xl,
            desktop: AppSpacing.xl,
          ),
        ),
        _buildDateSelectionCard(context, theme, isLarge),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    ThemeData theme,
    bool isLarge,
  ) {
    return Row(
      children: [
        Icon(
          Icons.date_range,
          color: AppColors.primary,
          size: isLarge ? 24 : 20,
        ),
        AppSpacing.horizontalSpaceSM,
        Text(
          'Date Range',
          style: AppTextStyles.responsive(
            context: context,
            style: AppTextStyles.cardTitle.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            desktopFactor: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelectionCard(
    BuildContext context,
    ThemeData theme,
    bool isLarge,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        AppSpacing.responsiveSpacing(
          context,
          mobile: AppSpacing.lg,
          tablet: AppSpacing.xl,
          desktop: AppSpacing.xl,
        ),
      ),
      decoration: AppDecorations.card.copyWith(
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mode Toggle
          _buildModeToggle(context, theme, isLarge),

          SizedBox(
            height: AppSpacing.responsiveSpacing(
              context,
              mobile: AppSpacing.lg,
              tablet: AppSpacing.xl,
              desktop: AppSpacing.xl,
            ),
          ),

          // Content based on mode
          if (_isCustomRangeMode)
            _buildCustomDateRange(context, theme, isLarge)
          else
            _buildQuickPeriods(context, theme, isLarge),

          // Selected Period Display
          if (widget.selectedPeriod != null) ...[
            SizedBox(height: AppSpacing.lg),
            _buildSelectedPeriodDisplay(context, theme),
          ],
        ],
      ),
    );
  }

  Widget _buildModeToggle(BuildContext context, ThemeData theme, bool isLarge) {
    return Row(
      children: [
        _buildToggleButton(
          'Quick Periods',
          !_isCustomRangeMode,
          () => setState(() => _isCustomRangeMode = false),
          isLarge,
        ),
        AppSpacing.horizontalSpaceSM,
        _buildToggleButton(
          'Custom Range',
          _isCustomRangeMode,
          () => setState(() => _isCustomRangeMode = true),
          isLarge,
        ),
      ],
    );
  }

  Widget _buildToggleButton(
    String text,
    bool isSelected,
    VoidCallback onTap,
    bool isLarge,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: isLarge ? 44 : 40,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: AppBorders.md,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: AppTextStyles.button.copyWith(
                color: isSelected
                    ? AppColors.onPrimary
                    : AppColors.textSecondary,
                fontSize: isLarge ? 14 : 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickPeriods(
    BuildContext context,
    ThemeData theme,
    bool isLarge,
  ) {
    final presetOptions = PeriodOption.getPresetOptions();

    if (isLarge) {
      return _buildQuickPeriodsGrid(presetOptions, context);
    } else {
      return _buildQuickPeriodsList(presetOptions, context);
    }
  }

  Widget _buildQuickPeriodsGrid(
    List<PeriodOption> options,
    BuildContext context,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final isSelected = _isPeriodSelected(option.period);

        return _buildPeriodButton(option, isSelected, true);
      },
    );
  }

  Widget _buildQuickPeriodsList(
    List<PeriodOption> options,
    BuildContext context,
  ) {
    return Column(
      children: options.map((option) {
        final isSelected = _isPeriodSelected(option.period);
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: _buildPeriodButton(option, isSelected, false),
        );
      }).toList(),
    );
  }

  Widget _buildPeriodButton(PeriodOption option, bool isSelected, bool isGrid) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _fromDate = option.period.from;
          _toDate = option.period.to;
        });
        widget.onPeriodSelected(option.period);
      },
      child: Container(
        width: double.infinity,
        height: isGrid ? null : 44,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.backgroundSecondary,
          borderRadius: AppBorders.md,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Center(
          child: Text(
            option.label,
            style: AppTextStyles.button.copyWith(
              color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
              fontSize: isGrid ? 12 : 13,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDateRange(
    BuildContext context,
    ThemeData theme,
    bool isLarge,
  ) {
    return Column(
      children: [
        if (isLarge)
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  'From Date',
                  _fromDate,
                  _onFromDateSelected,
                ),
              ),
              AppSpacing.horizontalSpaceLG,
              Expanded(
                child: _buildDateField('To Date', _toDate, _onToDateSelected),
              ),
            ],
          )
        else
          Column(
            children: [
              _buildDateField('From Date', _fromDate, _onFromDateSelected),
              AppSpacing.verticalSpaceLG,
              _buildDateField('To Date', _toDate, _onToDateSelected),
            ],
          ),

        AppSpacing.verticalSpaceLG,

        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: _canApplyCustomRange() ? _applyCustomRange : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: AppBorders.md),
            ),
            child: Text(
              'Apply Date Range',
              style: AppTextStyles.button.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? value,
    Function(DateTime) onSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body2.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        AppSpacing.verticalSpaceXS,
        GestureDetector(
          onTap: () => _selectDate(context, value, onSelected),
          child: Container(
            width: double.infinity,
            height: 44,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: AppBorders.md,
              color: AppColors.surface,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                AppSpacing.horizontalSpaceSM,
                Expanded(
                  child: Text(
                    value != null ? _formatDate(value) : 'Select date',
                    style: AppTextStyles.body2.copyWith(
                      color: value != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedPeriodDisplay(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: AppBorders.md,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.primary, size: 16),
          AppSpacing.horizontalSpaceSM,
          Expanded(
            child: Text(
              'Selected: ${_formatDate(widget.selectedPeriod!.from)} - ${_formatDate(widget.selectedPeriod!.to)} (${widget.selectedPeriod!.daysDuration} days)',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    DateTime? initialDate,
    Function(DateTime) onSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(
        const Duration(days: 730),
      ), // 2 years ago
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onSelected(picked);
    }
  }

  void _onFromDateSelected(DateTime date) {
    setState(() {
      _fromDate = date;
      // Auto-adjust to date if from > to
      if (_toDate != null && date.isAfter(_toDate!)) {
        _toDate = date;
      }
    });
  }

  void _onToDateSelected(DateTime date) {
    setState(() {
      _toDate = date;
      // Auto-adjust from date if to < from
      if (_fromDate != null && date.isBefore(_fromDate!)) {
        _fromDate = date;
      }
    });
  }

  bool _canApplyCustomRange() {
    if (_fromDate == null || _toDate == null) return false;

    // Validate business rules
    final daysDiff = _toDate!.difference(_fromDate!).inDays;
    return daysDiff >= 0 && daysDiff <= 365; // Max 1 year
  }

  void _applyCustomRange() {
    if (_canApplyCustomRange()) {
      final period = PeriodModel(from: _fromDate!, to: _toDate!);
      widget.onPeriodSelected(period);
    }
  }

  bool _isPeriodSelected(PeriodModel period) {
    if (widget.selectedPeriod == null) return false;
    return _isSamePeriod(widget.selectedPeriod!, period);
  }

  bool _isSamePeriod(PeriodModel period1, PeriodModel period2) {
    return _isSameDay(period1.from, period2.from) &&
        _isSameDay(period1.to, period2.to);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isPresetPeriod(PeriodModel period) {
    final presets = PeriodOption.getPresetOptions();
    return presets.any((preset) => _isSamePeriod(preset.period, period));
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
