import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../l10n/features/export/export_localizations.dart';
import '../../data/models/export_config_model.dart';
import '../../data/models/period_model.dart';
import '../bloc/export_bloc.dart';
import '../bloc/export_event.dart';
import '../bloc/export_state.dart';
import 'date_filter_card.dart';

class DateRangeFilterSection extends StatefulWidget {
  final DateRangeFilterModel? selectedDateRange;
  final Function(DateRangeFilterModel?) onDateRangeChanged;
  final bool isLargeScreen;

  const DateRangeFilterSection({
    super.key,
    this.selectedDateRange,
    required this.onDateRangeChanged,
    this.isLargeScreen = false,
  });

  @override
  State<DateRangeFilterSection> createState() => _DateRangeFilterSectionState();
}

class _DateRangeFilterSectionState extends State<DateRangeFilterSection> {
  DatePeriodsResponse? _datePeriodsData;
  String _selectedPeriod = 'last_30_days';
  String _selectedField = 'updated_at';
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  void initState() {
    super.initState();
    print('🔧 DateRangeFilterSection initState - Loading periods...');
    if (widget.selectedDateRange != null) {
      _selectedPeriod = widget.selectedDateRange!.period;
      _selectedField = widget.selectedDateRange!.field;
      print('🔧 Restored from widget: period=$_selectedPeriod, field=$_selectedField');
    } else {
      print('🔧 Using defaults: period=$_selectedPeriod, field=$_selectedField');
    }
    _loadDatePeriods();
  }

  void _loadDatePeriods() {
    print('🔧 _loadDatePeriods() called - dispatching LoadDatePeriods event');
    context.read<ExportBloc>().add(const LoadDatePeriods());
  }

  void _onPeriodChanged(String? period) {
    if (period == null) return;
    
    print('📅 Period changed to: $period');
    
    setState(() {
      _selectedPeriod = period;
    });
    
    _updateDateRange();
  }

  void _onFieldChanged(String? field) {
    if (field == null) return;
    
    setState(() {
      _selectedField = field;
    });
    
    _updateDateRange();
  }

  void _onCustomDateChanged({DateTime? startDate, DateTime? endDate}) {
    setState(() {
      if (startDate != null) _customStartDate = startDate;
      if (endDate != null) _customEndDate = endDate;
    });
    
    if (_selectedPeriod == 'custom' && _customStartDate != null && _customEndDate != null) {
      _updateDateRange();
    }
  }

