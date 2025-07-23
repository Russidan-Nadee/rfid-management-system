// Path: frontend/lib/features/export/presentation/widgets/export_config_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/export/presentation/bloc/export_bloc.dart';
import 'package:frontend/features/export/presentation/bloc/export_state.dart';
import 'package:frontend/features/export/presentation/bloc/export_event.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/app_constants.dart';
import '../../../../core/utils/helpers.dart';
import '../../data/models/export_config_model.dart';
import 'export_header_card.dart';
import 'export_type_section.dart';
import 'file_format_section.dart';

class ExportConfigWidget extends StatefulWidget {
  const ExportConfigWidget({super.key});

  @override
  State<ExportConfigWidget> createState() => _ExportConfigWidgetState();
}

class _ExportConfigWidgetState extends State<ExportConfigWidget> {
  String _selectedFormat = 'xlsx';

  void _onFormatSelected(String format) {
    setState(() {
      _selectedFormat = format;
    });
  }

  void _onExportPressed() {
    print('🚀 Export pressed - exporting all data');

    // Build simple export configuration (no date range, no filters)
    final config = ExportConfigModel(
      format: _selectedFormat,
      filters: null, // No filters = export all data
    );

    // Dispatch to BLoC
    context.read<ExportBloc>().add(CreateAssetExport(config));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExportBloc, ExportState>(
      listener: (context, state) {
        if (state is ExportJobCreated) {
          Helpers.showSuccess(context, 'Export job created! Processing...');
        } else if (state is ExportCompleted) {
          Helpers.showSuccess(
            context,
            'Export completed and ready to download!',
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
      padding: EdgeInsets.all(AppSpacing.xl),
      child: SizedBox(
        width: double.infinity,
        child: Container(
          constraints: BoxConstraints(maxWidth: clampedWidth),
          margin: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
                Expanded(child: ExportTypeSection()),
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
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: theme.colorScheme.primary,
            size: isLargeScreen ? 24 : 20,
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Export All Data',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: isLargeScreen ? 16 : 14,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'This will export all assets data without any date restrictions. All historical records will be included.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
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
        final isLoading = state is ExportLoading;

        return Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: isLoading
                ? Theme.of(context).colorScheme.surfaceVariant
                : Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              if (!isLoading)
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.3),
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
                padding: EdgeInsets.symmetric(
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
                                Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.lg),
                          Text(
                            state.message,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.upload,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 20,
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            'Export All Data',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
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
}
