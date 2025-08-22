// Path: frontend/lib/features/scan/presentation/widgets/image_upload_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/utils/helpers.dart';
import '../../../../l10n/features/scan/scan_localizations.dart';
import '../bloc/image_upload_bloc.dart';

class ImageUploadWidget extends StatelessWidget {
  final String assetNo;
  final VoidCallback? onUploadSuccess;

  const ImageUploadWidget({
    super.key,
    required this.assetNo,
    this.onUploadSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = ScanLocalizations.of(context);
    final theme = Theme.of(context);

    return BlocListener<ImageUploadBloc, ImageUploadState>(
      listener: (context, state) {
        if (state is ImageUploadSuccess) {
          Helpers.showSuccess(context, 'Image uploaded successfully');
          onUploadSuccess?.call();
        } else if (state is ImageUploadError) {
          Helpers.showError(context, state.message);
        }
      },
      child: BlocBuilder<ImageUploadBloc, ImageUploadState>(
        builder: (context, state) {
          if (state is ImageUploadLoading) {
            return _buildLoadingWidget(theme, l10n);
          }

          return _buildUploadButton(context, theme, l10n);
        },
      ),
    );
  }

  Widget _buildUploadButton(
    BuildContext context,
    ThemeData theme,
    ScanLocalizations l10n,
  ) {
    return ElevatedButton.icon(
      onPressed: () => _showImageSourceDialog(context),
      icon: Icon(Icons.add_photo_alternate, color: theme.colorScheme.onPrimary),
      label: Text(
        'Add Image',
        style: TextStyle(color: theme.colorScheme.onPrimary),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildLoadingWidget(ThemeData theme, ScanLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Uploading image...',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    // ✅ เก็บ BLoC reference ก่อนเปิด BottomSheet
    final imageUploadBloc = context.read<ImageUploadBloc>();

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImageWithBloc(imageUploadBloc, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImageWithBloc(imageUploadBloc, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageWithBloc(
    ImageUploadBloc imageUploadBloc,
    ImageSource source,
  ) async {
    try {
      print('🔍 ImageUploadWidget: Starting image picker for asset: $assetNo');

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      print('🔍 ImageUploadWidget: Picker completed');

      if (image != null) {
        print('✅ ImageUploadWidget: Image selected: ${image.path}');

        final File imageFile = File(image.path);

        // ตรวจสอบไฟล์
        final fileExists = await imageFile.exists();
        final fileSize = fileExists ? await imageFile.length() : 0;

        print('🔍 ImageUploadWidget: File exists: $fileExists');
        print('🔍 ImageUploadWidget: File size: $fileSize bytes');

        if (fileExists && fileSize > 0) {
          print('🔍 ImageUploadWidget: Sending upload event to BLoC');

          // ✅ ใช้ BLoC reference ที่ส่งมา
          imageUploadBloc.add(
            UploadImageEvent(assetNo: assetNo, imageFile: imageFile),
          );

          print('✅ ImageUploadWidget: Upload event sent successfully');
        } else {
          print('❌ ImageUploadWidget: Invalid file');
        }
      } else {
        print('ℹ️ ImageUploadWidget: No image selected by user');
      }
    } catch (error) {
      print('💥 ImageUploadWidget: Error in _pickImage: $error');
    }
  }
}
