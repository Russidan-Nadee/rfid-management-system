// Path: frontend/lib/features/export/presentation/widgets/export_config_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/export/presentation/bloc/export_bloc.dart';
import 'package:frontend/features/export/presentation/bloc/export_state.dart';
import 'package:frontend/features/export/presentation/bloc/export_event.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/app_constants.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../l10n/features/export/export_localizations.dart';
import '../../data/models/export_config_model.dart';
import 'export_header_card.dart';
import 'export_type_section.dart';
import 'file_format_section.dart';
import 'status_filter_section.dart';
import 'date_range_filter_section.dart';

class ExportConfigWidget extends StatefulWidget {
  const ExportConfigWidget({super.key});

  @override
  State<ExportConfigWidget> createState() => _ExportConfigWidgetState();
}

class _ExportConfigWidgetState extends State<ExportConfigWidget> {
  String _selectedFormat = 'xlsx';
  List<String> _selectedStatuses = []; // Empty = all statuses
  DateRangeFilterModel? _selectedDateRange;

  void _onFormatSelected(String format) {
    print('${ExportLocalizations.of(context).formatSelected}$format');
    setState(() {
      _selectedFormat = format;
    });
    print(
      '${ExportLocalizations.of(context).selectedFormatLabel}$_selectedFormat',
    );
  }

  void _onStatusesChanged(List<String> statuses) {
    setState(() {
      _selectedStatuses = statuses;
    });
    print('Selected statuses: ${statuses.isEmpty ? 'All' : statuses.join(', ')}');
  }

  void _onDateRangeChanged(DateRangeFilterModel? dateRange) {
    setState(() {
      _selectedDateRange = dateRange;
    });
    print('Date range changed: ${dateRange?.period ?? 'None'}');
  }

  void _onExportPressed() {
    final l10n = ExportLocalizations.of(context);
    print(l10n.exportPressed);
    print('${l10n.selectedFormatLabel}$_selectedFormat');

    // Build export configuration with filters if selected
    final filters = (_selectedStatuses.isNotEmpty || _selectedDateRange != null) 
        ? ExportFiltersModel(
            status: _selectedStatuses.isNotEmpty ? _selectedStatuses : null,
            dateRange: _selectedDateRange,
          )
        : null;
    
    final config = ExportConfigModel(
      format: _selectedFormat,
      filters: filters,
    );

    print('${l10n.configFormatLabel}${config.format}');

    // Dispatch to BLoC
    context.read<ExportBloc>().add(CreateAssetExport(config));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ExportLocalizations.of(context);

    return BlocListener<ExportBloc, ExportState>(
      listener: (context, state) {
        if (state is ExportJobCreated) {
          Helpers.showSuccess(context, l10n.exportJobCreated);
        } else if (state is ExportCompleted) {
          Helpers.showSuccess(context, l10n.exportCompleted);
          context.read<ExportBloc>().add(
            DownloadExport(state.exportJob.exportId),
          );
        } else if (state is ExportError) {
          Helpers.showError(context, state.message);
        } else if (state is ExportPlatformNotSupported) {
          Helpers.showError(context, state.message);
        }
      },
      child: _buildResponsiveLayout(context),
    );
  }

  Widget _buildResponsiveLayout(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= AppConstants.tabletBreakpoint;

    if (isLargeScreen) {
      return _buildLargeScreenLayout(context);
    } else {
      return _buildCompactLayout(context);
    }
  }

