// Path: frontend/lib/features/export/presentation/widgets/create_export_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/export/presentation/bloc/export_bloc.dart';
import 'package:frontend/features/export/presentation/bloc/export_event.dart';
import 'package:frontend/features/export/presentation/bloc/export_state.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../app/theme/app_typography.dart';

class CreateExportButton extends StatelessWidget {
  final String selectedFormat;

  const CreateExportButton({super.key, required this.selectedFormat});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ExportBloc, ExportState>(
      builder: (context, state) {
        final isLoading = state is ExportLoading;

        return Container(
          width: double.infinity,
          height: 56, // Using standard button height
          decoration: isLoading
              ? AppDecorations.buttonSecondary
              : AppDecorations.buttonPrimary,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading
                  ? null
                  : () => context.read<ExportBloc>().add(
                      CreateAssetExport(selectedFormat),
                    ),
              borderRadius: AppBorders.lg,
              child: Container(
                padding: AppSpacing.buttonPaddingSymmetric,
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
                                AppColors.onPrimary,
                              ),
                            ),
                          ),
                          AppSpacing.horizontalSpaceLG,
                          Text(
                            state.message,
                            style: AppTextStyles.button.copyWith(
                              color: AppColors.onPrimary,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.upload,
                            color: AppColors.onPrimary,
                            size: 20,
                          ),
                          AppSpacing.horizontalSpaceSM,
                          Text(
                            'Export File',
                            style: AppTextStyles.button.copyWith(
                              color: AppColors.onPrimary,
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
