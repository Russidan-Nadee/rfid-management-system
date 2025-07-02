// Path: frontend/lib/features/export/presentation/widgets/export_config_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/export/presentation/bloc/export_bloc.dart';
import 'package:frontend/features/export/presentation/bloc/export_state.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/app_constants.dart';
import '../../../../core/utils/helpers.dart';
import 'export_header_card.dart';
import 'export_type_section.dart';
import 'file_format_section.dart';
import 'create_export_button.dart';

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

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExportBloc, ExportState>(
      listener: (context, state) {
        if (state is ExportJobCreated) {
          Helpers.showSuccess(context, 'Export job created! Processing...');
        } else if (state is ExportCompleted) {
          Helpers.showSuccess(context, 'Export completed and shared!');
        } else if (state is ExportError) {
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
    final maxWidth = screenWidth * 0.9; // 90% ของหน้าจอ
    final clampedWidth = maxWidth.clamp(600.0, 1200.0); // ขยายขอบเขต

    return Padding(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: SizedBox(
        width: double.infinity, // เต็มความกว้าง
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
        const ExportHeaderCard(),

        SizedBox(
          height: AppSpacing.responsiveSpacing(
            context,
            mobile: AppSpacing.xl,
            tablet: AppSpacing.xxl,
            desktop: AppSpacing.xxxl,
          ),
        ),

        // Export Type and File Format in Row for large screens
        if (isLargeScreen)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
          )
        else
          // Mobile: Stack vertically
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
            mobile: AppSpacing.xxl,
            tablet: AppSpacing.xxxl,
            desktop: AppSpacing.xxxxl,
          ),
        ),

        _buildExportButton(context, isLargeScreen: isLargeScreen),
      ],
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
        child: SizedBox(
          width: buttonWidth,
          child: CreateExportButton(selectedFormat: _selectedFormat),
        ),
      );
    } else {
      return CreateExportButton(selectedFormat: _selectedFormat);
    }
  }
}