  void _updateDateRange() {
    DateRangeFilterModel? dateRange;
    
    if (_selectedPeriod == 'custom') {
      if (_customStartDate != null && _customEndDate != null) {
        dateRange = DateRangeFilterModel(
          period: _selectedPeriod,
          field: _selectedField,
          customStartDate: _formatDate(_customStartDate!),
          customEndDate: _formatDate(_customEndDate!),
        );
        print('🗓️ Custom date range: ${_formatDate(_customStartDate!)} to ${_formatDate(_customEndDate!)}');
      }
    } else {
      dateRange = DateRangeFilterModel(
        period: _selectedPeriod,
        field: _selectedField,
      );
      print('⏰ Period selected: $_selectedPeriod for field: $_selectedField');
    }
    
    widget.onDateRangeChanged(dateRange);
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _toggleDateRangeFilter(bool enabled) {
    if (enabled) {
      _updateDateRange();
    } else {
      widget.onDateRangeChanged(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = ExportLocalizations.of(context);

    return BlocListener<ExportBloc, ExportState>(
      listener: (context, state) {
        print('🔧 BlocListener received state: ${state.runtimeType}');
        if (state is DatePeriodsLoaded) {
          print('🔧 DatePeriodsLoaded state received! Setting data...');
          setState(() {
            _datePeriodsData = state.datePeriodsData;
          });
          print('🔧 _datePeriodsData set: ${_datePeriodsData?.periods.length} periods, ${_datePeriodsData?.availableFields.length} fields');
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, theme, isDark, l10n),
          SizedBox(height: AppSpacing.lg),
          _buildDateFilterCards(context, theme, isDark, l10n),
          if (widget.selectedDateRange != null && _selectedPeriod == 'custom') ...[
            SizedBox(height: AppSpacing.lg),
            _buildCustomDatePicker(context, theme, isDark, l10n),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    ExportLocalizations l10n,
  ) {
    return Row(
      children: [
        Icon(Icons.date_range, color: AppColors.primary, size: 20),
        SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            l10n.dateRangeFilter,
            style: AppTextStyles.cardTitle.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        if (widget.selectedDateRange != null) ...[
          SizedBox(width: AppSpacing.sm),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Active',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDateFilterCards(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    ExportLocalizations l10n,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.divider,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enable toggle
          Row(
            children: [
              Switch(
                value: widget.selectedDateRange != null,
                onChanged: _toggleDateRangeFilter,
                activeColor: theme.colorScheme.primary,
              ),
              SizedBox(width: AppSpacing.md),
              Text(
                widget.selectedDateRange != null ? l10n.dateRangeEnabled : l10n.enableDateFilter,
                style: AppTextStyles.body1.copyWith(
                  color: isDark ? AppColors.darkText : AppColors.textPrimary,
                  fontWeight: widget.selectedDateRange != null ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
          
          // Show dropdowns when enabled
          if (widget.selectedDateRange != null) ...[
            SizedBox(height: AppSpacing.lg),
            if (_datePeriodsData == null) ...[
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Text(l10n.loadingPeriods, style: TextStyle(color: Colors.orange)),
                  ],
                ),
              ),
            ] else ...[
              if (widget.isLargeScreen)
                Row(
                  children: [
                    Expanded(child: _buildSimpleDropdown(l10n.dateFieldLabel, _selectedField, _getLocalizedDateFields(l10n), _onFieldChanged, theme, isDark)),
                    SizedBox(width: AppSpacing.lg),
                    Expanded(child: _buildSimpleDropdown(l10n.periodLabel, _selectedPeriod, _getLocalizedPeriods(l10n), _onPeriodChanged, theme, isDark)),
                  ],
                )
              else
                Column(
                  children: [
                    _buildSimpleDropdown(l10n.dateFieldLabel, _selectedField, _getLocalizedDateFields(l10n), _onFieldChanged, theme, isDark),
                    SizedBox(height: AppSpacing.lg),
                    _buildSimpleDropdown(l10n.periodLabel, _selectedPeriod, _getLocalizedPeriods(l10n), _onPeriodChanged, theme, isDark),
                  ],
                ),
            ],
          ],
        ],
      ),
    );
  }

  List<Map<String, String>> _getLocalizedDateFields(ExportLocalizations l10n) {
    return [
      {'value': 'created_at', 'label': l10n.createdDateField},
      {'value': 'updated_at', 'label': l10n.lastUpdatedField},
      {'value': 'last_scan_date', 'label': l10n.lastScanField},
    ];
  }

  List<Map<String, String>> _getLocalizedPeriods(ExportLocalizations l10n) {
    return [
      {'value': 'today', 'label': l10n.todayPeriod},
      {'value': 'last_7_days', 'label': l10n.last7DaysPeriod},
      {'value': 'last_30_days', 'label': l10n.last30DaysPeriod},
      {'value': 'last_90_days', 'label': l10n.last90DaysPeriod},
      {'value': 'last_180_days', 'label': l10n.last180DaysPeriod},
      {'value': 'last_365_days', 'label': l10n.last365DaysPeriod},
      {'value': 'custom', 'label': l10n.customDateRange},
    ];
  }

  Widget _buildSimpleDropdown(
    String label,
    String value,
    List<Map<String, String>> items,
    Function(String?) onChanged,
    ThemeData theme,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.subtitle2.copyWith(
            color: isDark ? AppColors.darkText : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.divider,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              onChanged: onChanged,
              items: items.map((item) => DropdownMenuItem(
                value: item['value'],
                child: Text(
                  item['label']!,
                  style: AppTextStyles.body1.copyWith(
                    color: isDark ? AppColors.darkText : AppColors.textPrimary,
                  ),
                ),
              )).toList(),
              dropdownColor: isDark ? AppColors.darkSurface : AppColors.surface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    ExportLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enable Filter',
            style: AppTextStyles.subtitle2.copyWith(
              color: isDark ? AppColors.darkText : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Switch(
                value: widget.selectedDateRange != null,
                onChanged: _toggleDateRangeFilter,
                activeColor: theme.colorScheme.primary,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  widget.selectedDateRange != null ? 'Enabled' : 'Disabled',
                  style: AppTextStyles.body2.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeToggle(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    ExportLocalizations l10n,
  ) {
    return Row(
      children: [
        Switch(
          value: widget.selectedDateRange != null,
          onChanged: _toggleDateRangeFilter,
          activeColor: theme.colorScheme.primary,
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            widget.selectedDateRange != null
                ? 'Date range filter enabled'
                : 'Enable date range filter',
            style: AppTextStyles.body1.copyWith(
              color: isDark ? AppColors.darkText : AppColors.textPrimary,
              fontWeight: widget.selectedDateRange != null ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateFieldCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    ExportLocalizations l10n,
  ) {
    if (_datePeriodsData == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date Field',
            style: AppTextStyles.subtitle2.copyWith(
              color: isDark ? AppColors.darkText : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.divider,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedField,
                onChanged: _onFieldChanged,
                items: _datePeriodsData!.availableFields
                    .map((field) => DropdownMenuItem(
                          value: field.field,
                          child: Text(
                            field.label,
                            style: AppTextStyles.body2.copyWith(
                              color: isDark ? AppColors.darkText : AppColors.textPrimary,
                            ),
                          ),
                        ))
                    .toList(),
                dropdownColor: isDark ? AppColors.darkSurface : AppColors.surface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFieldSelector(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    ExportLocalizations l10n,
  ) {
    if (_datePeriodsData == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter by Date Field',
          style: AppTextStyles.subtitle2.copyWith(
            color: isDark ? AppColors.darkText : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.divider,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedField,
              onChanged: _onFieldChanged,
              items: _datePeriodsData!.availableFields
                  .map((field) => DropdownMenuItem(
                        value: field.field,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              field.label,
                              style: AppTextStyles.body1.copyWith(
                                color: isDark ? AppColors.darkText : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              field.description,
                              style: AppTextStyles.caption.copyWith(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
              dropdownColor: isDark ? AppColors.darkSurface : AppColors.surface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    ExportLocalizations l10n,
  ) {
    if (_datePeriodsData == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Period',
            style: AppTextStyles.subtitle2.copyWith(
              color: isDark ? AppColors.darkText : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.divider,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPeriod,
                onChanged: _onPeriodChanged,
                items: _datePeriodsData!.periods
                    .map((period) => DropdownMenuItem(
                          value: period.value,
                          child: Text(
                            period.label,
                            style: AppTextStyles.body2.copyWith(
                              color: isDark ? AppColors.darkText : AppColors.textPrimary,
                            ),
                          ),
                        ))
                    .toList(),
                dropdownColor: isDark ? AppColors.darkSurface : AppColors.surface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    ExportLocalizations l10n,
  ) {
    if (_datePeriodsData == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Period',
          style: AppTextStyles.subtitle2.copyWith(
            color: isDark ? AppColors.darkText : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.divider,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedPeriod,
              onChanged: _onPeriodChanged,
              items: _datePeriodsData!.periods
                  .map((period) => DropdownMenuItem(
                        value: period.value,
                        child: Text(
                          period.label,
                          style: AppTextStyles.body1.copyWith(
                            color: isDark ? AppColors.darkText : AppColors.textPrimary,
                          ),
                        ),
                      ))
                  .toList(),
              dropdownColor: isDark ? AppColors.darkSurface : AppColors.surface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomDatePicker(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    ExportLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.customDateRangeTitle,
          style: AppTextStyles.subtitle2.copyWith(
            color: isDark ? AppColors.darkText : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        if (widget.isLargeScreen)
          Row(
            children: [
              Expanded(child: _buildDateField(l10n.startDateLabel, _customStartDate, true, l10n)),
              SizedBox(width: AppSpacing.md),
              Expanded(child: _buildDateField(l10n.endDateLabel, _customEndDate, false, l10n)),
            ],
          )
        else
          Column(
            children: [
              _buildDateField(l10n.startDateLabel, _customStartDate, true, l10n),
              SizedBox(height: AppSpacing.sm),
              _buildDateField(l10n.endDateLabel, _customEndDate, false, l10n),
            ],
          ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? selectedDate, bool isStartDate, ExportLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
          lastDate: DateTime.now(),
        );
        
        if (date != null) {
          if (isStartDate) {
            _onCustomDateChanged(startDate: date);
          } else {
            _onCustomDateChanged(endDate: date);
          }
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.divider,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 20,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    selectedDate != null 
                        ? _formatDate(selectedDate) 
                        : l10n.selectDate,
                    style: AppTextStyles.body1.copyWith(
                      color: selectedDate != null
                          ? (isDark ? AppColors.darkText : AppColors.textPrimary)
                          : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}