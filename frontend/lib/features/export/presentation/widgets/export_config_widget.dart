// Path: frontend/lib/features/export/presentation/widgets/export_config_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/export/presentation/bloc/export_bloc.dart';
import 'package:frontend/features/export/presentation/bloc/export_state.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
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
      child: SingleChildScrollView(
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ExportHeaderCard(),
            AppSpacing.verticalSpaceXL,
            const ExportTypeSection(),
            AppSpacing.verticalSpaceXL,
            FileFormatSection(
              selectedFormat: _selectedFormat,
              onFormatSelected: _onFormatSelected,
            ),
            AppSpacing.verticalSpaceXXL,
            CreateExportButton(selectedFormat: _selectedFormat),
          ],
        ),
      ),
    );
  }
}
