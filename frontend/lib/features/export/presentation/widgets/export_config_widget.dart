// File: export_config_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/export/presentation/bloc/export_bloc.dart';
import 'package:frontend/features/export/presentation/bloc/export_state.dart';
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
          _showSnackBar(
            context,
            'Export job created! Processing...',
            Colors.blue,
          );
        } else if (state is ExportCompleted) {
          _showSnackBar(context, 'Export completed and shared!', Colors.green);
        } else if (state is ExportError) {
          _showSnackBar(context, state.message, Colors.red);
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ExportHeaderCard(),
            const SizedBox(height: 24),
            const ExportTypeSection(),
            const SizedBox(height: 24),
            FileFormatSection(
              selectedFormat: _selectedFormat,
              onFormatSelected: _onFormatSelected,
            ),
            const SizedBox(height: 32),
            CreateExportButton(selectedFormat: _selectedFormat),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