  Widget _buildLargeScreenLayout(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth * 0.9;
    final clampedWidth = maxWidth.clamp(600.0, 1200.0);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: SizedBox(
        width: double.infinity,
        child: Container(
          constraints: BoxConstraints(maxWidth: clampedWidth),
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: SingleChildScrollView(
            child: _buildContent(context, isLargeScreen: true),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.screenPaddingAll,
      child: _buildContent(context, isLargeScreen: false),
    );
  }

  Widget _buildContent(BuildContext context, {required bool isLargeScreen}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Card
        const ExportHeaderCard(),

        SizedBox(
          height: AppSpacing.responsiveSpacing(
            context,
            mobile: AppSpacing.xl,
            tablet: AppSpacing.xxl,
            desktop: AppSpacing.xxxl,
          ),
        ),

        // Export Type and File Format
        if (isLargeScreen)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Expanded(child: ExportTypeSection()),
                AppSpacing.horizontalSpaceXXL,
                Expanded(
                  child: FileFormatSection(
                    selectedFormat: _selectedFormat,
                    onFormatSelected: _onFormatSelected,
                    isLargeScreen: isLargeScreen,
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              const ExportTypeSection(),
              SizedBox(
                height: AppSpacing.responsiveSpacing(
                  context,
                  mobile: AppSpacing.xl,
                  tablet: AppSpacing.xxl,
                  desktop: AppSpacing.xxxl,
                ),
              ),
              FileFormatSection(
                selectedFormat: _selectedFormat,
                onFormatSelected: _onFormatSelected,
                isLargeScreen: isLargeScreen,
              ),
            ],
          ),

        SizedBox(
          height: AppSpacing.responsiveSpacing(
            context,
            mobile: AppSpacing.xl,
            tablet: AppSpacing.xxl,
            desktop: AppSpacing.xxxl,
          ),
        ),

        // Status Filter Section
        StatusFilterSection(
          selectedStatuses: _selectedStatuses,
          onStatusesChanged: _onStatusesChanged,
          isLargeScreen: isLargeScreen,
        ),

        SizedBox(
          height: AppSpacing.responsiveSpacing(
            context,
            mobile: AppSpacing.xl,
            tablet: AppSpacing.xxl,
            desktop: AppSpacing.xxxl,
          ),
        ),

        // Date Range Filter Section
        DateRangeFilterSection(
          selectedDateRange: _selectedDateRange,
          onDateRangeChanged: _onDateRangeChanged,
          isLargeScreen: isLargeScreen,
        ),

        SizedBox(
          height: AppSpacing.responsiveSpacing(
            context,
            mobile: AppSpacing.xl,
            tablet: AppSpacing.xxl,
            desktop: AppSpacing.xxxl,
          ),
        ),

        // All Data Notice Card
        _buildAllDataNoticeCard(context, isLargeScreen),

        SizedBox(
          height: AppSpacing.responsiveSpacing(
            context,
            mobile: AppSpacing.xxl,
            tablet: AppSpacing.xxxl,
            desktop: AppSpacing.xxxxl,
          ),
        ),

        // Export Button
        _buildExportButton(context, isLargeScreen: isLargeScreen),
      ],
    );
  }

  Widget _buildAllDataNoticeCard(BuildContext context, bool isLargeScreen) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = ExportLocalizations.of(context);

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
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant
            : theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withValues(alpha: 0.3)
              : theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: isDark
                ? theme.colorScheme.primary
                : theme.colorScheme.primary,
            size: isLargeScreen ? 24 : 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.exportData,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isDark
                        ? AppColors.darkText
                        : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: isLargeScreen ? 16 : 14,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _buildExportDescription(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    fontSize: isLargeScreen ? 14 : 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(
    BuildContext context, {
    required bool isLargeScreen,
  }) {
    if (isLargeScreen) {
      final screenWidth = MediaQuery.of(context).size.width;
      final buttonWidth = (screenWidth * 0.3).clamp(200.0, 400.0);

      return Center(
        child: SizedBox(width: buttonWidth, child: _buildExportButtonContent()),
      );
    } else {
      return _buildExportButtonContent();
    }
  }

  Widget _buildExportButtonContent() {
    return BlocBuilder<ExportBloc, ExportState>(
      builder: (context, state) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final isLoading = state is ExportLoading;
        final l10n = ExportLocalizations.of(context);

        return Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: isLoading
                ? (isDark
                      ? AppColors.darkSurfaceVariant
                      : theme.colorScheme.surfaceContainerHighest)
                : theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              if (!isLoading)
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading ? null : _onExportPressed,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDark
                                    ? AppColors.darkTextSecondary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Text(
                            state.message,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.upload,
                            color: theme.colorScheme.onPrimary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            l10n.exportData,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _buildExportDescription() {
    final l10n = ExportLocalizations.of(context);
    final descriptions = <String>[];
    
    if (_selectedStatuses.isNotEmpty) {
      descriptions.add('Status filters: ${_selectedStatuses.join(', ')}');
    }
    
    if (_selectedDateRange != null) {
      final period = _selectedDateRange!.period;
      final field = _selectedDateRange!.field;
      if (period == 'custom') {
        descriptions.add('Custom date range on $field');
      } else {
        descriptions.add('${period.replaceAll('_', ' ').toUpperCase()} on $field');
      }
    }
    
    if (descriptions.isEmpty) {
      return l10n.exportDataDescription;
    }
    
    return 'Export assets with: ${descriptions.join(', ')}';
  }
}
