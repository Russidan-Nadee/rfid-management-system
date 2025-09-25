import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/admin_asset_image_entity.dart';
import '../../domain/usecases/get_admin_asset_images_usecase.dart';
import '../../domain/usecases/upload_admin_image_usecase.dart';
import '../../domain/usecases/delete_image_usecase.dart';
import '../../../../l10n/features/admin/admin_localizations.dart';
import 'admin_image_gallery_widget.dart';

class AssetImagesTab extends StatefulWidget {
  final String assetNo;
  final GetAdminAssetImagesUsecase getImagesUsecase;
  final UploadAdminImageUsecase uploadImageUsecase;
  final DeleteImageUsecase deleteImageUsecase;

  const AssetImagesTab({
    super.key,
    required this.assetNo,
    required this.getImagesUsecase,
    required this.uploadImageUsecase,
    required this.deleteImageUsecase,
  });

  @override
  State<AssetImagesTab> createState() => _AssetImagesTabState();
}

class _AssetImagesTabState extends State<AssetImagesTab> {
  List<AdminAssetImageEntity> _images = [];
  bool _loadingImages = false;
  bool _uploadingImage = false;
  Set<int> _deletingImages = {};

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    setState(() {
      _loadingImages = true;
    });

    try {
      final images = await widget.getImagesUsecase(widget.assetNo);
      setState(() {
        _images = images;
        _loadingImages = false;
      });
    } catch (e) {
      setState(() {
        _loadingImages = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load images: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    print('🔍 Dialog: Starting image picker...');

    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      print('🔍 Dialog: Image picker result: ${pickedFile?.path ?? 'null'}');

      if (pickedFile != null) {
        print('🔍 Dialog: Setting upload state to true...');
        setState(() {
          _uploadingImage = true;
        });
        print('🔍 Dialog: Upload state updated, starting upload...');

        try {
          print('🔍 Dialog: Creating File object...');
          print('🔍 Dialog: picked file path: ${pickedFile.path}');

          // Handle web blob URLs differently
          if (kIsWeb && pickedFile.path.startsWith('blob:')) {
            print('🔍 Dialog: Web blob URL detected, using XFile directly');

            // For web, read bytes from XFile instead of File
            final bytes = await pickedFile.readAsBytes();
            print('🔍 Dialog: Read ${bytes.length} bytes from XFile');

            // Create a temporary file-like object for web
            final webImageFile = WebImageFile(
              pickedFile.path,
              bytes,
              pickedFile.name,
            );
            print(
              '🔍 Dialog: Created WebImageFile wrapper with name: ${pickedFile.name}',
            );

            print('🔍 Dialog: Calling upload use case with web file...');
            final success = await widget.uploadImageUsecase(
              widget.assetNo,
              webImageFile,
            );

            print('🔍 Dialog: Upload use case completed, success: $success');

            if (success) {
              await _loadImages();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Image uploaded successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
          } else {
            print('🔍 Dialog: Regular file path, using File object');
            final imageFile = File(pickedFile.path);
            print('🔍 Dialog: File created successfully');

            print('🔍 Dialog: File exists check...');
            final exists = await imageFile.exists();
            print('🔍 Dialog: File exists: $exists');

            if (exists) {
              final size = await imageFile.length();
              print('🔍 Dialog: File size: $size bytes');
            }

            print('🔍 Dialog: Calling upload use case...');
            final success = await widget.uploadImageUsecase(
              widget.assetNo,
              imageFile,
            );

            print('🔍 Dialog: Upload use case completed, success: $success');

            if (success) {
              await _loadImages();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Image uploaded successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } else {
              print('❌ Dialog: Mobile upload failed (success = false)');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Upload failed - please try again'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
        } catch (e) {
          print('💥 Dialog: Upload error caught: $e');
          print('💥 Dialog: Error type: ${e.runtimeType}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload image: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } finally {
          print('🔍 Dialog: Setting upload state to false...');
          if (mounted) {
            setState(() {
              _uploadingImage = false;
            });
          }
          print('🔍 Dialog: Upload state reset');
        }
      } else {
        print('ℹ️ Dialog: No image selected by user');
      }
    } catch (e) {
      print('💥 Dialog: Image picker error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open image picker: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteImage(int imageId) async {
    setState(() {
      _deletingImages.add(imageId);
    });

    try {
      await widget.deleteImageUsecase(imageId);
      await _loadImages(); // Reload images
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _deletingImages.remove(imageId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AdminLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upload button
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _uploadingImage ? null : _pickAndUploadImage,
                icon: _uploadingImage
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_photo_alternate),
                label: Text(_uploadingImage ? 'Uploading...' : 'Add Image'),
              ),
              const SizedBox(width: 16),
              Text(
                'Total: ${_images.length} images',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Images grid
          Expanded(
            child: _loadingImages
                ? const Center(child: CircularProgressIndicator())
                : AdminImageGalleryWidget(
                    images: _images,
                    assetNo: widget.assetNo,
                    onDeleteImage: _deleteImage,
                    deletingImages: _deletingImages,
                  ),
          ),
        ],
      ),
    );
  }
}

// Web-compatible File wrapper for blob URLs
class WebImageFile implements File {
  final String _path;
  final Uint8List _bytes;
  final String _name;

  WebImageFile(this._path, this._bytes, this._name);

  @override
  String get path => _path;

  @override
  Future<bool> exists() async => true; // Blob always exists if we have bytes

  @override
  Future<int> length() async => _bytes.length;

  @override
  Future<Uint8List> readAsBytes() async => _bytes;

  String get name => _name;

  // Minimal File interface implementation - only implement what we need
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError(
    'WebImageFile only supports exists(), length(), readAsBytes(), and path',
  );
}
